
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kologsoft/screens/stocking_mode.dart';

class StockingModeListPage extends StatefulWidget {
  @override
  _StockingModeListPageState createState() => _StockingModeListPageState();
}

class _StockingModeListPageState extends State<StockingModeListPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> _getWorkspaces() async {
    QuerySnapshot snapshot = await db.collection('stockingmode').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Stocking Mode"),
        backgroundColor: const Color(0xFF1B263B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // refresh
          )
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _getWorkspaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
                child: Text("No stocking mode registered yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 16)));

          final docs = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  String createdAtStr = "";
                  if (data['date'] != null && data['date'] is Timestamp) {
                    DateTime dt = (data['date'] as Timestamp).toDate();
                    createdAtStr =
                    "${dt.weekdayName()} ${dt.day} ${dt.monthName()} ${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B263B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Staff: ${data['staff'] ?? ''}\nDate: $createdAtStr",
                                  style: const TextStyle(
                                      color: Colors.white70, height: 1.4),
                                ),
                              ]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StockingMode(
                                  docId: doc.id,
                                  data: data,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Workspace"),
                                content: const Text(
                                    "Are you sure you want to delete this workspace?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel")),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete")),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await db.collection('workspaceclass').doc(doc.id).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Workspace deleted")));
                              setState(() {}); // refresh after delete
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

extension DateTimeExt on DateTime {
  String weekdayName() {
    const weekdays = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
    ];
    return weekdays[this.weekday-1];
  }
  String monthName() {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return months[this.month-1];
  }
}
