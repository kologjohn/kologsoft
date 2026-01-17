import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'companyreg.dart';
import 'customer_registration.dart';

class CustomerListPage extends StatelessWidget {
  CustomerListPage({super.key});
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text("Registered Customers"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF415A77),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerRegistration()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('customers').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No customers registered yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

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
                    /// LOGO PREVIEW
                    const SizedBox(width: 16),

                    /// COMPANY DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                         data['customertype'] == "Credit"
                              ? Text(
                            "Type: ${data['customertype']}\n"
                                "Credit Limit: ${double.tryParse(data['creditlimit']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}\n"
                                "Payment Duration: ${data['paymentduration']}\n"
                                "Contact: ${data['contact']}\n"
                                "Branch: ${data['branchName']}\n",
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          )
                              : Text(
                            "Type: ${data['customertype']}\n"
                                "Contact: ${data['contact']}\n"
                                "Branch: ${data['branchName']}\n",
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),


                        ],
                      ),
                    ),

                    /// EDIT
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerRegistration(
                              docId: doc.id,
                              data: data,
                            ),
                          ),
                        );
                      },
                    ),

                    /// DELETE
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete customer"),
                            content: const Text(
                                "Are you sure you want to delete this customer?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await db
                              .collection('customers')
                              .doc(doc.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("customer deleted")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
