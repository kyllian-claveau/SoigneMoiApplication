import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date
import 'package:soignemoiapplication/src/api/prescription_api.dart';

class PrescriptionView extends StatefulWidget {
  final int stayId;

  PrescriptionView({required this.stayId});

  @override
  _PrescriptionViewState createState() => _PrescriptionViewState();
}

class _PrescriptionViewState extends State<PrescriptionView> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> medications = [];
  TextEditingController medicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  TextEditingController startDateController = TextEditingController(); // Controller pour la date de début
  TextEditingController endDateController = TextEditingController(); // Controller pour la date de fin

  void _addMedication() {
    if (medicationController.text.isNotEmpty && dosageController.text.isNotEmpty) {
      setState(() {
        medications.add({
          'name': medicationController.text,
          'dosage': dosageController.text,
        });
        medicationController.clear();
        dosageController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both medication and dosage')),
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

  void _submitPrescription() async {
    if (_formKey.currentState!.validate()) {
      try {
        await PrescriptionAPI.addPrescription(
          stayId: widget.stayId,
          medications: medications,
          startDate: DateTime.parse(startDateController.text),
          endDate: DateTime.parse(endDateController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prescription added successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add prescription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, startDateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, endDateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an end date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Medications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: medicationController,
                  decoration: InputDecoration(
                    labelText: 'Medication',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addMedication,
                  child: Text('Add Medication'),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(medications[index]['name']),
                        subtitle: Text(medications[index]['dosage']),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPrescription,
                  child: Text('Submit Prescription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
