import 'package:flutter/material.dart';
import 'package:soignemoiapplication/src/api/stays_api.dart';

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
      // Optionally show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch stays: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Séjours'),
      ),
      body: stays.isEmpty
          ? Center(child: Text('Aucun séjour trouvé.'))
          : ListView.builder(
        itemCount: stays.length,
        itemBuilder: (context, index) {
          var stay = stays[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                'Séjour #${stay['id']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text('Spécialité: ${stay['specialty_id']}'),
                  SizedBox(height: 3),
                  Text('Raison: ${stay['reason']}'),
                  SizedBox(height: 3),
                  Text('ID du planning: ${stay['schedule_id']}'),
                  SizedBox(height: 5),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Action à effectuer lors du clic sur un séjour
              },
            ),
          );
        },
      ),
    );
  }
}
