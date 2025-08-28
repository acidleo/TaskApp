// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tasklist/providers/auth_provider.dart';
// import 'package:tasklist/providers/task_provider.dart';
// import 'package:tasklist/ui/screens/list_screen.dart';
// import 'package:tasklist/ui/screens/login_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final taskProvider = Provider.of<TaskProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("HOME SCREEN"),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const CircleAvatar(child: Icon(Icons.person)),
//             onSelected: (value) async {
//               if (value == "logout") {
//                 await authProvider.logout();
//                 if (context.mounted) {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                     (route) => false,
//                   );
//                 }
//               }
//             },
//             itemBuilder:
//                 (context) => const [
//                   PopupMenuItem(value: "logout", child: Text("Log Out")),
//                 ],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: StreamBuilder<Map<String, int>>(
//           stream: taskProvider.getTaskCounts(),
//           builder: (context, snapshot) {
//             final counts =
//                 snapshot.data ?? {"total": 0, "completed": 0, "pending": 0};

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Total Tasks Card
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 3,
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         const Text(
//                           "Total Tasks",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "${counts['total']}",
//                           style: const TextStyle(
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Completed & Pending Tasks Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Card(
//                         color: Colors.green.shade100,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             children: [
//                               const Text(
//                                 "Completed",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 "${counts['completed']}",
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Card(
//                         color: Colors.red.shade100,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             children: [
//                               const Text(
//                                 "Pending",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 "${counts['pending']}",
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),

//                 // Navigate Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ListScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Task List",
//                       style: TextStyle(fontSize: 16, color: Colors.blue),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/providers/auth_provider.dart';
import 'package:tasklist/providers/task_provider.dart';
import 'package:tasklist/providers/network_provider.dart';
import 'package:tasklist/ui/screens/list_screen.dart';
import 'package:tasklist/ui/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("HOME SCREEN"),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            onSelected: (value) async {
              if (value == "logout") {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: "logout", child: Text("Log Out")),
                ],
          ),
        ],
      ),
      body: Consumer<NetworkProvider>(
        builder: (context, network, _) {
          final isOnline = network.isOnline;

          if (isOnline) {
            // Online mode: use Firestore stream
            return StreamBuilder<Map<String, int>>(
              stream: taskProvider.getTaskCounts(),
              builder: (context, snapshot) {
                final counts =
                    snapshot.data ?? {"total": 0, "completed": 0, "pending": 0};

                return _buildHomeContent(context, counts);
              },
            );
          } else {
            // Offline mode: use cached tasks
            final cachedTasks = taskProvider.getCachedTasks();
            final total = cachedTasks.length;
            final completed =
                cachedTasks
                    .where(
                      (t) => (t['status'] ?? '').toLowerCase() == 'completed',
                    )
                    .length;
            final pending = total - completed;

            final counts = {
              "total": total,
              "completed": completed,
              "pending": pending,
            };

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade200,
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    "Offline mode: showing cached data",
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: _buildHomeContent(context, counts)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, Map<String, int> counts) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Tasks Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Total Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${counts['total']}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Completed & Pending Row
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${counts['completed']}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.red.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Pending",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${counts['pending']}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Navigate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListScreen()),
                  ),
              child: const Text(
                "Task List",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
