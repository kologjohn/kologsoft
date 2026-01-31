import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/itemregmodel.dart';
import '../providers/Datafeed.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 900;
    final value = Provider.of<Datafeed>(context, listen: false);
    final companyid = value.companyid;
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(title: const Text("Registered Items")),
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
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF22304A),
                hintText: "Search...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () => setState(() => searchQuery = ""),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('itemsreg').orderBy('name').where("companyId", isEqualTo: companyid).snapshots(),
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

                final items = snapshot.data!.docs
                    .map((e) => ItemModel.fromDoc(e))
                    .where((item) {
                  final name = item.name ?? "";
                  final barcode = item.barcode ?? "";
                  final company = item.company ?? "";
                  final category = item.pcategory ?? "";
                    return name.toLowerCase().contains(searchQuery) ||
                      barcode.toLowerCase().contains(searchQuery) ||
                      company.toLowerCase().contains(searchQuery) ||
                      category.toLowerCase().contains(searchQuery);
                      }).toList();

                if (items.isEmpty) {
                  return Center(child: Text( "No items found for '$searchQuery'",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return isDesktop
                    ? _desktopTable(items)
                    : _mobileCards(items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCards(List<ItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showItemModal(item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF415A77),
                    child: Text("${index + 1}"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Barcode: ${item.barcode}",
                          style:
                          const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.white54),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemModal(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;

        return Dialog(
          backgroundColor: const Color(0xFF182232),
          insetPadding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            height: size.height * 0.78,
            width: size.width > 700 ? 600 : double.infinity,
            child: Column(
              children: [
                // ================= HEADER =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF415A77),
                        child: Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : "#",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (item.pcategory.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22304A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(item.pcategory, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ),
                                const SizedBox(width: 8),
                                Text("Barcode: ${item.barcode}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white24),

                // ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.imageurl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: ClipOval(
                                child: SizedBox(
                                  height: 140,
                                  width: 140,
                                  child: Image.network(
                                    item.imageurl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return SizedBox(
                                        height: 140,
                                        width: 140,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: progress.expectedTotalBytes != null
                                                ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 140,
                                      width: 140,
                                      color: const Color(0xFF22304A),
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        _section("Basic Information"),
                        _line("Item No", item.no,'1'),
                        _line("Barcode", item.barcode,'2'),
                        _line("Product Type", item.producttype,'3'),
                        _line("Category", item.pcategory,'4'),
                        _line("Company", item.company,'5'),
                        _line("Warehouse", item.warehouse,'6'),

                        const SizedBox(height: 12),
                        _section("Pricing"),
                        _line("Cost Price", item.cp,'1'),
                        _line("Retail Markup", item.retailmarkup,'2'),
                        _line("Wholesale Markup", item.wholesalemarkup,'3'),
                        _line("Retail Price", item.retailprice,'4'),
                        _line("Wholesale Price", item.wholesaleprice,'5'),
                        _line("Pricing Mode", item.pricingmode,'6'),

                        const SizedBox(height: 12),
                        _section("Stock"),
                        _line("Opening Stock", item.openingstock,'1'),
                        _line("Wholesale Minimum Quantity", item.wminqty,'1'),
                        _line("Supplier Minnimum Quantity", item.sminqty,'1'),

                        const SizedBox(height: 12),
                        _section("Pricing Modes"),
                        if (item.modes.isEmpty)
                          const Text("No pricing modes defined", style: TextStyle(color: Colors.white54)),
                        if (item.modes.isNotEmpty)
                          ...item.modes.entries.map((e) {
                            final m = Map<String, dynamic>.from(e.value);
                            return _pricingCard(
                              name: m['name'],
                              qty: m['qty'],
                              rp: m['rp'],
                              wp: m['wp'],
                              sp: m['sp'],
                            );
                          }),

                        const SizedBox(height: 12),
                        _section("Audit"),
                        _line("Created At", item.createdat.toString(),'1'),
                        _line("Updated At", item.updatedat?.toString() ?? "",'2'),
                        _line("Updated By", item.updatedby.toString() ?? "",'3'),
                        _line("Staff", item.staff,'4'),
                      ],
                    ),
                  ),
                ),


                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A6F97)),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Edit"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemRegPage(docId: item.id, item: item),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        label: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteItem(item.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _line(String label, String value,String no) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF415A77),
            child: Text(no),
          ),
          SizedBox(width: 10,),
          SizedBox(
            width: 140,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _pricingCard({
    required String name,
    required dynamic qty,
    required dynamic rp,
    required dynamic wp,
    required dynamic sp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              _priceBox("Quantity", qty),
              _priceBox("Retail Price", rp),
              _priceBox("Wholesale Price", wp),
              _priceBox("Supplier Price", sp),
            ],
          )
        ],
      ),
    );
  }

  Widget _desktopTable(List<ItemModel> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
        MaterialStateProperty.all(const Color(0xFF22304A)),
        dataRowColor:
        MaterialStateProperty.all(const Color(0xFF1B263B)),
        columns: const [
          DataColumn(label: Text("#", style: TextStyle(color: Colors.white70))),
          DataColumn(label: Text("Name", style: TextStyle(color: Colors.white70))),
          DataColumn(label: Text("Barcode", style: TextStyle(color: Colors.white70))),
          DataColumn(label: Text("Company", style: TextStyle(color: Colors.white70))),
          DataColumn(label: Text("Category", style: TextStyle(color: Colors.white70))),
         // DataColumn(label: Text("Pricing", style: TextStyle(color: Colors.white70))),
          DataColumn(label: Text("Actions", style: TextStyle(color: Colors.white70))),
        ],
        rows: List.generate(items.length, (index) {
          final item = items[index];
          final pricing = item.modes.values
              .map((m) => "${m['name']} (${m['qty']})")
              .join(", ");

          return DataRow(
            onSelectChanged: (_) => _showItemModal(item),
            cells: [
              DataCell(Text("${index + 1}",
                  style: const TextStyle(color: Colors.white))),
              DataCell(Text(item.name,
                  style: const TextStyle(color: Colors.white))),
              DataCell(Text(item.barcode,
                  style: const TextStyle(color: Colors.white70))),
              DataCell(Text(item.company,
                  style: const TextStyle(color: Colors.white70))),
              DataCell(Text(item.pcategory,
                  style: const TextStyle(color: Colors.white70))),
             // DataCell(Text(pricing,style: const TextStyle(color: Colors.white60))),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ItemRegPage(docId: item.id, item: item),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteItem(item.id),
                  ),
                ],
              )),
            ],
          );
        }),
      ),
    );
  }

  Widget _priceBox(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF22304A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF182232),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Confirm Delete",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this item?\nThis action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await db.collection('itemsreg').doc(id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete item: $e")),
        );
      }
    }
  }

}

