import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tasklist/providers/task_provider.dart';
import 'package:tasklist/ui/screens/detailaddedit_screen.dart';

class DetailScreen extends StatelessWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Overview"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: taskProvider.getTaskById(id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Task not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isCompleted =
              (data["status"] ?? "").toLowerCase() == "completed";
          final createdAt = (data["createdAt"] as Timestamp).toDate();

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: screenHeight * 0.8,
                  width: double.infinity,
                  color: const Color.fromARGB(255, 190, 193, 196),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 22,
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Task ID: ${id.substring(0, 5)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    height: 16,
                                    width: 1,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Created Date: ${DateFormat('dd MMM yyyy').format(createdAt)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                data["title"] ?? "",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  data["description"] ?? "",
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isCompleted
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  data["status"] ?? "Pending",
                                  style: TextStyle(
                                    color:
                                        isCompleted
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailaddeditScreen(
                                      id: id,
                                      title: data["title"],
                                      description: data["description"],
                                      status: data["status"],
                                    ),
                              ),
                            );
                          },
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.edit),
                          mini: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
