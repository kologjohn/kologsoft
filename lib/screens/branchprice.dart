import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/itemregmodel.dart';
import '../models/staffmodel.dart';
import '../providers/Datafeed.dart';
import 'branchpriceedit.dart';

class BranchPricePage extends StatefulWidget {
  const BranchPricePage({super.key});

  @override
  State<BranchPricePage> createState() => _BranchPricePageState();
}

class _BranchPricePageState extends State<BranchPricePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String searchQuery = '';
  StaffModel? curreenstaff;
  String? userbranchid;
  String? userrole;
  String? staff;
  String? companyid;
  List<Map<String, dynamic>> branches = [];
  String? selectedBranchId;
  bool branchLocked = false;

  bool get canSelectBranch {
    if (userrole == null) return false;
    final n = userrole!.toLowerCase().replaceAll(' ', '');
    return {'admin', 'manager', 'superadmin'}.contains(n);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vvalue = Provider.of<Datafeed>(context, listen: false);
      companyid = vvalue.companyid;

      curreenstaff = vvalue.currentStaff;
      userbranchid = vvalue.branchid;
      userrole = vvalue.accessLevel;
      staff =vvalue.staff;
      _initUserAndBranches();
    });
  }

  Future<void> _initUserAndBranches() async {
    try {
      final adminroles = ['admin', 'manager', 'super admin'];
      if (userrole != null && adminroles.contains(userrole)) {
        final snap = await db.collection('branches')
            .where('companyId', isEqualTo: companyid?.toUpperCase())
            .orderBy('branchName') .get();

        branches = snap.docs.map((d) {
          final m = d.data();
          return {
            'id': d.id,
            'name': (m['branchName'] ?? d.id).toString(),
          };
        }).toList();

        if (userbranchid != null && userbranchid!.isNotEmpty) {
          selectedBranchId = userbranchid;
        } else if (branches.isNotEmpty) {
          selectedBranchId = branches.first['id'] as String;
        }
      } else {
        selectedBranchId = userbranchid;
      }
      //	print('Loaded branches: $branches');
    } catch (e, s) {
      debugPrint('Error loading branches: $e');
      debugPrintStack(stackTrace: s);
      selectedBranchId = userbranchid;
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 900;
    final value = Provider.of<Datafeed>(context,listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(title:  Text(value.company)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (canSelectBranch)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: const Text(
                          'Select Branch:',
                          style: TextStyle(color: Colors.white70,fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (branches.isNotEmpty)
                        SizedBox(
                          height: 70,
                          width: isDesktop ? 600 : 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: branches.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final b = branches[idx];
                                    final id = b['id'] as String;
                                    final name = b['name'] as String;
                                    final selected = selectedBranchId == id;

                                    return GestureDetector(
                                      onTap: () {
                                        if (!branchLocked) {
                                          setState(() {
                                            selectedBranchId = id;
                                            branchLocked = true;
                                          });
                                        }
                                      },
                                      onDoubleTap: () async {
                                        if (id == selectedBranchId) return;
                                        final doChange = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Change branch',
                                            ),
                                            content: const Text(
                                              'Do you want to change pricing for this branch?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (doChange == true) {
                                          setState(() {
                                            selectedBranchId = id;
                                            branchLocked = true;
                                          });
                                        }
                                      },
                                      child: Opacity(
                                        opacity: (branchLocked && !selected)
                                            ? 0.45
                                            : 1.0,
                                        child: Card(
                                          color: selected
                                              ? Colors.amber
                                              : const Color(0xFF22304A),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    color: selected
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                                if (selected)
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.lock,
                                                      size: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (branchLocked)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    'Branch locked. Double-tap another branch to change.',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        const Text(
                          'No branches',
                          style: TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 680 : MediaQuery.of(context).size.width * 0.95,

                      ),
                      child: TextFormField(
                        onChanged: (v) =>
                            setState(() => searchQuery = v.toLowerCase()),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF22304A),
                          hintText: 'Search items...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (selectedBranchId == null)
            Expanded(
              child: Center(
                child: Text(
                  'Tap a branch to view items',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('itemsreg').orderBy('name').snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (!snap.hasData || snap.data!.docs.isEmpty)
                    return const Center(
                      child: Text(
                        'No items',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );

                  final items = snap.data!.docs
                      .map((d) => ItemModel.fromDoc(d))
                      .where((item) {
                        final name = item.name.toLowerCase();
                        final barcode = (item.barcode ?? '').toLowerCase();
                        final company = (item.company ?? '').toLowerCase();
                        final category = (item.pcategory ?? '').toLowerCase();
                        return name.contains(searchQuery) ||
                            barcode.contains(searchQuery) ||
                            company.contains(searchQuery) ||
                            category.contains(searchQuery);
                      })
                      .toList();

                  if (items.isEmpty)
                    return Center(
                      child: Text(
                        "No items found for '$searchQuery'",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );

                  return isDesktop ? _desktopTable(items) : _mobileList(items);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _mobileList(List<ItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          color: const Color(0xFF1B263B),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF415A77),
              child: Text('${i + 1}'),
            ),
            title: Text(item.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'Barcode: ${item.barcode}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              if (selectedBranchId == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Branchitempriceupdate(
                    item: item,
                    branchId: selectedBranchId!,
                    staff: staff!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _desktopTable(List<ItemModel> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF22304A)),
        dataRowColor: MaterialStateProperty.all(const Color(0xFF1B263B)),
        columns: const [
          DataColumn(
            label: Text('#', style: TextStyle(color: Colors.white70)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(color: Colors.white70)),
          ),
          DataColumn(
            label: Text('Barcode', style: TextStyle(color: Colors.white70)),
          ),
          DataColumn(
            label: Text('Category', style: TextStyle(color: Colors.white70)),
          ),
          DataColumn(
            label: Text('Actions', style: TextStyle(color: Colors.white70)),
          ),
        ],
        rows: List.generate(items.length, (index) {
          final item = items[index];
          return DataRow(
            onSelectChanged: (_) {
              if (selectedBranchId == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Branchitempriceupdate(
                    item: item,
                    branchId: selectedBranchId!,
                    staff: staff!,
                  ),
                ),
              );
            },
            cells: [
              DataCell(
                Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(item.name, style: const TextStyle(color: Colors.white)),
              ),
              DataCell(
                Text(
                  item.barcode ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                Text(
                  item.pcategory ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () {
                    if (selectedBranchId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Branchitempriceupdate(
                          item: item,
                          branchId: selectedBranchId!,
                          staff: staff!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

 


  TextFormField _buildFieldWithEnabled(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
        bool enabled = true,
        Function(String)? onChanged,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: _inputDecoration(label, icon),
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
  TextFormField _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool enabled = true,
        bool isNumber = false,
        Function(String)? onChanged,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: _inputDecoration(label, icon),
      onChanged: onChanged,
      inputFormatters: inputFormatters,
    );
  }
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF22304A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }
}
