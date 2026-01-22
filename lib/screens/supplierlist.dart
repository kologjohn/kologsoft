import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/screens/supplierscreen.dart';
import 'package:provider/provider.dart';
import '../models/suppliermodel.dart';
import '../providers/Datafeed.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {

  final CollectionReference suppliersRef =
  FirebaseFirestore.instance.collection('suppliers');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final listWidth = screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;
return Consumer<Datafeed>(builder: (context, value, child){
  return Scaffold(
    backgroundColor:  const Color(0xFF1B263B),
    appBar: AppBar(title: const Text('Supplier List')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Container(
            width: listWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: suppliersRef.orderBy('datecreated', descending: true).where('companyid',isEqualTo: value.companyid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                        'No suppliers found',
                        style: TextStyle(color: Colors.white70),
                      ));
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final supplier = Supplier.fromMap(data);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      title: Text(supplier.supplier,
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text('Supplier: ${supplier.supplier}',
                          //     style: const TextStyle(color: Colors.white60)),
                          Text('Contact: ${supplier.contact}',
                              style: const TextStyle(color: Colors.white60)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () {
                              // Navigate to edit page (reuse SupplierRegistration)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupplierRegistration(supplier: supplier),
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
                                  title: const Text('Delete Supplier'),
                                  content: const Text('Are you sure you want to delete this supplier?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirm ?? false) {
                                await suppliersRef.doc(supplier.id).delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Supplier deleted successfully')),
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
          ),
        ),
      ),
    ),
  );

},);
  }
}
