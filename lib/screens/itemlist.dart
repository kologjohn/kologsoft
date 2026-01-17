import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'itemlist.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('items').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No items registered yet",
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

              // Determine active pricing
              final retailActive = (data['retailmarkup'] ?? '').isNotEmpty;
              final wholesaleActive = !retailActive;

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
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF22304A),
                      child: const Icon(Icons.inventory, color: Colors.white70),
                    ),
                    const SizedBox(width: 16),

                    /// ITEM DETAILS
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
                          Text(
                            "Barcode: ${data['barcode'] ?? ''}\n"
                                "Cost Price: ${data['costprice'] ?? ''}\n"
                                "Retail Markup: ${data['retailmarkup'] ?? ''} → Retail Price: ${data['retailprice'] ?? ''}",
                            style: TextStyle(
                              color: retailActive ? Colors.white70 : Colors.white38,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            "Wholesale Markup: ${data['wholesalemarkup'] ?? ''} → Wholesale Price: ${data['wholesaleprice'] ?? ''}",
                            style: TextStyle(
                              color: wholesaleActive ? Colors.white70 : Colors.white38,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            "Opening Stock: ${data['openingstock'] ?? ''}\n"
                                "Product Type: ${data['producttype'] ?? ''}\n"
                                "Pricing Mode: ${data['pricingmode'] ?? ''}\n"
                                "Category: ${data['productcategory'] ?? ''}\n"
                                "Warehouse: ${data['warehouse'] ?? ''}\n"
                                "Company: ${data['company'] ?? ''}",
                            style: const TextStyle(color: Colors.white38, height: 1.4),
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
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Item"),
                            content: const Text(
                                "Are you sure you want to delete this item?"),
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
                          await db.collection('items').doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Item deleted")),
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
