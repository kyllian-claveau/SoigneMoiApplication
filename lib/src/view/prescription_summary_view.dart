import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soignemoiapplication/src/api/prescription_api.dart';
import 'package:soignemoiapplication/src/view/home_screen.dart';

class PrescriptionSummaryView extends StatefulWidget {
  final int prescriptionId;

  PrescriptionSummaryView({required this.prescriptionId});

  @override
  _PrescriptionSummaryViewState createState() => _PrescriptionSummaryViewState();
}

class _PrescriptionSummaryViewState extends State<PrescriptionSummaryView> {
  Map<String, dynamic>? prescriptionDetails;
  bool isLoading = true;
  TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPrescriptionDetails();
  }

  void fetchPrescriptionDetails() async {
    try {
      var details = await PrescriptionAPI.getPrescriptionDetails(widget.prescriptionId);
      setState(() {
        prescriptionDetails = details;
        endDateController.text = details['end_date'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch prescription details: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateEndDate() async {
    if (endDateController.text.isNotEmpty) {
      try {
        await PrescriptionAPI.updateEndDate(
          prescriptionId: widget.prescriptionId,
          endDate: DateTime.parse(endDateController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End date updated successfully')),
        );
        // Rediriger vers HomeScreen après la mise à jour
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update end date: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Summary'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : prescriptionDetails == null
          ? Center(child: Text('No details available'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescription ID: ${prescriptionDetails!['id']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Start Date: ${prescriptionDetails!['start_date']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: endDateController,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, endDateController),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _updateEndDate,
                        child: Text('Update End Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Medications:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...prescriptionDetails!['medications'].map<Widget>((med) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      med['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(med['dosage']),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
