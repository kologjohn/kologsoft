// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProductModel {
//   String id;                // unique product ID (e.g., p001)
//   String name;              // product/service name
//   String barcode;           // barcode string
//   String costprice;         // cost price as string
//   String sellingprice;      // selling price as string
//   String producttype;       // 'service' or 'product'
//   String warehouse;         // warehouse location/name
//   String productcategory;   // category
//   String openingstock;      // opening stock as string
//   String retailmarkup;      // retail markup % as string
//   String wholesalemarkup;   // wholesale markup % as string
//   String retailprice;       // calculated retail price as string
//   String pricingmode;       // 'single' or 'multiple'
//   String company;           // company name
//   String companyid;         // normalized company ID
//   String createdby;         // staff/user who created
//   String updatedby;         // staff/user who updated
//   String createdat;         // creation timestamp as string
//   String updatedat;         // last updated timestamp as string
//
//   ProductModel({
//     required this.id,
//     required this.name,
//     required this.barcode,
//     required this.costprice,
//     required this.sellingprice,
//     required this.producttype,
//     required this.warehouse,
//     required this.productcategory,
//     required this.openingstock,
//     required this.retailmarkup,
//     required this.wholesalemarkup,
//     required this.retailprice,
//     required this.pricingmode,
//     required this.company,
//     required this.companyid,
//     required this.createdby,
//     required this.updatedby,
//     required this.createdat,
//     required this.updatedat,
//   });
//
//   // Convert to Map for Firestore, everything as string
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id.toLowerCase(),
//       'name': name.toLowerCase(),
//       'barcode': barcode.toLowerCase(),
//       'costprice': costprice,
//       'sellingprice': sellingprice,
//       'producttype': producttype.toLowerCase(),
//       'warehouse': warehouse.toLowerCase(),
//       'productcategory': productcategory.toLowerCase(),
//       'openingstock': openingstock,
//       'retailmarkup': retailmarkup,
//       'wholesalemarkup': wholesalemarkup,
//       'retailprice': retailprice,
//       'pricingmode': pricingmode.toLowerCase(),
//       'company': company.toLowerCase(),
//       'companyid': companyid.toLowerCase(),
//       'createdby': createdby,
//       'updatedby': updatedby,
//       'createdat': createdat,
//       'updatedat': updatedat,
//     };
//   }
//
//   // Factory constructor from Firestore map
//   factory ProductModel.fromMap(Map<String, dynamic> map) {
//     return ProductModel(
//       id: (map['id'] ?? '').toString(),
//       name: (map['name'] ?? '').toString(),
//       barcode: (map['barcode'] ?? '').toString(),
//       costprice: (map['costprice'] ?? '0').toString(),
//       sellingprice: (map['sellingprice'] ?? '0').toString(),
//       producttype: (map['producttype'] ?? '').toString(),
//       warehouse: (map['warehouse'] ?? '').toString(),
//       productcategory: (map['productcategory'] ?? '').toString(),
//       openingstock: (map['openingstock'] ?? '0').toString(),
//       retailmarkup: (map['retailmarkup'] ?? '0').toString(),
//       wholesalemarkup: (map['wholesalemarkup'] ?? '0').toString(),
//       retailprice: (map['retailprice'] ?? '0').toString(),
//       pricingmode: (map['pricingmode'] ?? '').toString(),
//       company: (map['company'] ?? '').toString(),
//       companyid: (map['companyid'] ?? '').toString(),
//       createdby: (map['createdby'] ?? '').toString(),
//       updatedby: (map['updatedby'] ?? '').toString(),
//       createdat: map['createdat'] != null
//           ? (map['createdat'] is Timestamp
//           ? (map['createdat'] as Timestamp).toDate().toIso8601String()
//           : map['createdat'].toString())
//           : DateTime.now().toIso8601String(),
//       updatedat: map['updatedat'] != null
//           ? (map['updatedat'] is Timestamp
//           ? (map['updatedat'] as Timestamp).toDate().toIso8601String()
//           : map['updatedat'].toString())
//           : DateTime.now().toIso8601String(),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String no; // unique ID like KS00X
  final String name;
  final String barcode;
  final String costprice; // stored as string
  final String retailmarkup; // stored as string
  final String wholesalemarkup; // stored as string
  final String retailprice; // stored as string
  final String wholesaleprice; // stored as string
  final String producttype; // "product" or "service"
  final String pricingmode; // dropdown from firestore
  final String productcategory; // dropdown from firestore
  final String warehouse; // dropdown from firestore
  final String openingstock; // string
  final String company;
  final String companyid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  ItemModel({
    required this.id,
    required this.no,
    required this.name,
    required this.barcode,
    required this.costprice,
    required this.retailmarkup,
    required this.wholesalemarkup,
    required this.retailprice,
    required this.wholesaleprice,
    required this.producttype,
    required this.pricingmode,
    required this.productcategory,
    required this.warehouse,
    required this.openingstock,
    required this.company,
    required this.companyid,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no': no,
      'name': name,
      'barcode': barcode,
      'costprice': costprice,
      'retailmarkup': retailmarkup,
      'wholesalemarkup': wholesalemarkup,
      'retailprice': retailprice,
      'wholesaleprice': wholesaleprice,
      'producttype': producttype,
      'pricingmode': pricingmode,
      'productcategory': productcategory,
      'warehouse': warehouse,
      'openingstock': openingstock,
      'company': company,
      'companyid': companyid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }

  factory ItemModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: d['id'] ?? '',
      no: d['no'] ?? '',
      name: d['name'] ?? '',
      barcode: d['barcode'] ?? '',
      costprice: d['costprice'] ?? '0',
      retailmarkup: d['retailmarkup'] ?? '0',
      wholesalemarkup: d['wholesalemarkup'] ?? '0',
      retailprice: d['retailprice'] ?? '0',
      wholesaleprice: d['wholesaleprice'] ?? '0',
      producttype: d['producttype'] ?? 'product',
      pricingmode: d['pricingmode'] ?? '',
      productcategory: d['productcategory'] ?? '',
      warehouse: d['warehouse'] ?? '',
      openingstock: d['openingstock'] ?? '0',
      company: d['company'] ?? '',
      companyid: d['companyid'] ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
      updatedBy: d['updatedBy'] ?? '',
    );
  }
}
