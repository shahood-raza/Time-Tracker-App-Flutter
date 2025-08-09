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
      appBar: AppBar(title: Text('Manage Projects')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return ListTile(
                title: Text(project.name),
                trailing: IconButton(
                  onPressed: () {
                    provider.deleteProject(project.id);
                  },
                  icon: Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add project',
        onPressed: () async {
          final projectName = await showDialog<String>(
            context: context,
            builder: (context) => AddProjectDialog(),
          );
          if(projectName != null && projectName.isNotEmpty){
            final project = Project(id: DateTime.now().millisecondsSinceEpoch.toString(), name: projectName);
            Provider.of<TimeEntryProvider>(context, listen: false).addProject(project);
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
