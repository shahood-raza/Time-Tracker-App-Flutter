import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../screens/time_entry_screen.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('Time Tracker App'),
        foregroundColor: Colors.blueAccent,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.grey,
          unselectedLabelColor: Colors.blueAccent,
          tabs: [
            Tab(text: 'All Entries'),
            Tab(text: 'Grouped By Projects'),
          ],
        ),
      ),
      //for side drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white60, fontSize: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.folder, color: Colors.blueAccent),
              title: Text('Projects'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_projects');
              },
            ),
            ListTile(
              leading: Icon(Icons.task_sharp, color: Colors.blueAccent),
              title: Text('Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_tasks');
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildByEntries(context), buildByGroupedProjects(context)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeEntryScreen()),
          );
        },
        tooltip: 'Add Time',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildByEntries(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Text(
              ' Click the + Button to Add Entries',
              style: TextStyle(color: Colors.grey[600], fontSize: 20),
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.entries[index];
            String formattedDate = DateFormat(
              'MMM dd, yyyy',
            ).format(entry.date);

            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.deleteEntry(entry.id);
              },
              background: Container(
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: Colors.blueAccent,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ListTile(
                  title: Text(
                    '${getProjectNameById(context, entry.projectId)} - ${entry.totalTime} hrs',
                  ),
                  subtitle: Text('$formattedDate - Notes: ${entry.notes}'),
                  isThreeLine: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildByGroupedProjects(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Text(
              'Click the + button to Add Entries.',
              style: TextStyle(color: Colors.grey[600], fontSize: 20),
            ),
          );
        }

        var grouped = groupBy(provider.entries, (TimeEntry e) => e.projectId);
        return ListView(
          children: grouped.entries.map((entry) {
            String projectName = getProjectNameById(context, entry.key);
            double totalHours = entry.value.fold(
              0.0,
              (double prev, TimeEntry element) => prev + element.totalTime,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "$projectName \nTotal Time: ${totalHours.toStringAsFixed(1)} hrs",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // to disable scrollingwith in inner list view
                  shrinkWrap:
                      true, // necessary to integrate a listview within other listview

                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    TimeEntry timeEntry = entry.value[index];
                    return ListTile(
                      leading: Icon(Icons.mobile_screen_share_outlined),
                      title: Text('${getTaskNameById(context, timeEntry.taskId)} - ${timeEntry.notes}'),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(timeEntry.date),
                      ),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  String getProjectNameById(BuildContext context, String projectId) {
    var project = Provider.of<TimeEntryProvider>(context, listen: false)
        .projects
        .firstWhere(
          (proj) => proj.id == projectId,
          orElse: () => Project(id: 'Unknown', name: 'Unknown'),
        );
    return project.name;
  }

  String getTaskNameById(BuildContext context, String taskId) {
    var task = Provider.of<TimeEntryProvider>(context, listen: false).tasks
        .firstWhere(
          (tk) => tk.id == taskId,
          orElse: () => Task(id: 'Unknown', name: 'Unknown'),
        );
    return task.name;
  }
}
