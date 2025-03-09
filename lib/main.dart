import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool completed;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.completed = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
    });
  }

  void _updatePlan(int index, String name, String description, DateTime date) {
    setState(() {
      plans[index].name = name;
      plans[index].description = description;
      plans[index].date = date;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _markPlanCompleted(int index) {
    setState(() {
      plans[index].completed = true;
    });
  }

  Future<void> _showCreatePlanDialog() async {
    String name = '';
    String description = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(selectedDate == null
                    ? 'Select Date'
                    : selectedDate!.toLocal().toString().split(' ')[0]),
                onPressed: () async {
                  DateTime now = DateTime.now();
                  final datePicked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (datePicked != null) {
                    setState(() {
                      selectedDate = datePicked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () { Navigator.of(context).pop(); },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (name.isNotEmpty &&
                    description.isNotEmpty &&
                    selectedDate != null) {
                  _addPlan(name, description, selectedDate!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      }
    );
  }

  Future<void> _showEditPlanDialog(int index) async {
    String name = plans[index].name;
    String description = plans[index].description;
    DateTime selectedDate = plans[index].date;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: description),
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(selectedDate.toLocal().toString().split(' ')[0]),
                onPressed: () async {
                  DateTime now = DateTime.now();
                  final datePicked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (datePicked != null) {
                    setState(() {
                      selectedDate = datePicked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () { Navigator.of(context).pop(); },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty) {
                  _updatePlan(index, name, description, selectedDate);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildPlanItem(int index) {
    final plan = plans[index];
    return GestureDetector(
      onLongPress: () {
        _showEditPlanDialog(index);
      },
      onDoubleTap: () {
        _deletePlan(index);
      },
      child: Draggable<Plan>(
        data: plan,
        feedback: Material(
          child: ListTile(
            title: Text(plan.name),
            subtitle: Text('${plan.description}\n${plan.date.toLocal().toString().split(' ')[0]}'),
          ),
        ),
        child: Dismissible(
          key: Key(plan.name + plan.date.toString()),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            _markPlanCompleted(index);
            return false;
          },
          child: ListTile(
            title: Text(
              plan.name,
              style: TextStyle(
                  decoration: plan.completed ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text('${plan.description}\n${plan.date.toLocal().toString().split(' ')[0]}'),
            trailing: Icon(
              plan.completed ? Icons.check_circle : Icons.circle,
              color: plan.completed ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Manager'),
      ),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return _buildPlanItem(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
