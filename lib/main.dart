import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:schedule_generator/ui/home_screen.dart';

Future<void> main () async {
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  runApp(ScheduleGenerator());
}



//ini stl
class ScheduleGenerator extends StatelessWidget {
  const ScheduleGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schedule Generator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        //use material itu
        useMaterial3: true
      ),

      home: HomeScreen(),

    );
  }
}