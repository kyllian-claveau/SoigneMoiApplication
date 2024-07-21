import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soignemoiapplication/src/api/prescription_api.dart';
import 'package:soignemoiapplication/src/layout/header.dart';
import 'package:soignemoiapplication/src/layout/footer.dart';
import 'home_screen.dart';

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
        SnackBar(content: Text('Échec de la récupération des détails de la prescription : $e')),
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
          SnackBar(content: Text('Date de fin mise à jour avec succès')),
        );
        // Rediriger vers HomeScreen après la mise à jour
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour de la date de fin : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Résumé de la Prescription',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : prescriptionDetails == null
                  ? Center(child: Text('Aucun détail disponible'))
                  : SingleChildScrollView(
                child: Card(
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
                          'Date de début: ${prescriptionDetails!['start_date']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: endDateController,
                          decoration: InputDecoration(
                            labelText: 'Date de fin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, endDateController),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: _updateEndDate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Mettre à jour la date de fin'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const AppFooter(isHomeScreen: false),
        ],
      ),
    );
  }
}
