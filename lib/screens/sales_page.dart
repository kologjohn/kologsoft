import 'package:flutter/material.dart';

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

  String? _selectedSalesMode;
  final List<String> _salesMode = ['Single', 'Box'];
  String? _selectedPriceMode;
  final List<String> _priceMode = ['Retail', 'Wholesale'];
  String? _selectedTaxType;
  final List<String> _taxType = ['Flat', 'standard', 'No vat'];

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
          padding: const EdgeInsets.only(left: 8.0, top: 20, right: 8, bottom: 20),
          child: Column(
            children: [
              Center(
                child: LayoutBuilder(
                    builder: (context, constraints){
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
                                    const Text("SALES ENTRIES",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              validator: (value) => value == null || value.isEmpty
                                                  ? 'Barcode required'
                                                  : null,
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
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              validator: (value) => value == null || value.isEmpty
                                                  ? 'Item required'
                                                  : null,
                                            ),
                                            SizedBox(height: 10),
                                            DropdownButtonFormField<String>(
                                              value: _selectedSalesMode,
                                              dropdownColor: const Color(0xFF22304A),
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Sales Mode',
                                                labelStyle: const TextStyle(color: Colors.white70),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(color: Colors.white24),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(color: Colors.blue),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              items: _salesMode.map((type) {
                                                return DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedSalesMode = value;
                                                });
                                              },
                                              validator: (value) =>
                                              value == null ? 'Please select sales mode' : null,
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: DropdownButtonFormField<String>(
                                                    value: _selectedPriceMode,
                                                    dropdownColor: const Color(0xFF22304A),
                                                    style: const TextStyle(color: Colors.white),
                                                    decoration: InputDecoration(
                                                      labelText: 'Price Mode',
                                                      labelStyle: const TextStyle(color: Colors.white70),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(color: Colors.white24),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(color: Colors.blue),
                                                      ),
                                                      fillColor: const Color(0xFF22304A),
                                                      filled: true,
                                                    ),
                                                    items: _priceMode.map((type) {
                                                      return DropdownMenuItem<String>(
                                                        value: type,
                                                        child: Text(type),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedPriceMode = value;
                                                      });
                                                    },
                                                    validator: (value) =>
                                                    value == null ? 'Please select price mode' : null,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _priceController,
                                                    style: TextStyle(color: Colors.white),
                                                    decoration: InputDecoration(
                                                      labelText: 'Price',
                                                      labelStyle: const TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(
                                                          color: Colors.white24,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                      fillColor: const Color(0xFF22304A),
                                                      filled: true,
                                                    ),
                                                    validator: (value) => value == null || value.isEmpty
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
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              validator: (value) => value == null || value.isEmpty
                                                  ? 'Enter quantity'
                                                  : null,
                                            ),
                                            SizedBox(height: 10),
                                            DropdownButtonFormField<String>(
                                              value: _selectedTaxType,
                                              dropdownColor: const Color(0xFF22304A),
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Tax Type',
                                                labelStyle: const TextStyle(color: Colors.white70),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(color: Colors.white24),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(color: Colors.blue),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              items: _taxType.map((type) {
                                                return DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedTaxType = value;
                                                });
                                              },
                                              validator: (value) =>
                                              value == null ? 'Please select price mode' : null,
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
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                fillColor: const Color(0xFF22304A),
                                                filled: true,
                                              ),
                                              validator: (value) => value == null || value.isEmpty
                                                  ? 'Enter Discount'
                                                  : null,
                                            ),
                                            SizedBox(height: 20),
                                            const Divider(color: Colors.white24,),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.orangeAccent,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      onPressed: (){},
                                                      child: Text("Save Record", style: TextStyle(color: Colors.white),)
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.lightBlue,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      onPressed: (){},
                                                      child: Text("Reset", style: TextStyle(color: Colors.white))
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.teal,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      onPressed: (){},
                                                      child: Text("Home", style: TextStyle(color: Colors.white))
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                    )
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
                                    const Text("SALES PREVIEW",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                        5: FlexColumnWidth(1),
                                      },
                                      children: [
                                        _tableRow([
                                          "#",
                                          "Item",
                                          "Quantity",
                                          "Price",
                                          "Total",
                                          "Action"
                                        ], isHeader: true,),
                                        _tableRow(["", "Taxable Total", "", "", "0.00", ""]),
                                        _tableRow(["", "Payable Amount", "", "", "0.00", ""]),
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
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: (){},
                                              child: Text("POS PRINT", style: TextStyle(color: Colors.white),)
                                          ),
                                        ),

                                        SizedBox(
                                          width: 100,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: (){},
                                              child: Text("MOMO", style: TextStyle(color: Colors.white))
                                          ),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.lightBlue,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: (){},
                                              child: Text("NEW TRANSACTION", style: TextStyle(color: Colors.white))
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: (){},
                                              child: Text("Customer Info", style: TextStyle(color: Colors.white))
                                          ),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }
                ),
              )

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
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: Colors.white
            ),
          ),
        ),
      )
          .toList(),
    );
  }


}
