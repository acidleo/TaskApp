import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasklist/providers/task_provider.dart';
import 'package:tasklist/providers/network_provider.dart';
import 'package:tasklist/ui/screens/detailaddedit_screen.dart';
import 'package:tasklist/ui/screens/detail_screen.dart';
import 'package:tasklist/widgets/taskcard_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final taskProvider = context.read<TaskProvider>();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTasksAsPdf(context, taskProvider),
          ),
        ],
      ),
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
            final cachedTasks =
                taskProvider
                    .getCachedTasks()
                    .where((task) => task['userId'] == uid)
                    .toList();

            if (cachedTasks.isEmpty) {
              return const Center(child: Text("No tasks available "));
            }

            // final cachedTasks = taskProvider.getCachedTasks();
            // if (cachedTasks.isEmpty) {
            //   return const Center(child: Text("No tasks available"));
            // }

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

  Future<void> _shareTasksAsPdf(
    BuildContext context,
    TaskProvider taskProvider,
  ) async {
    final tasks = taskProvider.getCachedTasks();
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No tasks to share!")));
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Task List",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              ...tasks.map((task) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Title: ${task['title'] ?? ''}",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Description: ${task['description'] ?? ''}",
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        "Status: ${task['status'] ?? 'Pending'}",
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'task_list.pdf');
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
