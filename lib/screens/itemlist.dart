import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'itemreg.dart';

class ItemListPage extends StatelessWidget {
  ItemListPage({super.key});

  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text("Registered Items"),
      ),

      /// ADD NEW ITEM
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
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('items').orderBy('name').snapshots(),
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

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final retailMarkup = (data['retailmarkup'] ?? '').toString();
              final wholesaleMarkup = (data['wholesalemarkup'] ?? '').toString();

              final bool retailActive =
                  retailMarkup.isNotEmpty && wholesaleMarkup.isEmpty;

              final bool wholesaleActive = !retailActive;

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
                    /// ITEM ICON
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF22304A),
                      child: Icon(Icons.inventory, color: Colors.white70),
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
                                "Cost Price: ${data['costprice'] ?? ''}",
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// RETAIL INFO
                          Text(
                            "Retail Markup: ${data['retailmarkup'] ?? ''}  →  "
                                "Retail Price: ${data['retailprice'] ?? ''}",
                            style: TextStyle(
                              color: retailActive
                                  ? Colors.white70
                                  : Colors.white38,
                              height: 1.4,
                            ),
                          ),

                          /// WHOLESALE INFO
                          Text(
                            "Wholesale Markup: ${data['wholesalemarkup'] ?? ''}  →  "
                                "Wholesale Price: ${data['wholesaleprice'] ?? ''}",
                            style: TextStyle(
                              color: wholesaleActive
                                  ? Colors.white70
                                  : Colors.white38,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// EXTRA INFO
                          Text(
                            "Opening Stock: ${data['openingstock'] ?? ''}\n"
                                "Product Type: ${data['producttype'] ?? ''}\n"
                                "Pricing Mode: ${data['pricingmode'] ?? ''}\n"
                                "Category: ${data['productcategory'] ?? ''}\n"
                                "Warehouse: ${data['warehouse'] ?? ''}\n"
                                "Company: ${data['company'] ?? ''}",
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
                              .collection('items')
                              .doc(doc.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Item deleted successfully"),
                            ),
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
