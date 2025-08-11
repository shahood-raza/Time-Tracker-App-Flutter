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
        title: Text(
          'Time Tracker App',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        foregroundColor: Colors.blueAccent,
        backgroundColor: Colors.white,
        elevation: 10,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeEntryScreen()),
          );
        },
        tooltip: 'Add Time',
        child: Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget buildByEntries(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Text(
              'Click the + Button to Add Entries',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white, size: 28),
              ),

              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  title: Text(
                    '${getProjectNameById(context, entry.projectId)}  \nTotal Time: ${entry.totalTime} hrs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      '$formattedDate\nNotes: ${entry.notes}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  isThreeLine: true,

                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.access_time, color: Colors.blueAccent),
                  ),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          );
        }

        var grouped = groupBy(provider.entries, (TimeEntry e) => e.projectId);

        return ListView(
          children: grouped.entries.map((group) {
            String projectId = group.key;
            String projectName = getProjectNameById(context, projectId);

            double totalHours = group.value.fold(
              0.0,
              (double prev, TimeEntry element) => prev + element.totalTime,
            );

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Total Time: ${totalHours.toStringAsFixed(1)} hrs",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Divider(),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: group.value.length,
                      itemBuilder: (context, index) {
                        TimeEntry timeEntry = group.value[index];
                        return ListTile(
                          leading: Icon(
                            Icons.work_outline,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            '${getTaskNameById(context, timeEntry.taskId)} - ${timeEntry.notes}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy').format(timeEntry.date),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
