import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasklist/providers/task_provider.dart';
import 'package:tasklist/providers/network_provider.dart';
import 'package:tasklist/ui/screens/detailaddedit_screen.dart';
import 'package:tasklist/ui/screens/detail_screen.dart';
import 'package:tasklist/widgets/taskcard_widget.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final taskProvider = context.read<TaskProvider>();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Task List"), centerTitle: true),
      body: Consumer<NetworkProvider>(
        builder: (context, network, _) {
          final isOnline = network.isOnline;

          // return StreamBuilder<List<Map<String, dynamic>>>(
          //   stream: taskProvider.getAllTasks(),
          //   builder: (context, snapshot) {
          //     // print(ConnectionState);
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(child: CircularProgressIndicator());
          //     }

          //     // final tasks = snapshot.data ?? [];

          //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //       return const Center(child: Text("No tasks available"));
          //     }

          //     final tasks = snapshot.data ?? [];

          //     return _buildTaskList(context, tasks);
          //   },
          // );

          if (isOnline) {
            // Online mode: Firestore stream
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: taskProvider.getAllTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks available"));
                }

                return _buildTaskList(context, tasks);
              },
            );
          } else {
            // Offline mode: show cached tasks filtered by userId
            final cachedTasks = taskProvider.getCachedTasks();
            if (cachedTasks.isEmpty) {
              return const Center(child: Text("No tasks available"));
            }

            return _buildTaskList(context, cachedTasks);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DetailaddeditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    // print(tasks);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final data = tasks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(id: data["id"])),
            );
          },
          child: TaskcardWidget(
            id: data["id"],
            title: data["title"] ?? "",
            description: data["description"] ?? "",
            status: data["status"] ?? "Pending",
          ),
        );
      },
    );
  }
}
