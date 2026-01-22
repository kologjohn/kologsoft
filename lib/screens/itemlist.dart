import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'itemreg.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    //bool isWideScreen = constraints.maxWidth > 500;
    final screenwidth =MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text("Registered Items"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF415A77),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemRegPage()),
          );
        },
      ),
      /// ITEMS STREAM
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color(0xFF22304A),
                  hintText: 'Search  ...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: searchQuery.isNotEmpty ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        ) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),

          /// LIST VIEW
          Expanded(
            child:

            StreamBuilder<QuerySnapshot>(
              stream: db.collection('itemsreg').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items registered yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;

                // Filter documents based on search query - search all fields
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Search through all fields in the document
                  return data.values.any((value) {
                    if (value == null) return false;
                    return value.toString().toLowerCase().contains(searchQuery);
                  });
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? "No items registered yet"
                          : "No items found matching '$searchQuery'",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Extract modes data
              final modesMap = data['modes'] as Map<String, dynamic>? ?? {};
              final singleMode = modesMap['single'] as Map<String, dynamic>? ?? {};
              final cartonMode = modesMap['carton'] as Map<String, dynamic>? ?? {};

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
                    /// ITEM NUMBER
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF415A77),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// ITEM DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// NAME
                          Text(
                            (data['name'] ?? '').toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),
                          /// BASIC INFO
                          Text(
                            "Barcode: ${data['barcode'] ?? ''}\n"
                             "Cost Price: ${data['cp'] ?? ''}",
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 6),
                          /// SINGLE MODE INFO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: modesMap.entries.map((entry) {
                              final modeData = entry.value as Map<String, dynamic>;
                              final modeName = modeData['name'] ?? entry.key;
                              final qty = modeData['qty'] ?? '';
                              final rp = modeData['rp'] ?? '';
                              final wp = modeData['wp'] ?? '';
                              final sp = modeData['sp'] ?? '';

                              return Text(
                                "$modeName  Qty: $qty | RPrice: $rp  | WPrice: $wp |  SPrice: $sp",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          /// EXTRA INFO
                          Text(
                            "Product Type: ${data['producttype'] ?? ''}\n"
                            "Category: ${data['pcategory'] ?? ''}\n"
                            "Company: ${data['company'] ?? ''}\n"
                            "Box Pricing: ${data['modemore'] == true ? 'Enabled' : 'Disabled'}",
                            style: const TextStyle(
                              color: Colors.white38,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// EDIT BUTTON
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemRegPage(
                              docId: doc.id,
                              data: data,
                            ),
                          ),
                        );
                      },
                    ),

                    /// DELETE BUTTON
                    IconButton(
                      icon: const Icon(Icons.delete,
                      color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Item"),
                            content: const Text(
                              "Are you sure you want to delete this item?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await db.collection('itemsreg').doc(doc.id).delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Item deleted successfully"),
                              ),
                            );
                          }
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
          ),
        ],
      ),
    );
  }
}
