import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(EcoHabitTrackerApp());
}

class EcoHabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHabit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HabitTrackerScreen(),
    );
  }
}

class Habit {
  String title;
  String frequency;
  int streak;
  int completions;

  Habit({required this.title, required this.frequency, this.streak = 0, this.completions = 0});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'frequency': frequency,
      'streak': streak,
      'completions': completions,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      title: map['title'],
      frequency: map['frequency'],
      streak: map['streak'],
      completions: map['completions'],
    );
  }
}

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  List<Habit> habits = [];
  List<String> motivationalQuotes = [
    "Small steps make a big difference!",
    "Your planet is proud of you!",
    "Eco-warrior in action!",
    "One habit at a time!",
    "Consistency is key!",
  ];

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? habitStrings = prefs.getStringList('habits');
    if (habitStrings != null) {
      setState(() {
        habits = habitStrings
            .map((habit) => Habit.fromMap(Map<String, dynamic>.from(Uri.splitQueryString(habit))))
            .toList();
      });
    }
  }

  Future<void> saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> habitStrings = habits
        .map((habit) => Uri(queryParameters: habit.toMap().map((key, value) => MapEntry(key, value.toString()))).query)
        .toList();
    await prefs.setStringList('habits', habitStrings);
  }

  void addHabit(String title, String frequency) {
    setState(() {
      habits.add(Habit(title: title, frequency: frequency));
    });
    saveHabits();
  }

  void completeHabit(int index) {
    setState(() {
      habits[index].streak++;
      habits[index].completions++;
    });
    saveHabits();
    showMotivationalQuote();
  }

  void showMotivationalQuote() {
    final random = Random();
    final quote = motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(quote),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showAddHabitDialog() {
    String title = '';
    String frequency = 'Daily';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Eco Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Habit Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              DropdownButton<String>(
                value: frequency,
                onChanged: (value) {
                  setState(() {
                    frequency = value!;
                  });
                },
                items: ['Daily', 'Weekly']
                    .map((f) => DropdownMenuItem(
                  child: Text(f),
                  value: f,
                ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  addHabit(title, frequency);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> getBarChartData() {
    return habits.asMap().entries.map((entry) {
      int index = entry.key;
      Habit habit = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: habit.streak.toDouble(),
            color: Colors.green,
            width: 15,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoHabit Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                Habit habit = habits[index];
                return ListTile(
                  title: Text(habit.title),
                  subtitle: Text('Frequency: ${habit.frequency}\nStreak: ${habit.streak}'),
                  trailing: IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => completeHabit(index),
                  ),
                );
              },
            ),
          ),
          if (habits.isNotEmpty)
            Container(
              height: 200,
              padding: EdgeInsets.all(8),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(habits[value.toInt()].title.length > 4
                              ? habits[value.toInt()].title.substring(0, 4)
                              : habits[value.toInt()].title);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: getBarChartData(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddHabitDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
