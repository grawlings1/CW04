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
  String priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.completed = false,
    this.priority = 'Low',
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  int _priorityValue(String priority) {
    switch (priority) {
      case "High":
        return 3;
      case "Medium":
        return 2;
      default:
        return 1;
    }
  }

  void _sortPlans() {
    setState(() {
      plans.sort((a, b) =>
          _priorityValue(b.priority).compareTo(_priorityValue(a.priority)));
    });
  }

  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date, priority: priority));
      _sortPlans();
    });
  }

  void _updatePlan(int index, String name, String description, DateTime date, String priority) {
    setState(() {
      plans[index].name = name;
      plans[index].description = description;
      plans[index].date = date;
      plans[index].priority = priority;
      _sortPlans();
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

  void _updatePlanDate(Plan plan, DateTime newDate) {
    setState(() {
      int index = plans.indexOf(plan);
      if (index != -1) {
        plans[index].date = newDate;
      }
    });
  }

  Future<void> _showCreatePlanDialog() async {
    String name = '';
    String description = '';
    DateTime? selectedDate;
    String selectedPriority = 'Low';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Plan'),
          content: SingleChildScrollView(
            child: Column(
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
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedPriority,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedPriority = newValue;
                      });
                    }
                  },
                  items: <String>['Low', 'Medium', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('Priority: $value'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () { Navigator.of(context).pop(); },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if(name.isNotEmpty && description.isNotEmpty && selectedDate != null) {
                  _addPlan(name, description, selectedDate!, selectedPriority);
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
    String selectedPriority = plans[index].priority;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: SingleChildScrollView(
            child: Column(
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
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedPriority,
                  onChanged: (String? newValue) {
                    if(newValue != null){
                      setState(() {
                        selectedPriority = newValue;
                      });
                    }
                  },
                  items: <String>['Low', 'Medium', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('Priority: $value'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () { Navigator.of(context).pop(); },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                if(name.isNotEmpty && description.isNotEmpty) {
                  _updatePlan(index, name, description, selectedDate, selectedPriority);
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
            subtitle: Text('${plan.description}\n${plan.date.toLocal().toString().split(' ')[0]}\nPriority: ${plan.priority}'),
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
              '${plan.name} (Priority: ${plan.priority})',
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
      body: Column(
        children: [
          Container(
            height: 250,
            child: CalendarWidget(
              onPlanDropped: (plan, date) {
                _updatePlanDate(plan, date);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return _buildPlanItem(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final Function(Plan, DateTime) onPlanDropped;

  CalendarWidget({required this.onPlanDropped});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        DateTime date = DateTime(now.year, now.month, index + 1);
        return DragTarget<Plan>(
          onAccept: (plan) {
            onPlanDropped(plan, date);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text('${date.day}'),
            );
          },
        );
      },
    );
  }
}
