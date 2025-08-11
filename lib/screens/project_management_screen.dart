import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/time_entry_provider.dart';
import '../dialogs/add_project_dialog.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Projects',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            if (provider.projects.isEmpty) {
              // ✅ Empty state message
              return const Center(
                child: Text(
                  'No projects added yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Text(
                        project.name.isNotEmpty
                            ? project.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        provider.deleteProject(project.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
         backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white, width: 3),
        ),
        tooltip: 'Add project',
        onPressed: () async {
          final projectName = await showDialog<String>(
            context: context,
            builder: (context) => AddProjectDialog(),
          );
          if(projectName != null && projectName.isNotEmpty){
            final project = Project(id: DateTime.now().millisecondsSinceEpoch.toString(), name: projectName);
            Provider.of<TimeEntryProvider>(context, listen: false).addProject(project);
          }
        },
        child: Icon(Icons.add, size: 30,),
      ),
    );
  }
}
