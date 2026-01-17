
import 'package:cloud_firestore/cloud_firestore.dart';
class ItemModel {
  final String id;
  final String no;
  final String name;
  final String barcode;
  final String costprice;
  final String retailmarkup;
  final String wholesalemarkup;
  final String retailprice;
  final String wholesaleprice;
  final String producttype;
  final String pricingmode;
  final String productcategory;
  final String warehouse;
  final String openingstock;
  final String company;
  final String companyid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;
  final String imageurl;

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
    required this.imageurl,
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
      'image': imageurl,
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
      imageurl: d['image'] ?? '',
    );
  }
}
