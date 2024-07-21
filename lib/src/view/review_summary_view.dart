import 'package:flutter/material.dart';
import 'package:soignemoiapplication/src/layout/header.dart';
import 'package:soignemoiapplication/src/layout/footer.dart';

class ReviewSummaryView extends StatelessWidget {
  final Map<String, dynamic> review;

  ReviewSummaryView({required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Résumé de l\'Avis',
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
              child: SingleChildScrollView(
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
                          review['title'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          review['description'],
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Date: ${review['date']}',
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Patient: ${review['user_firstname']} ${review['user_lastname']}',
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
