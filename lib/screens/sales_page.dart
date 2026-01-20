import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';
import 'package:kologsoft/models/momo_payment_model.dart';
import 'package:kologsoft/models/customerreg_model.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _totalPiecesController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();

  String? _selectedSalesMode;
  List<String> _salesMode = []; // Will be populated from item's modes
  String? _selectedPriceMode;
  final List<String> _priceMode = ['Retail', 'Wholesale'];
  String? _selectedTaxType;
  final List<String> _taxType = ['Flat', 'standard', 'No vat'];
  Map<String, dynamic>? _itemModes; // Store the modes from selected item
  Map<String, dynamic>? _currentModeData; // Store the selected mode's data

  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Map<String, dynamic>? _selectedItem;
  String _searchQuery = '';

  // Sales preview items
  List<Map<String, dynamic>> _salesItems = [];

  @override
  void initState() {
    super.initState();
    _barcodeController.addListener(_onBarcodeChanged);
    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _barcodeController.removeListener(_onBarcodeChanged);
    _quantityController.removeListener(_onQuantityChanged);
    super.dispose();
  }

  void _onBarcodeChanged() {
    setState(() {
      _searchQuery = _barcodeController.text.trim();
      _showSuggestions = _searchQuery.isNotEmpty;
    });
  }

  void _onQuantityChanged() {
    _updatePrice(); // Recalculate price based on quantity vs sminqty
  }

  void _calculateTotals() {
    if (_currentModeData == null || _quantityController.text.isEmpty) {
      _totalPiecesController.text = '0';
      _totalAmountController.text = '0';
      return;
    }

    try {
      final userQuantity = double.tryParse(_quantityController.text) ?? 0;
      final modeQty = double.tryParse(_currentModeData!['qty'] ?? '1') ?? 1;

      // Calculate total pieces: user quantity × mode quantity
      final totalPieces = userQuantity * modeQty;
      _totalPiecesController.text = totalPieces.toStringAsFixed(0);

      // Calculate total amount: price × user quantity
      final price = double.tryParse(_priceController.text) ?? 0;
      final totalAmount = price * userQuantity;
      _totalAmountController.text = totalAmount.toStringAsFixed(2);

      setState(() {});
    } catch (e) {
      debugPrint('Error calculating totals: $e');
    }
  }

  void _addToSalesPreview() {
    if (_formKey.currentState!.validate()) {
      final salesItem = {
        'item': _itemController.text,
        'mode': _selectedSalesMode ?? '',
        'quantity': _quantityController.text,
        'price': _priceController.text,
        'totalPieces': _totalPiecesController.text,
        'totalAmount': _totalAmountController.text,
        'priceMode': _selectedPriceMode ?? 'Retail',
      };

      setState(() {
        _salesItems.add(salesItem);
      });

      // Clear form
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added to sales preview'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetForm() {
    _itemController.clear();
    _barcodeController.clear();
    _quantityController.clear();
    _priceController.clear();
    _discountController.clear();
    _totalPiecesController.clear();
    _totalAmountController.clear();
    setState(() {
      _selectedItem = null;
      _selectedSalesMode = null;
      _selectedPriceMode = null;
      _selectedTaxType = null;
      _currentModeData = null;
      _itemModes = null;
      _salesMode = [];
    });
  }

  void _removeFromSalesPreview(int index) {
    setState(() {
      _salesItems.removeAt(index);
    });
  }

  double _calculateTaxableTotal() {
    double total = 0;
    for (var item in _salesItems) {
      total += double.tryParse(item['totalAmount'] ?? '0') ?? 0;
    }
    return total;
  }

  void _showMomoDialog() {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController amountController = TextEditingController(
      text: _calculateTaxableTotal().toStringAsFixed(2),
    );
    final TextEditingController networkController = TextEditingController();
    String? selectedNetwork;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: AlertDialog(
              backgroundColor: const Color(0xFF1A2332),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mobile Money Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Network Selection
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF22304A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedNetwork,
                          isExpanded: true,
                          hint: const Text(
                            'Select Network',
                            style: TextStyle(color: Colors.white70),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                          ),
                          dropdownColor: const Color(0xFF22304A),
                          style: const TextStyle(color: Colors.white),
                          items: ['MTN', 'Vodafone', 'AirtelTigo']
                              .map(
                                (network) => DropdownMenuItem<String>(
                                  value: network,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.sim_card,
                                        color: network == 'MTN'
                                            ? Colors.yellow
                                            : network == 'Vodafone'
                                            ? Colors.red
                                            : Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(network),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedNetwork = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '024XXXXXXX',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF2196F3),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFF4CAF50),
                        ),
                        prefixText: 'GHS ',
                        prefixStyle: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'A payment request will be sent to this number',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (phoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter phone number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (selectedNetwork == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select network'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final provider = Provider.of<Datafeed>(
                              context,
                              listen: false,
                            );
                            final docId = FirebaseFirestore.instance
                                .collection('momo_payments')
                                .doc()
                                .id;

                            final momoPayment = MomoPaymentModel(
                              id: docId,
                              phoneNumber: phoneController.text,
                              amount: double.parse(amountController.text),
                              branchId: provider.selectedBranch?.id ?? '',
                              branchName:
                                  provider.selectedBranch?.branchname ?? '',
                              companyId: provider.companyid,
                              staff: provider.staff,
                              status: 'pending',
                              createdAt: DateTime.now(),
                            );

                            await FirebaseFirestore.instance
                                .collection('momo_payments')
                                .doc(docId)
                                .set(momoPayment.toMap());

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'MOMO request sent to ${phoneController.text}',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isSaving = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Send Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerInfoDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    String? selectedCustomerType;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: AlertDialog(
              backgroundColor: const Color(0xFF1A2332),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Customer Name *',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Enter full name',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFFF9800),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '024XXXXXXX',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF4CAF50),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Customer Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF22304A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCustomerType,
                          isExpanded: true,
                          hint: const Text(
                            'Customer Type *',
                            style: TextStyle(color: Colors.white70),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                          ),
                          dropdownColor: const Color(0xFF22304A),
                          style: const TextStyle(color: Colors.white),
                          items:
                              [
                                    'Retail',
                                    'Wholesale',
                                    'Distributor',
                                    'Corporate',
                                  ]
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(
                                            type == 'Retail'
                                                ? Icons.shopping_bag
                                                : type == 'Wholesale'
                                                ? Icons.business_center
                                                : type == 'Distributor'
                                                ? Icons.local_shipping
                                                : Icons.corporate_fare,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(type),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomerType = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email (Optional)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'customer@email.com',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF2196F3),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Address (Optional)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Enter customer address',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFFF44336),
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF44336),
                          ),
                        ),
                        fillColor: const Color(0xFF22304A),
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter name and phone number',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (selectedCustomerType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select customer type'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final provider = Provider.of<Datafeed>(
                              context,
                              listen: false,
                            );
                            final docId = FirebaseFirestore.instance
                                .collection('customers')
                                .doc()
                                .id;

                            final customer = CustomerRegModel(
                              id: docId,
                              branchname:
                                  provider.selectedBranch?.branchname ?? '',
                              branchid: provider.selectedBranch?.id ?? '',
                              name: nameController.text,
                              contact: phoneController.text,
                              customertype: selectedCustomerType!,
                              creditlimit: null,
                              paymentduration: null,
                              companyid: provider.companyid,
                              staff: provider.staff,
                              date: DateTime.now(),
                              updatedby: null,
                              updatedat: null,
                              deletedat: null,
                            );

                            // Save customer with additional fields
                            final customerData = customer.toMap();
                            customerData['email'] = emailController.text;
                            customerData['address'] = addressController.text;

                            await FirebaseFirestore.instance
                                .collection('customers')
                                .doc(docId)
                                .set(customerData);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Customer ${nameController.text} saved successfully',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isSaving = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error saving customer: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _itemController.text = item['name'] ?? '';
      _barcodeController.text = item['barcode'] ?? ''; // Fill barcode field

      // Extract modes from item
      _itemModes = item['modes'] as Map<String, dynamic>?;

      if (_itemModes != null && _itemModes!.isNotEmpty) {
        // Populate sales mode dropdown with available modes
        _salesMode = _itemModes!.keys.map((key) {
          final modeData = _itemModes![key] as Map<String, dynamic>?;
          return modeData?['name'] as String? ?? key;
        }).toList();

        // Set the first mode as default and update price
        if (_salesMode.isNotEmpty) {
          _selectedSalesMode = _salesMode.first;
          _updatePrice();
        }
      } else {
        // Fallback to default modes if item doesn't have modes
        _salesMode = ['Single', 'Box'];
        _selectedSalesMode = null;
        _currentModeData = null;
      }

      _showSuggestions = false;
      _suggestions = [];
    });

    // Print item details
    debugPrint('========== SELECTED ITEM DETAILS ==========');
    debugPrint('Name: ${item['name']}');
    debugPrint('Barcode: ${item['barcode']}');
    debugPrint('Modes: ${item['modes']}');
    debugPrint('Category: ${item['productcategory']}');
    debugPrint('Stock: ${item['openingstock']}');
    debugPrint('==========================================');
  }

  void _updatePrice() {
    if (_itemModes == null || _selectedSalesMode == null) {
      _priceController.text = '0';
      _currentModeData = null;
      return;
    }

    // Find the mode data by matching the name
    Map<String, dynamic>? selectedModeData;
    for (var entry in _itemModes!.entries) {
      final modeData = entry.value as Map<String, dynamic>?;
      if (modeData?['name'] == _selectedSalesMode) {
        selectedModeData = modeData;
        break;
      }
    }

    if (selectedModeData != null) {
      _currentModeData = selectedModeData;

      // Get user input quantity and sminqty from item level (not mode)
      final userQuantity = double.tryParse(_quantityController.text) ?? 0;
      final sminqty =
          double.tryParse(_selectedItem?['sminqty']?.toString() ?? '0') ?? 0;

      // Debug: Log raw values from Firestore
      debugPrint('========== PRICE CALCULATION DEBUG ==========');
      debugPrint(
        'Raw sp: ${selectedModeData['sp']} (${selectedModeData['sp'].runtimeType})',
      );
      debugPrint(
        'Raw wp: ${selectedModeData['wp']} (${selectedModeData['wp'].runtimeType})',
      );
      debugPrint(
        'Raw rp: ${selectedModeData['rp']} (${selectedModeData['rp'].runtimeType})',
      );
      debugPrint(
        'Raw sminqty: ${_selectedItem?['sminqty']} (${_selectedItem?['sminqty'].runtimeType})',
      );
      debugPrint('Parsed sminqty: $sminqty');
      debugPrint('User quantity: $userQuantity');
      debugPrint('Price Mode: $_selectedPriceMode');

      // Set price based on retail/wholesale selection using sp/wp
      String price = '0';
      if (_selectedPriceMode == 'Retail') {
        // Check if quantity >= sminqty to use sp, otherwise use rp
        if (userQuantity >= sminqty && sminqty > 0) {
          debugPrint('Condition: qty >= sminqty -> Using sp');
          price =
              selectedModeData['sp']?.toString() ??
              selectedModeData['rp']?.toString() ??
              '0';
        } else {
          debugPrint('Condition: qty < sminqty -> Using rp');
          price =
              selectedModeData['rp']?.toString() ??
              selectedModeData['sp']?.toString() ??
              '0';
        }
      } else if (_selectedPriceMode == 'Wholesale') {
        debugPrint('Wholesale mode -> Using wp');
        price = selectedModeData['wp']?.toString() ?? '0';
      } else {
        // Default: check sminqty condition
        if (userQuantity >= sminqty && sminqty > 0) {
          debugPrint('Default + qty >= sminqty -> Using sp');
          price =
              selectedModeData['sp']?.toString() ??
              selectedModeData['rp']?.toString() ??
              '0';
        } else {
          debugPrint('Default + qty < sminqty -> Using rp');
          price =
              selectedModeData['rp']?.toString() ??
              selectedModeData['sp']?.toString() ??
              '0';
        }
      }

      debugPrint('Selected price: $price');
      debugPrint('==========================================');

      _priceController.text = price;

      // Recalculate totals when price changes
      _calculateTotals();
    } else {
      _currentModeData = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: Text(
          "SALES TRANSACTIONS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            top: 20,
            right: 8,
            bottom: 20,
          ),
          child: Column(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 900;
                    final double itemWidth = isSmallScreen
                        ? constraints.maxWidth
                        : (constraints.maxWidth / 2) - 24;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: Container(
                            color: Color(0xFF182232),
                            //height: 600,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "SALES ENTRIES",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                  SizedBox(height: 15),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _barcodeController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Barcode',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Barcode required'
                                              : null,
                                        ),
                                        // Auto-suggestion dropdown with StreamBuilder
                                        if (_showSuggestions)
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('itemsreg')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 4,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.blue,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                );
                                              }

                                              // Filter results based on search query
                                              final allDocs =
                                                  snapshot.data!.docs;
                                              final filteredDocs = allDocs
                                                  .where((doc) {
                                                    final data =
                                                        doc.data()
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    final name =
                                                        (data['name'] ?? '')
                                                            .toString()
                                                            .toLowerCase();
                                                    final barcode =
                                                        (data['barcode'] ?? '')
                                                            .toString()
                                                            .toLowerCase();
                                                    final query = _searchQuery
                                                        .toLowerCase();
                                                    return name.contains(
                                                          query,
                                                        ) ||
                                                        barcode.contains(query);
                                                  })
                                                  .take(10)
                                                  .toList();

                                              if (filteredDocs.isEmpty) {
                                                return SizedBox.shrink();
                                              }

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 250,
                                                    ),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      filteredDocs.length,
                                                  itemBuilder: (context, index) {
                                                    final doc =
                                                        filteredDocs[index];
                                                    final item =
                                                        doc.data()
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    item['id'] = doc.id;

                                                    return ListTile(
                                                      dense: true,
                                                      leading: Icon(
                                                        Icons.inventory_2,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      title: Text(
                                                        item['name'] ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Barcode: ${item['barcode']} | Retail: GHS ${item['retailprice']} | Stock: ${item['openingstock']}',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      trailing: Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.white54,
                                                        size: 14,
                                                      ),
                                                      onTap: () =>
                                                          _selectItem(item),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _itemController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Item',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Item required'
                                              : null,
                                        ),
                                        SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          value: _selectedSalesMode,
                                          dropdownColor: const Color(
                                            0xFF22304A,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Sales Mode',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                          items: _salesMode.isEmpty
                                              ? null
                                              : _salesMode.map((type) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: type,
                                                    child: Text(type),
                                                  );
                                                }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedSalesMode = value;
                                              _updatePrice();
                                            });
                                          },
                                          validator: (value) => value == null
                                              ? 'Please select sales mode'
                                              : null,
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedPriceMode,
                                                dropdownColor: const Color(
                                                  0xFF22304A,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Price Mode',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors
                                                                  .white24,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                      ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                                items: _priceMode.map((type) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: type,
                                                    child: Text(type),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedPriceMode = value;
                                                    _updatePrice();
                                                  });
                                                },
                                                validator: (value) =>
                                                    value == null
                                                    ? 'Please select price mode'
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _priceController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Price',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors
                                                                  .white24,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                      ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                                validator: (value) =>
                                                    value == null ||
                                                        value.isEmpty
                                                    ? 'Enter amount'
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _quantityController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Quantity',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Enter quantity'
                                              : null,
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _totalPiecesController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Total Pieces',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors
                                                                  .white24,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                      ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _totalAmountController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Total Amount',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors
                                                                  .white24,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                      ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _discountController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Discount',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        const Divider(color: Colors.white24),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orangeAccent,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: _addToSalesPreview,
                                                child: Text(
                                                  "Save Record",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.lightBlue,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: _resetForm,
                                                child: Text(
                                                  "Reset",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {},
                                                child: Text(
                                                  "Home",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Container(
                            color: Color(0xFF182232),
                            //height: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "SALES PREVIEW",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                  SizedBox(height: 15),

                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    columnWidths: const {
                                      0: FixedColumnWidth(40),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(1),
                                      3: FlexColumnWidth(1),
                                      4: FlexColumnWidth(1),
                                      5: FixedColumnWidth(60),
                                    },
                                    children: [
                                      _tableRow([
                                        "#",
                                        "Item",
                                        "Quantity",
                                        "Price",
                                        "Total",
                                        "Action",
                                      ], isHeader: true),
                                      // Display sales items
                                      ..._salesItems.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        return _tableRowWithAction(
                                          (index + 1).toString(),
                                          item['item'] ?? '',
                                          item['quantity'] ?? '0',
                                          item['price'] ?? '0',
                                          item['totalAmount'] ?? '0',
                                          () => _removeFromSalesPreview(index),
                                        );
                                      }).toList(),
                                      _tableRow([
                                        "",
                                        "Taxable Total",
                                        "",
                                        "",
                                        _calculateTaxableTotal()
                                            .toStringAsFixed(2),
                                        "",
                                      ]),
                                      _tableRow([
                                        "",
                                        "Payable Amount",
                                        "",
                                        "",
                                        _calculateTaxableTotal()
                                            .toStringAsFixed(2),
                                        "",
                                      ]),
                                    ],
                                  ),

                                  SizedBox(height: 20),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {},
                                          child: Text(
                                            "POS PRINT",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: _showMomoDialog,
                                          child: Text(
                                            "MOMO",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {},
                                          child: Text(
                                            "NEW TRANSACTION",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: _showCustomerInfoDialog,
                                          child: Text(
                                            "Customer Info",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells
          .map(
            (e) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                e,
                textAlign: isHeader ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _tableRowWithAction(
    String index,
    String item,
    String quantity,
    String price,
    String total,
    VoidCallback onDelete,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(index, style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(item, style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(quantity, style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(price, style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(total, style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
