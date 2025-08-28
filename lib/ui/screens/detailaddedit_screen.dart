import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/providers/task_provider.dart';

class DetailaddeditScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final String? description;
  final String? status;

  const DetailaddeditScreen({
    super.key,
    this.id,
    this.title,
    this.description,
    this.status,
  });

  @override
  State<DetailaddeditScreen> createState() => _DetailaddeditScreenState();
}

class _DetailaddeditScreenState extends State<DetailaddeditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _status = "Pending";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.description ?? "",
    );
    _status = widget.status ?? "Pending";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();

    try {
      // Queue the Firestore write (offline-safe)
      if (widget.id == null) {
        taskProvider.addTask(
          _titleController.text,
          _descriptionController.text,
          _status,
        );
      } else {
        taskProvider.updateTask(
          widget.id!,
          _titleController.text,
          _descriptionController.text,
          _status,
        );
      }

      // Show feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.id == null
                ? "Task added successfully!"
                : "Task updated successfully!",
          ),
        ),
      );

      // Navigate back immediately (offline-friendly)
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? "Add Task" : "Edit Task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? "Enter task title" : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator:
                    (value) => value!.isEmpty ? "Enter task description" : null,
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),
                  DropdownMenuItem(
                    value: "Completed",
                    child: Text("Completed"),
                  ),
                ],
                onChanged: (value) => setState(() => _status = value!),
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text("Save Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
