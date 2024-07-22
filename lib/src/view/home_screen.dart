import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:soignemoiapplication/src/api/prescription_api.dart';
import 'package:soignemoiapplication/src/view/prescription_view.dart';
import 'package:soignemoiapplication/src/view/prescription_summary_view.dart';
import 'package:soignemoiapplication/src/view/review_view.dart';
import 'package:soignemoiapplication/src/view/review_summary_view.dart';
import 'package:soignemoiapplication/src/api/stays_api.dart';
import 'package:soignemoiapplication/src/api/review_api.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:soignemoiapplication/src/layout/header.dart';
import 'package:soignemoiapplication/src/layout/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const route = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> stays = [];

  @override
  void initState() {
    super.initState();
    fetchStays();
  }

  void fetchStays() async {
    try {
      List<dynamic> fetchedStays = await StayAPI.fetchStays();
      setState(() {
        stays = fetchedStays;
      });
    } catch (e) {
      print('Error fetching stays: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la récupération des séjours : $e')),
      );
    }
  }

  void _navigateToPrescriptionView(int stayId) async {
    var now = DateTime.now();
    var nextAvailableTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
    if (now.isBefore(nextAvailableTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous ne pouvez ajouter des prescriptions qu\'après 10:00 AM')),
      );
      return;
    }

    try {
      var result = await PrescriptionAPI.checkPrescription(stayId);
      if (result['exists']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionSummaryView(prescriptionId: result['prescription']),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionView(stayId: stayId),
          ),
        );
      }
    } catch (e) {
      print('Error checking prescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la vérification de la prescription : $e')),
      );
    }
  }

  void _navigateToReviewView(int stayId) async {
    var now = DateTime.now();
    var nextAvailableTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
    if (now.isBefore(nextAvailableTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous ne pouvez ajouter des avis qu\'après 10:00 AM')),
      );
      return;
    }

    try {
      var result = await ReviewAPI.checkTodayReview(stayId);
      if (result['exists']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewSummaryView(review: result['review']),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewView(stayId: stayId),
          ),
        );
      }
    } catch (e) {
      print('Error checking review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la vérification de l\'avis : $e')),
      );
    }
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(dateTime);
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
              'Liste des Séjours',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: stays.isEmpty
                ? const Center(
              child: Text(
                'Aucun séjour trouvé.',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: stays.length,
              itemBuilder: (context, index) {
                var stay = stays[index];
                var now = DateTime.now();
                var nextAvailableTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
                if (now.isAfter(nextAvailableTime)) {
                  nextAvailableTime = nextAvailableTime.add(Duration(days: 1));
                }
                var timeLeft = nextAvailableTime.difference(now);
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xFF481C4B),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(
                      'Séjour de ${stay['user_firstname']} ${stay['user_lastname']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('Raison: ${stay['reason']}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text('Date : ${_formatDate(stay['start_date'])} - ${_formatDate(stay['end_date'])}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 5),
                        TimerCountdown(
                          format: CountDownTimerFormat.hoursMinutesSeconds,
                          endTime: tz.TZDateTime.now(tz.local).add(timeLeft),
                          onEnd: () {
                            setState(() {});
                          },
                          timeTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.note_add, color: Colors.white),
                          onPressed: () => _navigateToReviewView(stay['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.medical_services, color: Colors.white),
                          onPressed: () => _navigateToPrescriptionView(stay['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const AppFooter(isHomeScreen: true),
        ],
      ),
    );
  }
}
