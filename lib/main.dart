import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:time_tracker/screens/home_screen.dart';
import 'package:time_tracker/screens/project_management_screen.dart';
import 'package:time_tracker/screens/task_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(MyApp(localStorage:localStorage));
}

class MyApp extends StatelessWidget{
  final LocalStorage localStorage ;
  const MyApp({super.key , required this.localStorage});
  
  @override
  Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=> TimeEntryProvider(localStorage))
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Time Tracker App',
          initialRoute: '/',
          routes: {
            '/':(context) => HomeScreen(),
            '/manage_projects':(context)=> ProjectManagementScreen(),
            '/manage_tasks': (context)=> TaskManagementScreen()
          },
        ),
      );
  }
}