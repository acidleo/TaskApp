import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
    "taskdetails",
  );

  // Offline cache
  List<Map<String, dynamic>> cachedTasks = [];

  /// Get all tasks for the current logged-in user and update cache
  Stream<List<Map<String, dynamic>>> getAllTasks() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return tasks
        .where("userId", isEqualTo: uid)
        // .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          // print("hai");
          // print(snapshot.docs);
          final taskList =
              snapshot.docs
                  .map(
                    (doc) => {
                      "id": doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    },
                  )
                  .toList();

          cachedTasks = taskList; // update offline cache
          return taskList;
        });
  }

  /// Get cached tasks (offline mode)
  List<Map<String, dynamic>> getCachedTasks() {
    return cachedTasks;
  }

  /// Fetch a single task by ID
  Stream<DocumentSnapshot> getTaskById(String id) {
    return tasks.doc(id).snapshots();
  }

  /// Add a new task for current user
  Future<void> addTask(String title, String description, String status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await tasks.add({
      "title": title,
      "description": description,
      "status": status,
      "createdAt": DateTime.now(),
      "userId": uid, // associate task with current user
    });

    notifyListeners();
  }

  /// Update task (only if owned by current user)
  Future<void> updateTask(
    String id,
    String title,
    String description,
    String status,
  ) async {
    final doc = await tasks.doc(id).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data["userId"] != _auth.currentUser?.uid) {
      throw Exception("Cannot update another user's task");
    }

    await tasks.doc(id).update({
      "title": title,
      "description": description,
      "status": status,
    });

    notifyListeners();
  }

  /// Task counts for dashboard
  Stream<Map<String, int>> getTaskCounts() {
    return getAllTasks().map((taskList) {
      final total = taskList.length;
      final completed =
          taskList
              .where((t) => (t['status'] ?? "").toLowerCase() == "completed")
              .length;
      final pending = total - completed;

      return {"total": total, "completed": completed, "pending": pending};
    });
  }
}
