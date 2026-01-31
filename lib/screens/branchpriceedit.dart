import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as hiveBox;
import 'package:image_picker/image_picker.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;
import '../models/itemregmodel.dart';
import '../providers/Datafeed.dart';

class Branchitempriceupdate extends StatefulWidget {
  final ItemModel item;
  final String branchId;
  final String staff;

  const Branchitempriceupdate({super.key, required this.item, required this.branchId, required this.staff,});
  @override
  State<Branchitempriceupdate> createState() => _BranchitempriceupdateState();
}

class _BranchitempriceupdateState extends State<Branchitempriceupdate> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costController = TextEditingController();
  int pricingStep = 0;
  bool _enableBoxPricing = false;
  bool _showBoxPricingSwitch = false;
  final _boxQtyController = TextEditingController();
  final _halfboxqty_controller = TextEditingController();
  final _quarterqty_controller = TextEditingController();
  final _retail_price = TextEditingController();
  final _packQtyController = TextEditingController();

  final _supplierPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _halfboxprice_controller = TextEditingController();
  final _quarterprice_controller = TextEditingController();
  final _packprice_controller = TextEditingController();

  final _wholesaleMinQtyController = TextEditingController();
  final _supplierMinQtyController = TextEditingController();
  bool _loading = false;
  // ================= UNIFIED VALIDATION METHOD =================
  String? _validateField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      if (fieldName == 'supplierMinQty') return null; // Optional field
      return 'Required';
    }

    switch (fieldName) {
      case 'retailPrice':
        double retailPrice = double.tryParse(value) ?? 0;
        double unitCost = double.tryParse(_costController.text) ?? 0;
        double boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        double supplierPrice =double.tryParse(_supplierPriceController.text) ?? 0;
        double boxQty = double.tryParse(_boxQtyController.text) ?? 1;
        double boxunitprice = boxPrice / boxQty;

        if (retailPrice <= 0) return 'Enter a valid retail price';
        if (boxQty == 1) {

        }
        if (unitCost > 0 && retailPrice < unitCost) {
          return 'Retail price GHS$retailPrice must be greater than\n Unit Cost which is GHS${boxPrice / boxQty}';
        }

        if (boxQty > 1) {
          if (retailPrice < boxunitprice) {
            return 'Retail price GHS$retailPrice must be equal to \n or greater than Box unit Price GHS${boxPrice / boxQty}';
          }

          if (supplierPrice > 0 && retailPrice < (supplierPrice / boxQty)) {
            return 'Unit retail price GHS$retailPrice must be equal \n to or greater than Supplier Price ${supplierPrice / boxQty}';
          }

          if (retailPrice < unitCost) {
            return 'Retail price GHS$retailPrice must be greater than\n or equal to Unit Cost GHS$unitCost';
          }
        }
        return null;

      case 'costPrice':
        final costPrice = double.tryParse(value) ?? 0;
        final retailPrice = double.tryParse(_retail_price.text) ?? 0;

        if (retailPrice > 0 && costPrice > retailPrice) {
          return 'Unit Cost Price GHS$costPrice must be less than Retail Price GHS$retailPrice';
        }
        return null;

      case 'boxQty':
        final boxQty = int.tryParse(value) ?? 0;
        if (boxQty < 1) {
          return 'Box quantity must be at least 1';
        }
        return null;

      case 'boxPrice':
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
        // if (boxQty == 1) return null;

        double boxPrice = double.tryParse(value) ?? 0;
        double boxQtyVal = double.tryParse(_boxQtyController.text) ?? 1;
        double pricePerUnit = boxQtyVal > 0 ? boxPrice / boxQtyVal : 0;
        double retailPrice = double.tryParse(_retail_price.text) ?? 0;
        double costPrice = double.tryParse(_costController.text) ?? 0;

        if (boxQty == 1) {
          // if (supplierPrice != boxPrice || supplierPrice != retailPrice) {
          //   return 'Prices should be equal because Box Qty is 1,';
          // }
          if(costPrice > boxPrice){
            return 'Cost price  GHS$costPrice \n is more than Box Price GHS$boxPrice';
          }
          if(boxPrice > retailPrice){
            return 'Box price  GHS$boxPrice \n can more than Retail Price GHS$retailPrice';
          }
          return null;
        }

        if (pricePerUnit > retailPrice) {
          return 'Price per unit which is GHS${boxPrice / boxQtyVal} \n Qty cannot be less than Retail Price';
        }

        if (pricePerUnit < costPrice) {
          return 'Price per unit which is GHS${boxPrice / boxQtyVal} \n Qty cannot be less than Unit Cost Price';
        }
        return null;

      case 'supplierPrice':
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
        if (boxQty <= 0) return null;

        final supplierPrice = double.tryParse(value) ?? 0;
        final unitCost = double.tryParse(_costController.text) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final retailPrice = double.tryParse(_retail_price.text) ?? 0;
        double costPrice = double.tryParse(_costController.text) ?? 0;
        if (boxQty == 1) {
          if(costPrice > supplierPrice){
            return 'Cost price  GHS$costPrice \n is more than Supplier Price GHS$supplierPrice';
          }
          if(supplierPrice > retailPrice){
            return 'Supplier price  GHS$supplierPrice \n is more than Retail Price GHS$retailPrice';
          }
          return null;
        }

        final minSupplierPrice = unitCost * boxQty;
        if (supplierPrice < minSupplierPrice) {
          return 'Supplier Price GHS$supplierPrice must be more\n or equal to  (${minSupplierPrice.toStringAsFixed(2)})';
        }

        if (supplierPrice > boxPrice) {
          return 'Supplier Price must be less than \n or equal to Box Price';
        }
        return null;

      case 'supplierMinQty':
        final supplierQty = int.tryParse(value) ?? 0;
        if (supplierQty == 1) return null;
        return null;

      case 'halfBoxQty':
        final halfBoxQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;

        if (boxQty == 0) return null;

        final requiredHalfQty = (boxQty / 2).ceil();
        if (halfBoxQty > boxQty) {
          return 'Half Box Qty cannot exceed Box Qty';
        }
        if (halfBoxQty < requiredHalfQty) {
          return 'Half Box Qty must be at least $requiredHalfQty';
        }
        return null;

      case 'halfBoxPrice':
        final halfBoxPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        if (boxPrice == 0) return null;

        final requiredHalfPrice = boxPrice / 2;
        if (halfBoxPrice > boxPrice) {
          return 'Half Box Price cannot exceed Box Price';
        }
        if (halfBoxPrice < requiredHalfPrice) {
          return 'Half Box Price must be at least ${requiredHalfPrice.toStringAsFixed(2)}';
        }
        return null;

      case 'quarterQty':
        final quarterQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
        final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
        final packQty = int.tryParse(_packQtyController.text) ?? 0;

        if (boxQty == 0) return null;

        final requiredQuarterQty = (boxQty / 4).ceil();
        if (quarterQty > boxQty) {
          return 'Quarter Qty cannot exceed Box Qty';
        }
        if (quarterQty < requiredQuarterQty) {
          return 'Quarter Qty must be at least $requiredQuarterQty';
        }
        if (halfQty > 0 && quarterQty >= halfQty) {
          return 'Quarter Qty must be less than Half Qty';
        }
        if (packQty > 0 && quarterQty <= packQty) {
          return 'Quarter Qty must be greater than Pack Qty';
        }
        return null;

      case 'quarterPrice':
        final quarterPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final halfBoxPrice =
            double.tryParse(_halfboxprice_controller.text) ?? 0;

        if (boxPrice == 0) return null;

        final requiredQuarterPrice = boxPrice / 4;
        if (quarterPrice > boxPrice) {
          return 'Quarter Price cannot exceed Box Price';
        }
        if (quarterPrice < requiredQuarterPrice) {
          return 'Quarter Price must be at least ${requiredQuarterPrice.toStringAsFixed(2)}';
        }
        if (halfBoxPrice > 0 && quarterPrice >= halfBoxPrice) {
          return 'Quarter Price must be less than Half Box Price';
        }
        return null;

      case 'packQty':
        if (!_enableBoxPricing) return null;

        final packQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
        final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
        final quarterQty = int.tryParse(_quarterqty_controller.text) ?? 0;

        if (boxQty > 0 && packQty > 0 && boxQty % packQty != 0) {
          return 'Box Qty must be divisible by Pack Qty';
        }

        if (boxQty > 0 && packQty > boxQty) {
          return 'Pack Qty cannot exceed Box Qty';
        }

        if (halfQty > 0 && packQty >= halfQty) {
          return 'Pack Qty must be less than Half Qty';
        }

        if (quarterQty > 0 && packQty >= quarterQty) {
          return 'Pack Qty must be less than Quarter Qty';
        }

        final packUnitPrice = double.tryParse(_packprice_controller.text) ?? 0;
        final unitCost = double.tryParse(_costController.text) ?? 0;
        final totalPackPrice = packUnitPrice * boxQty;
        final totalUnitCost = unitCost * boxQty;

        if (totalPackPrice < totalUnitCost) {
          return 'Pack unit price × Box Qty must be ≥ Unit Cost × Box Qty';
        }
        return null;

      case 'packPrice':
        final packPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
        final packQty = double.tryParse(_packQtyController.text) ?? 0;
        final retailprice = double.tryParse(_retail_price.text) ?? 0;
        final unitcostprice =
            int.tryParse(_costController.text.toString()) ?? 0;

        if (boxQty == 0 || packQty == 0 || boxPrice == 0) return null;

        double unitboxprice = boxPrice / boxQty;
        final requiredPackPrice = packPrice / packQty;

        if (requiredPackPrice > retailprice ||
            requiredPackPrice < unitcostprice ||
            requiredPackPrice < unitboxprice) {
          return 'Please check Unit(box/cost/retail) price';
        }
        return null;

      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<Datafeed>().fetchproductcategory();
    });

      final d = widget.item;
      _nameController.text = d.name ?? '';
      _barcodeController.text = d.barcode ?? '';
      _costController.text = d.cp ?? '';


      _costController.text = d.cp;
      _supplierMinQtyController.text = d.sminqty;

      // Enable box pricing switch
      _enableBoxPricing = d.modemore == true;

      // ----- LOAD MODES -----
      final modes = d.modes as Map<String, dynamic>? ?? {};

      // Single
      final single = modes['single'] ?? {};
      _retail_price.text = single['rp'] ?? '';

      // Pack
      final pack = modes['pack'] ?? {};
      _packQtyController.text = pack['qty'] ?? '';
      _packprice_controller.text = pack['wp'] ?? '';

      // Quarter
      final quarter = modes['quarter'] ?? {};
      _quarterqty_controller.text = quarter['qty'] ?? '';
      _quarterprice_controller.text = quarter['wp'] ?? '';

      // Half
      final half = modes['half'] ?? {};
      _halfboxqty_controller.text = half['qty'] ?? '';
      _halfboxprice_controller.text = half['wp'] ?? '';

      // Carton (Full Box)
      final carton = modes['carton'] ?? {};
      _boxQtyController.text = carton['qty'] ?? '';
      _supplierPriceController.text = carton['sp'] ?? '';
      _wholesalePriceController.text = carton['wp'] ?? '';
      final int boxQty = int.tryParse(_boxQtyController.text) ?? 0;
      final double boxPrice =
          double.tryParse(_wholesalePriceController.text) ?? 0;
      if (boxQty > 1 && boxPrice > 0) {
        // quantities
        final int halfQty = (boxQty / 2).ceil();
        final int quarterQty = (boxQty / 4).ceil();

        // prices
        final double halfPrice = boxPrice / 2;
        final double quarterPrice = boxPrice / 4;

        _halfboxqty_controller.text = halfQty.toString();
        _quarterqty_controller.text = quarterQty.toString();

        _halfboxprice_controller.text = halfPrice.toStringAsFixed(2);
        _quarterprice_controller.text = quarterPrice.toStringAsFixed(2);
      }
      // pricingStep: 0 = none, 1 = half, 2 = quarter, 3 = pack
      int step = 0;
      if (modes.containsKey('half')) step = 1;
      if (modes.containsKey('quarter')) step = 2;
      if (modes.containsKey('pack')) step = 3;
      pricingStep = step;

      _enableBoxPricing = modes.isNotEmpty && (
      modes.containsKey('carton') ||
      modes.containsKey('half') ||
      modes.containsKey('quarter') ||
      modes.containsKey('pack'));
      _showBoxPricingSwitch = _enableBoxPricing;

      try {
        final boxQtyVal = int.tryParse(_boxQtyController.text) ?? 0;
        if (boxQtyVal == 1) {
          final retail = _retail_price.text;
          _wholesalePriceController.text = retail;
          _supplierPriceController.text = retail;
        }
      } catch (_) {}
    }


  void _clearAllFields() {
    // Reset form validation
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _barcodeController.clear();
      _costController.clear();
      _boxQtyController.clear();
      _halfboxqty_controller.clear();
      _quarterqty_controller.clear();
      _retail_price.clear();
      _packQtyController.clear();
      _supplierPriceController.clear();
      _wholesalePriceController.clear();
      _halfboxprice_controller.clear();
      _quarterprice_controller.clear();
      _packprice_controller.clear();
      _wholesaleMinQtyController.clear();
      _supplierMinQtyController.clear();

      // Reset pricing options
      pricingStep = 0;
      _enableBoxPricing = false;
      _showBoxPricingSwitch = false;


    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Consumer<Datafeed>(
      builder: (context, datafeed, child) {

        return Scaffold(
          backgroundColor: const Color(0xFF101624),
          appBar: AppBar(
            title: Text('${datafeed.company} -${datafeed.branch}'),
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width < 610
                        ? width * 0.9
                        : width < 1024
                        ? 500
                        : 900,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildField(
                            enabled: false,
                            _nameController,
                            'Item Name',
                            Icons.label,
                            onChanged: (v) {
                              _formKey.currentState!.validate();
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          child: _buildField(
                            _retail_price,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            'Retail Price',
                            Icons.attach_money,
                            isNumber: true,
                            validator: (v) => _validateField('retailPrice', v),
                            onChanged: (value) {
                              final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
                              if (boxQty == 1) {
                                //_enableBoxPricing
                                setState(() {
                                  _wholesalePriceController.text = value;
                                  _supplierPriceController.text = value;
                                });
                              }
                              _formKey.currentState?.validate();
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          child: _buildField(
                            _costController,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            'Unit Cost Price',
                            Icons.attach_money,
                            isNumber: true,
                            onChanged: (_) {
                              _formKey.currentState?.validate();
                            },
                            validator: (v) => _validateField('costPrice', v),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          child: _buildField(
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            _boxQtyController,
                            'Box quantity',
                            Icons.attach_money,
                            isNumber: true,
                            onChanged: (value) {
                              final qty = double.tryParse(value) ?? 0;
                              if (qty > 1) {
                                setState(() {
                                  _showBoxPricingSwitch = true;
                                  _enableBoxPricing = true;
                                  // auto calculate quantities
                                  _halfboxqty_controller.text = (qty / 2).ceil().toString();
                                  _quarterqty_controller.text = (qty / 4).ceil().toString();
                                });
                              } else if (qty == 1) {
                                setState(() {
                                  _showBoxPricingSwitch = true;
                                  _enableBoxPricing = true;

                                  // Sync prices: retail = wholesale = supplier
                                  final retailPrice = _retail_price.text;
                                  _wholesalePriceController.text = retailPrice;
                                  _supplierPriceController.text = retailPrice;
                                });
                              } else {
                                setState(() {
                                  _showBoxPricingSwitch = false;
                                  _enableBoxPricing = false;
                                  pricingStep = 0;
                                });
                              }
                              _formKey.currentState!.validate();
                            },
                            validator: (v) => _validateField('boxQty', v),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldWithEnabled(
                                onChanged: (val) {
                                  final price = double.tryParse(val) ?? 0;
                                  _halfboxprice_controller.text = (price / 2).toStringAsFixed(2);
                                  _quarterprice_controller.text = (price / 4).toStringAsFixed(2);
                                  _formKey.currentState?.validate();
                                },
                                _wholesalePriceController,
                                'Box Price',
                                Icons.attach_money,
                                isNumber: true,
                                // enabled: double.tryParse(_boxQtyController.text) != 1,
                                validator: (v) => _validateField('boxPrice', v),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFieldWithEnabled(
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                _supplierPriceController,
                                'Supplier Price',
                                Icons.attach_money,
                                isNumber: true,
                                onChanged: (v) {
                                  _formKey.currentState!.validate();
                                },
                                validator: (v) => _validateField('supplierPrice', v),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        SizedBox(
                          child: _buildField(
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            _supplierMinQtyController,
                            'Supplier Min Qty',
                            Icons.numbers,
                            isNumber: true,
                            onChanged: (value) {
                              _formKey.currentState?.validate();
                            },
                            validator: (v) =>
                                _validateField('supplierMinQty', v),
                          ),
                        ),
                        if (_enableBoxPricing) ...[
                          const SizedBox(height: 15),

                          /// HALF ROW
                          if (pricingStep >= 1)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    enabled: false,
                                    _halfboxqty_controller,
                                    'Half Box Qty',
                                    Icons.inventory,
                                    isNumber: true,
                                    validator: (v) =>
                                        _validateField('halfBoxQty', v),
                                    onChanged: (value) {
                                      //final qty = double.tryParse(value) ?? 0;
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    _halfboxprice_controller,
                                    'Half Box Price',
                                    Icons.attach_money,
                                    isNumber: true,
                                    validator: (v) =>
                                        _validateField('halfBoxPrice', v),
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22304A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Remove half pricing',
                                    padding: EdgeInsets.zero,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      size: 20,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(0xFF182232),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                          content: const Text(
                                            'Remove half-box pricing for this item? This cannot be undone.',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm != true) return;

                                      setState(() {
                                        pricingStep = 0;

                                        _halfboxqty_controller.clear();
                                        _halfboxprice_controller.clear();

                                        _quarterqty_controller.clear();
                                        _quarterprice_controller.clear();

                                        _packQtyController.clear();
                                        _packprice_controller.clear();
                                      });

                                      if (widget.item.id != null) {
                                        try {
                                         if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Half pricing removed'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to remove half pricing: $e'), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                          if (pricingStep >= 1) const SizedBox(height: 15),

                          /// QUARTER ROW
                          if (pricingStep >= 2)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    enabled: false,
                                    _quarterqty_controller,
                                    'Quarter Qty',
                                    Icons.inventory,
                                    isNumber: true,
                                    validator: (v) =>
                                        _validateField('quarterQty', v),
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    _quarterprice_controller,
                                    'Quarter Price',
                                    Icons.attach_money,
                                    isNumber: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      final quarterPrice = double.tryParse(v) ?? 0;
                                      final boxPrice = double.tryParse(
                                            _wholesalePriceController.text,
                                          ) ?? 0;
                                      final halfBoxPrice = double.tryParse(
                                        _halfboxprice_controller.text,
                                      ) ?? 0;

                                      if (boxPrice == 0) return null;

                                      final requiredQuarterPrice = boxPrice / 4;
                                      if (quarterPrice > boxPrice) {
                                        return 'Quarter Price cannot exceed Box Price';
                                      }
                                      if (quarterPrice < requiredQuarterPrice) {
                                        return 'Quarter Price must be at least ${requiredQuarterPrice.toStringAsFixed(2)}';
                                      }
                                      if (halfBoxPrice > 0 &&
                                          quarterPrice >= halfBoxPrice) {
                                        return 'Quarter Price must be less than Half Box Price';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22304A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Remove quarter pricing',
                                    padding: EdgeInsets.zero,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      size: 20,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(0xFF182232),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                          content: const Text(
                                            'Remove quarter pricing for this item? This cannot be undone.',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm != true) return;

                                      setState(() {
                                        pricingStep = 1;
                                        _quarterqty_controller.clear();
                                        _quarterprice_controller.clear();
                                        _packQtyController.clear();
                                        _packprice_controller.clear();
                                      });

                                      if (widget.item.id != null) {
                                        try {

                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Quarter pricing removed'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to remove quarter pricing: $e'), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                          if (pricingStep >= 2) const SizedBox(height: 15),

                          /// PACK ROW
                          if (pricingStep >= 3)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    _packQtyController,
                                    'Pack Qty',
                                    Icons.inventory,
                                    isNumber: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (!_enableBoxPricing) return null;

                                      final packQty = int.tryParse(v) ?? 0;
                                      final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
                                      final halfQty = int.tryParse( _halfboxqty_controller.text,) ?? 0;
                                      final quarterQty = int.tryParse(_quarterqty_controller.text, ) ?? 0;

                                      // Quantity rules
                                      if (boxQty > 0 &&  packQty > 0 && boxQty % packQty != 0) {
                                        return 'Box Qty must be divisible by Pack Qty';
                                      }

                                      if (boxQty > 0 && packQty > boxQty) {
                                        return 'Pack Qty cannot exceed Box Qty';
                                      }

                                      if (halfQty > 0 && packQty >= halfQty) {
                                        return 'Pack Qty must be less than Half Qty';
                                      }

                                      if (quarterQty > 0 &&
                                          packQty >= quarterQty) {
                                        return 'Pack Qty must be less than Quarter Qty';
                                      }

                                      // Price rule: pack unit price * total box qty ≥ unit cost * box qty
                                      final packUnitPrice = double.tryParse(_packprice_controller.text,) ?? 0;
                                      final unitCost = double.tryParse(_costController.text) ?? 0;

                                      final totalPackPrice = packUnitPrice *  boxQty; // total revenue from pack
                                      final totalUnitCost = unitCost * boxQty; // total cost for the box

                                      if (totalPackPrice < totalUnitCost) {
                                        return 'Pack unit price × Box Qty must be ≥ Unit Cost × Box Qty';
                                      }

                                      return null; // valid
                                    },
                                    onChanged: (v) {
                                      _formKey.currentState!.validate();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildField(
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    _packprice_controller,
                                    'Pack Price',
                                    Icons.attach_money,
                                    isNumber: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';

                                      final packPrice = double.tryParse(v) ?? 0;
                                      final boxPrice =
                                          double.tryParse(
                                            _wholesalePriceController.text,
                                          ) ??
                                              0;
                                      final boxQty =
                                          double.tryParse(
                                            _boxQtyController.text,
                                          ) ??
                                              0;
                                      final packQty =
                                          double.tryParse(
                                            _packQtyController.text,
                                          ) ??
                                              0;
                                      final retailprice =
                                          double.tryParse(_retail_price.text) ??
                                              0;
                                      final unitcostprice =
                                          int.tryParse(
                                            _costController.text.toString(),
                                          ) ??
                                              0;

                                      if (boxQty == 0 ||  packQty == 0 || boxPrice == 0)
                                        return null;

                                      final packsPerBox = boxQty / packQty;
                                      final totalFromPacks = packsPerBox * packPrice;
                                      double unitboxprice = boxPrice / boxQty;

                                      final requiredPackPrice = packPrice / packQty;

                                      if (requiredPackPrice > retailprice ||
                                          requiredPackPrice < unitcostprice ||
                                          requiredPackPrice < unitboxprice) {
                                        return 'Please check Unit(box/cost/retail) price ';
                                      }

                                      return null;
                                    },
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22304A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Remove pack pricing',
                                    padding: EdgeInsets.zero,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      size: 20,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(0xFF182232),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                          content: const Text(
                                            'Remove pack pricing for this item? This cannot be undone.',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm != true) return;

                                      setState(() {
                                        pricingStep = 2;
                                        _packQtyController.clear();
                                        _packprice_controller.clear();
                                      });

                                      if (widget.item.id != null) {
                                        try {


                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Pack pricing removed'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to remove pack pricing: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              backgroundColor: Colors.blue,
                              shape:RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)
                              )
                            ),
                            onPressed: _loading ? null : () async {
                             if (!_formKey.currentState!.validate())
                              return;
                              setState(() => _loading = true);
                              try {
                                Map<String, dynamic> modesMap = Map<String, dynamic>.from(widget.item?.modes ?? {});
                                modesMap["single"] = {
                                  'name': 'Single',
                                  'sp': _retail_price.text.trim(),
                                  'wp': _retail_price.text.trim(),
                                  'rp': _retail_price.text.trim(),
                                  'qty': '1',
                                };

                                double boxqty = _boxQtyController.text.isNotEmpty ? double.parse(_boxQtyController.text): 0;
                                if (boxqty >= 2) {
                                  modesMap["carton"] = {
                                    'name': 'carton',
                                    'sp': _supplierPriceController.text.trim(),
                                    'wp': _wholesalePriceController.text.trim(),
                                    'rp': _wholesalePriceController.text.trim(),
                                    'qty': _boxQtyController.text.trim(),
                                  };
                                } else {
                                  modesMap.remove("carton");
                                }

                                if (_enableBoxPricing) {
                                  // HALF
                                  if (pricingStep >= 1 &&
                                      _halfboxqty_controller.text.isNotEmpty &&
                                      _halfboxprice_controller.text.isNotEmpty) {
                                    modesMap["half"] = {
                                      'name': 'Half carton',
                                      'sp': _halfboxprice_controller.text.trim(),
                                      'wp': _halfboxprice_controller.text.trim(),
                                      'rp': _halfboxprice_controller.text.trim(),
                                      'qty': _halfboxqty_controller.text.trim(),
                                    };
                                  } else {
                                    modesMap.remove("half");
                                  }

                                  // QUARTER
                                  if (pricingStep >= 2 &&
                                      _quarterqty_controller.text.isNotEmpty &&
                                      _quarterprice_controller.text.isNotEmpty) {
                                    modesMap["quarter"] = {
                                      'name': 'Quarter carton',
                                      'sp': _quarterprice_controller.text.trim(),
                                      'wp': _quarterprice_controller.text.trim(),
                                      'rp': _retail_price.text.trim(),
                                      'qty': _quarterqty_controller.text.trim(),
                                    };
                                  } else {
                                    modesMap.remove("quarter");
                                  }

                                  // PACK
                                  if (pricingStep >= 3 &&
                                      _packQtyController.text.isNotEmpty &&
                                      _packprice_controller.text.isNotEmpty) {
                                    modesMap["pack"] = {
                                      'name': 'Pack',
                                      'sp': _packprice_controller.text.trim(),
                                      'wp': _packprice_controller.text.trim(),
                                      'rp': _retail_price.text.trim(),
                                      'qty': _packQtyController.text.trim(),
                                    };
                                  } else {
                                    modesMap.remove("pack");
                                  }
                                } else {
                                  modesMap.remove("half");
                                  modesMap.remove("quarter");
                                  modesMap.remove("pack");
                                }

                           // print('Updating item ${widget.item.id} with modes: $modesMap');

                                await db.collection('itemsreg').doc(widget.item.id).update({
                                  widget.item.id: modesMap,
                                  '${widget.branchId}wminqty': _wholesaleMinQtyController.text.trim(),
                                  '${widget.branchId}bcp': _costController.text.trim(),
                                  '${widget.branchId}bsminqty': _supplierMinQtyController.text.trim(),
                                  '${widget.branchId}branchupupdatedat': DateTime.now(),
                                  '${widget.branchId}branchupdatedby': widget.staff!,
                                });

                                _clearAllFields();
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  Navigator.pushNamed(context, Routes.branchprice);
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of( context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Item updated successfully!',),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                }

                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }

                              setState(() => _loading = false);
                            },
                            child: _loading ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text('Update Item'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:
          _enableBoxPricing && double.tryParse(_boxQtyController.text) != 1
              ? Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'add_pricing',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    setState(() {
                      if (pricingStep < 3) pricingStep++;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'toggle_pricing',
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    setState(() => _enableBoxPricing = false);
                  },
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          )
              : null,
        );
      },
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
