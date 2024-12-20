import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'login_page.dart';
import 'notes_page.dart';
import 'planner_page.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notlar ve Planlar',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: const Color.fromARGB(255, 0, 1, 1)),
        ),
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: _isLoggedIn(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

    //  if (snapshot.hasData && !snapshot.data!) {
    //     return LoginPage(); }

      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Notlar & Planlar",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 229, 75, 75),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: NoteAndPlanSearch(),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Kullanıcı Adı"),
                accountEmail: Text("email@example.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 237, 227, 211),
                  child: Icon(Icons.person, size: 40),
                ),
              ),
              ListTile(
                title: Text("Notlar"),
                leading: Icon(Icons.note),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotesPage()),
                  );
                },
              ),
              ListTile(
                title: Text("Planlar"),
                leading: Icon(Icons.calendar_today),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlannerPage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text("Ayarlar"),
                leading: Icon(Icons.settings),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            "Ana Sayfa",
            style: TextStyle(fontSize: 24),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateDialog(context);
          },
          child: Icon(
            Icons.add_sharp,
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 229, 75, 75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    },
  );
}

}

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ne yapmak istersiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
              child: Text('Not Al'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PlannerPage()),
                );
              },
              child: Text('Plan Yap'),
            ),
          ],
        );
      },
    );
  }

class NoteAndPlanSearch extends SearchDelegate<String> {
  final List<String> notes = ["Not 1", "Not 2", "Önemli Not", "Flutter Planı"];
  final List<String> plans = ["Plan 1", "Yaz Tatili", "Ödev Planı", "Flutter Projesi"];

  @override
  String? get searchFieldLabel => "Notlar ve Planlar Ara...";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> filteredNotes = notes
        .where((note) => note.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final List<String> filteredPlans = plans
        .where((plan) => plan.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final List<String> results = []..addAll(filteredNotes)..addAll(filteredPlans);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]),
          onTap: () {
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> filteredNotes = notes
        .where((note) => note.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final List<String> filteredPlans = plans
        .where((plan) => plan.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final List<String> suggestions = []..addAll(filteredNotes)..addAll(filteredPlans);

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
