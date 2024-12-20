import 'package:flutter/material.dart';
import 'database_helper.dart';

class PlannerPage extends StatefulWidget {
  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, 
        title: Text(
          "Planlayıcı",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Günlük"),
            Tab(text: "Haftalık"),
            Tab(text: "Aylık"),
            Tab(text: "Yıllık"),
          ],
          indicatorColor: Colors.amber, 
          labelColor: Colors.amber, 
          unselectedLabelColor: Colors.white70, 
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyPlanPage(),
          WeeklyPlanPage(),
          MonthlyPlanPage(),
          YearlyPlanPage(),
        ],
      ),
    );
  }
}


class DailyPlanPage extends StatefulWidget {
  @override
  _DailyPlanPageState createState() => _DailyPlanPageState();
}

class _DailyPlanPageState extends State<DailyPlanPage> {
  final Map<String, String> planData = {};

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  _addPlan(BuildContext context) async {
    TimeOfDay? selectedTime = await _selectTime(context);

    if (selectedTime != null) {
      String formattedTime = "${selectedTime.format(context)}";
      TextEditingController planController = TextEditingController();
      String? result = await showDialog<String>(context: context, builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: planController,
                decoration: InputDecoration(hintText: "Planınızı buraya yazın"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Vazgeç"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, planController.text);
              },
              child: Text("Kaydet"),
            ),
          ],
        );
      });

      if (result != null && result.isNotEmpty) {
        await _saveDailyPlan("Günlük Plan", result, formattedTime);
        setState(() {
          planData[formattedTime] = result;
        });
      }
    }
  }

  _saveDailyPlan(String title, String content, String time) async {
    final plan = {
      'title': title,
      'content': content,
      'date': DateTime.now().toString(),
      'time': time,
      'type': 0,
    };

    await DatabaseHelper().insertPlan(plan);
  }

  Future<List<Map<String, dynamic>>> _getDailyPlans() async {
    return await DatabaseHelper().getPlansByType(0);
  }

  _deletePlan(int planId) async {
    await DatabaseHelper().deletePlan(planId);
    setState(() {});
  }

  _editPlan(BuildContext context, int planId, String currentContent) async {
    TextEditingController planController = TextEditingController(text: currentContent);

    String? updatedContent = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Yeni planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (updatedContent != null && updatedContent.isNotEmpty) {
      await DatabaseHelper().updatePlan({
        'id': planId,
        'title': 'Günlük Plan',
        'content': updatedContent,
        'date': DateTime.now().toString(),
        'time': '',
        'type': 0,
      });
      setState(() {});
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: SizedBox(),
      actions: [],
      title: SizedBox(),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _getDailyPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Hiç plan eklenmedi"));
        }

        List<Map<String, dynamic>> plans = snapshot.data!;

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            var plan = plans[index];
            return ListTile(
              title: Text(plan['title']),
              subtitle: Text(plan['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPlan(context, plan['id'], plan['content']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePlan(plan['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addPlan(context),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 83, 173, 247),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}


}

class WeeklyPlanPage extends StatefulWidget {
  @override
  _WeeklyPlanPageState createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  final List<String> daysOfWeek = [
     "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi","Pazar",
  ];

  Future<List<Map<String, dynamic>>> _getWeeklyPlans() async {
    return await DatabaseHelper().getPlansByType(1);
  }

  _deletePlan(int planId) async {
    await DatabaseHelper().deletePlan(planId);
    setState(() {});
  }

  _editPlan(BuildContext context, int planId, String currentContent) async {
    TextEditingController planController = TextEditingController(text: currentContent);

    String? updatedContent = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Yeni planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (updatedContent != null && updatedContent.isNotEmpty) {
      await DatabaseHelper().updatePlan({
        'id': planId,
        'title': 'Haftalık Plan', 
        'content': updatedContent,
        'date': DateTime.now().toString(),
        'time': '',
        'type': 1,
      });
      setState(() {});
    }
  }

  _addPlan(BuildContext context) async {
    TextEditingController planController = TextEditingController();
    String? result = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Yeni Haftalık Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (result != null && result.isNotEmpty) {
      await _saveWeeklyPlan("Haftalık Plan", result);
      setState(() {}); 
    }
  }
  _saveWeeklyPlan(String title, String content) async {
    final plan = {
      'title': title,
      'content': content,
      'date': DateTime.now().toString(),
      'time': '', 
      'type': 1,  
    };

    await DatabaseHelper().insertPlan(plan);
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: SizedBox(),
      actions: [],
      title: SizedBox(),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _getWeeklyPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Hiç plan eklenmedi"));
        }

        List<Map<String, dynamic>> plans = snapshot.data!;

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            var plan = plans[index];
            return ListTile(
              title: Text(plan['title']),
              subtitle: Text(plan['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPlan(context, plan['id'], plan['content']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePlan(plan['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addPlan(context),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 83, 173, 247),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

}
class MonthlyPlanPage extends StatefulWidget {
  @override
  _MonthlyPlanPageState createState() => _MonthlyPlanPageState();
}

class _MonthlyPlanPageState extends State<MonthlyPlanPage> {
  Future<List<Map<String, dynamic>>> _getMonthlyPlans() async {
    return await DatabaseHelper().getPlansByType(2);
  }

  _deletePlan(int planId) async {
    await DatabaseHelper().deletePlan(planId);
    setState(() {});
  }

  _editPlan(BuildContext context, int planId, String currentContent) async {
    TextEditingController planController = TextEditingController(text: currentContent);

    String? updatedContent = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Yeni planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (updatedContent != null && updatedContent.isNotEmpty) {
      await DatabaseHelper().updatePlan({
        'id': planId,
        'title': 'Aylık Plan',
        'content': updatedContent,
        'date': DateTime.now().toString(),
        'time': '',
        'type': 2,
      });
      setState(() {});
    }
  }

  _addPlan(BuildContext context) async {
    TextEditingController planController = TextEditingController();
    String? result = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Yeni Aylık Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (result != null && result.isNotEmpty) {
      await _saveMonthlyPlan("Aylık Plan", result);
      setState(() {});
    }
  }

  _saveMonthlyPlan(String title, String content) async {
    final plan = {
      'title': title,
      'content': content,
      'date': DateTime.now().toString(),
      'time': '',
      'type': 2,
    };

    await DatabaseHelper().insertPlan(plan);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: SizedBox(),
      actions: [],
      title: SizedBox(),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _getMonthlyPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Hiç plan eklenmedi"));
        }

        List<Map<String, dynamic>> plans = snapshot.data!;

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            var plan = plans[index];
            return ListTile(
              title: Text(plan['title']),
              subtitle: Text(plan['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPlan(context, plan['id'], plan['content']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePlan(plan['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addPlan(context),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 83, 173, 247),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

}
class YearlyPlanPage extends StatefulWidget {
  @override
  _YearlyPlanPageState createState() => _YearlyPlanPageState();
}

class _YearlyPlanPageState extends State<YearlyPlanPage> {
  Future<List<Map<String, dynamic>>> _getYearlyPlans() async {
    return await DatabaseHelper().getPlansByType(3);
  }

  _deletePlan(int planId) async {
    await DatabaseHelper().deletePlan(planId);
    setState(() {});
  }

  _editPlan(BuildContext context, int planId, String currentContent) async {
    TextEditingController planController = TextEditingController(text: currentContent);

    String? updatedContent = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Yeni planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (updatedContent != null && updatedContent.isNotEmpty) {
      await DatabaseHelper().updatePlan({
        'id': planId,
        'title': 'Yıllık Plan', 
        'content': updatedContent,
        'date': DateTime.now().toString(),
        'time': '',
        'type': 3,
      });
      setState(() {});
    }
  }

  _addPlan(BuildContext context) async {
    TextEditingController planController = TextEditingController();
    String? result = await showDialog<String>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Yeni Yıllık Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planController,
              decoration: InputDecoration(hintText: "Planınızı buraya yazın"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, planController.text);
            },
            child: Text("Kaydet"),
          ),
        ],
      );
    });

    if (result != null && result.isNotEmpty) {
      await _saveYearlyPlan("Yıllık Plan", result);
      setState(() {});
    }
  }

  _saveYearlyPlan(String title, String content) async {
    final plan = {
      'title': title,
      'content': content,
      'date': DateTime.now().toString(),
      'time': '',
      'type': 3,
    };

    await DatabaseHelper().insertPlan(plan);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: SizedBox(),
      actions: [],
      title: SizedBox(),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _getYearlyPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Hiç plan eklenmedi"));
        }

        List<Map<String, dynamic>> plans = snapshot.data!;

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            var plan = plans[index];
            return ListTile(
              title: Text(plan['title']),
              subtitle: Text(plan['content']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPlan(context, plan['id'], plan['content']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePlan(plan['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addPlan(context),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 83, 173, 247),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

}
