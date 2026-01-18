import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String? id;
  final String name;
  final String barcode;
  final String? barcodeurl;
  final String? qrcodeurl;
  final String? imageurl;

  // Box-level fields
  final int boxqty;
  final String boxretailprice;
  final String boxwholesalesprice;
  final String boxsupplierprice;
  final bool boxpricingenabled;

  // Nested pricing (half / quarter / pack etc.)
  final Map<String, dynamic>? pricing;

  // Other fields
  final String? costprice;
  final String? producttype;
  final String? pricingmode;
  final String? productcategory;
  final String? wholesaleminqty;
  final String? supplierminqty;

  // Metadata
  final String? company;
  final String? companyid;
  final String? staff;
  final String? updateby;
  final DateTime? updatedat;
  final String? deleteby;
  final DateTime? deletedat;

  ItemModel({
    this.id,
    required this.name,
    required this.barcode,
    this.barcodeurl,
    this.qrcodeurl,
    this.imageurl,
    required this.boxqty,
    this.boxretailprice = '',
    this.boxwholesalesprice = '',
    this.boxsupplierprice = '',
    this.boxpricingenabled = false,
    this.pricing,
    this.costprice,
    this.producttype,
    this.pricingmode,
    this.productcategory,
    this.wholesaleminqty,
    this.supplierminqty,
    this.company,
    this.companyid,
    this.staff,
    this.updateby,
    this.updatedat,
    this.deleteby,
    this.deletedat,
  });

  // ---------- FROM FIRESTORE ----------
  factory ItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ItemModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      barcode: (map['barcode'] ?? '').toString(),
      barcodeurl: map['barcodeurl']?.toString(),
      qrcodeurl: map['qrcodeurl']?.toString(),
      imageurl: map['imageurl']?.toString(),

      boxqty: int.tryParse(map['boxqty']?.toString() ?? '0') ?? 0,
      boxretailprice: map['boxretailprice']?.toString() ?? '',
      boxwholesalesprice: map['boxwholesalesprice']?.toString() ?? '',
      boxsupplierprice: map['boxsupplierprice']?.toString() ?? '',
      boxpricingenabled: map['boxpricingenabled'] ?? false,

      pricing: map['pricing'] as Map<String, dynamic>?,

      costprice: map['costprice']?.toString(),
      producttype: map['producttype']?.toString(),
      pricingmode: map['pricingmode']?.toString(),
      productcategory: map['productcategory']?.toString(),
      wholesaleminqty: map['wholesaleminqty']?.toString(),
      supplierminqty: map['supplierminqty']?.toString(),

      company: map['company']?.toString(),
      companyid: map['companyid']?.toString(),
      staff: map['staff']?.toString(),

      updateby: map['updateby']?.toString(),
      updatedat: map['updatedat'] is Timestamp
          ? (map['updatedat'] as Timestamp).toDate()
          : null,

      deleteby: map['deleteby']?.toString(),
      deletedat: map['deletedat'] is Timestamp
          ? (map['deletedat'] as Timestamp).toDate()
          : null,
    );
  }

  // ---------- TO FIRESTORE ----------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'barcodeurl': barcodeurl,
      'qrcodeurl': qrcodeurl,
      'imageurl': imageurl,

      'boxqty': boxqty,
      'boxretailprice': boxretailprice,
      'boxwholesalesprice': boxwholesalesprice,
      'boxsupplierprice': boxsupplierprice,
      'boxpricingenabled': boxpricingenabled,

      'pricing': pricing,

      'costprice': costprice,
      'producttype': producttype,
      'pricingmode': pricingmode,
      'productcategory': productcategory,
      'wholesaleminqty': wholesaleminqty,
      'supplierminqty': supplierminqty,

      'company': company,
      'companyid': companyid,
      'staff': staff,

      'updateby': updateby,
      'updatedat': updatedat == null ? null : Timestamp.fromDate(updatedat!),

      'deleteby': deleteby,
      'deletedat': deletedat == null ? null : Timestamp.fromDate(deletedat!),
    };
  }

  // ---------- COPY ----------
  ItemModel copyWith({
    String? id,
    String? name,
    String? barcode,
    String? barcodeurl,
    String? qrcodeurl,
    String? imageurl,
    int? boxqty,
    String? boxretailprice,
    String? boxwholesalesprice,
    String? boxsupplierprice,
    bool? boxpricingenabled,
    Map<String, dynamic>? pricing,
    String? costprice,
    String? producttype,
    String? pricingmode,
    String? productcategory,
    String? wholesaleminqty,
    String? supplierminqty,
    String? company,
    String? companyid,
    String? staff,
    String? updateby,
    DateTime? updatedat,
    String? deleteby,
    DateTime? deletedat,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      barcodeurl: barcodeurl ?? this.barcodeurl,
      qrcodeurl: qrcodeurl ?? this.qrcodeurl,
      imageurl: imageurl ?? this.imageurl,
      boxqty: boxqty ?? this.boxqty,
      boxretailprice: boxretailprice ?? this.boxretailprice,
      boxwholesalesprice: boxwholesalesprice ?? this.boxwholesalesprice,
      boxsupplierprice: boxsupplierprice ?? this.boxsupplierprice,
      boxpricingenabled: boxpricingenabled ?? this.boxpricingenabled,
      pricing: pricing ?? this.pricing,
      costprice: costprice ?? this.costprice,
      producttype: producttype ?? this.producttype,
      pricingmode: pricingmode ?? this.pricingmode,
      productcategory: productcategory ?? this.productcategory,
      wholesaleminqty: wholesaleminqty ?? this.wholesaleminqty,
      supplierminqty: supplierminqty ?? this.supplierminqty,
      company: company ?? this.company,
      companyid: companyid ?? this.companyid,
      staff: staff ?? this.staff,
      updateby: updateby ?? this.updateby,
      updatedat: updatedat ?? this.updatedat,
      deleteby: deleteby ?? this.deleteby,
      deletedat: deletedat ?? this.deletedat,
    );
  }
}
