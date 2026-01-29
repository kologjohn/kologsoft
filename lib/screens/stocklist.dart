import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kologsoft/screens/newstock.dart';
import 'package:provider/provider.dart';
import '../providers/Datafeed.dart';
import 'itemreg.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text("Stocked Item List"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF415A77),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewStock()),
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
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Provider.of<Datafeed>(context, listen: false).itemsStream(collectionName: 'stock_transactions'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No stock items yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final allDocs = snapshot.data!;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc as Map<String, dynamic>;
                  return data.values.any((value) {
                    if (value == null) return false;
                    return value.toString().toLowerCase().contains(searchQuery);
                  });
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? "No items stocked yet"
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
                    final data = doc as Map<String, dynamic>;
                    final rawItems = data['items'];

                    List<Map<String, dynamic>> items = [];

                    if (rawItems is List) {
                      items = rawItems.map((e) => Map<String, dynamic>.from(e)).toList();
                    } else if (rawItems is Map) {
                      items = rawItems.entries.map((entry) {
                        return {
                          'key': entry.key,
                          ...Map<String, dynamic>.from(entry.value),
                        };
                      }).toList();
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Invoice#: ${data['invoice']}",
                                style: const TextStyle(color: Colors.amberAccent,
                                    fontSize: 20,
                                  fontWeight: FontWeight.bold),

                              ),
                              CircleAvatar(
                                radius: 18,
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
                            ],
                          ),
                          const SizedBox(height: 8),

                          ...items.map((item) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.label, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${item['item']}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Text("Qty: ${item['quantity']}", style: const TextStyle(color: Colors.white)),
                                Text("Mode: ${item['stockingmode']}", style: const TextStyle(color: Colors.white)),
                                Text("Purchase price: ${item['price']}", style: const TextStyle(color: Colors.white)),
                                Text("Total: ${item['total']}", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                const Divider(color: Colors.white24, height: 20),

                              ],
                            );
                          }).toList(),

                          Text(
                            "Date: ${data['createdat'].toDate().toString().substring(0, 10)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Staff: ${data['createdby'].toString()}",
                            style: const TextStyle(color: Colors.white),
                          ),

                          const Divider(color: Colors.white24, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                "Total Amount: GHC ${data['netval'].toStringAsFixed(2) ?? 0}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NewStock(
                                            docId: doc['docid'],
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
                                          title: Text("Delete Stock Invoice #${data['invoice']}"),
                                          content: const Text("Are you sure you want to delete this stock invoice?"),
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
                                        await db.collection('stock_transactions').doc(doc['docid']).delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Stock invoice deleted successfully"),backgroundColor: Colors.green,),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
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
