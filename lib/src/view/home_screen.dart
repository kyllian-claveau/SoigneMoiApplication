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
        SnackBar(content: Text('Failed to fetch stays: $e')),
      );
    }
  }

  void _navigateToPrescriptionView(int stayId) async {
    var now = DateTime.now();
    var nextAvailableTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
    if (now.isBefore(nextAvailableTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add prescriptions after 10:00 AM')),
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
        SnackBar(content: Text('Failed to check prescription: $e')),
      );
    }
  }

  void _navigateToReviewView(int stayId) async {
    var now = DateTime.now();
    var nextAvailableTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
    if (now.isBefore(nextAvailableTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add reviews after 10:00 AM')),
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
        SnackBar(content: Text('Failed to check review: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Séjours'),
        backgroundColor: Colors.teal,
      ),
      body: stays.isEmpty
          ? const Center(child: Text('Aucun séjour trouvé.', style: TextStyle(fontSize: 18)))
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
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: Text(
                'Séjour de ${stay['user_firstname']} ${stay['user_lastname']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Spécialité: ${stay['specialty_id']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('Raison: ${stay['reason']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('Date de début: ${_formatDate(stay['start_date'])}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text('Date de fin: ${_formatDate(stay['end_date'])}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  TimerCountdown(
                    format: CountDownTimerFormat.hoursMinutesSeconds,
                    endTime: tz.TZDateTime.now(tz.local).add(timeLeft),
                    onEnd: () {
                      setState(() {});
                    },
                    timeTextStyle: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.note_add),
                    onPressed: () => _navigateToReviewView(stay['id']),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () => _navigateToPrescriptionView(stay['id']),
            ),
          );
        },
      ),
    );
  }
}
