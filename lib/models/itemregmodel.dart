import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class ItemModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String no;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String barcode;
  @HiveField(4)
  final String costprice;
  @HiveField(5)
  final String retailmarkup;
  @HiveField(6)
  final String wholesalemarkup;
  @HiveField(7)
  final String retailprice;
  @HiveField(8)
  final String wholesaleprice;
  @HiveField(9)
  final String producttype;
  @HiveField(10)
  final String pricingmode;
  @HiveField(11)
  final String productcategory;
  @HiveField(12)
  final String warehouse;
  @HiveField(13)
  final String openingstock;
  @HiveField(14)
  final String company;
  @HiveField(15)
  final String companyid;
  @HiveField(16)
  final DateTime createdAt;
  @HiveField(17)
  final DateTime updatedAt;
  @HiveField(18)
  final String updatedBy;
  @HiveField(19)
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

  factory ItemModel.fromMap(Map<String, dynamic> d) {
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
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : d['createdAt'] is DateTime
          ? d['createdAt']
          : DateTime.now(),
      updatedAt: d['updatedAt'] is Timestamp
          ? (d['updatedAt'] as Timestamp).toDate()
          : d['updatedAt'] is DateTime
          ? d['updatedAt']
          : DateTime.now(),
      updatedBy: d['updatedBy'] ?? '',
      imageurl: d['image'] ?? '',
    );
  }
}
