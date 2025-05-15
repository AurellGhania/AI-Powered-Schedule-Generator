import 'package:flutter/material.dart';
import 'package:schedule_generator/UI/home_components/task_input.dart';
import 'package:schedule_generator/UI/home_components/task_list.dart';
import 'package:schedule_generator/UI/result_screen.dart';
import 'package:schedule_generator/models/task.dart';
import 'package:schedule_generator/services/gemini_service.dart';
import 'package:schedule_generator/ui/home_components/generated_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final GeminiService geminiService = GeminiService();
  bool isLoading = false;
  String? generatedResult;

  // action penambahan/input task
  void addTask (Task task) {
    setState(() => tasks.add(task));
  }
  // untuk action penghapusan task yang sudah diinput
  void removeTask(int index) {
    setState(() => tasks.removeAt(index));
  }
  // untuk action generate schedule berdasarkan input user
  Future<void> generateSchedule() async {
     setState(() => isLoading = true);
     try {
       final result = await geminiService.generateSchedule(tasks);
        if (!mounted) return;
        generatedResult = result;
        _showSuccessDialog();
        //mounted itu untuk hanlde ghosttouch(bukan dari orng)
     } catch (e) {
       if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate: $e"))
        );
       }
     }
     setState(() => isLoading= false );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: Text("Congrastulation"),
        content: Text("Schedule Generated Successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => ResultScreen(result: generatedResult ?? "There is no task, Please try to generate another task")
                )
              );
            }, 
            child: Text("View Result"),
          )
        ],
      ) 
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = Colors.indigoAccent[100];
    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.bold
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Generator"),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
        
        backgroundColor: Colors.yellow[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container( //untuk task input
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Task Input", 
                  style: sectionTitleStyle,
                  ),
                  SizedBox(height: 12),
                  TaskInputSection(
                    onTaskAdded: addTask
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task List", style: sectionTitleStyle),
                    SizedBox(height: 12),
                    Expanded(
                      child: TaskList(
                        tasks: tasks, 
                        onRemove: removeTask,
                      )
                    ),
                  ],
                ),
              )
            ),
            SizedBox(height: 20),
            GeneratedButton(
              isLoading: isLoading, 
              onPressed: generateSchedule
            )
          ],
        ),
      ),
    );
  }
}