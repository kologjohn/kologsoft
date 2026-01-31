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
  final String cp;
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
  final String pcategory;
  @HiveField(12)
  final String warehouse;
  @HiveField(13)
  final String openingstock;
  @HiveField(14)
  final String company;
  @HiveField(15)
  final String companyid;
  @HiveField(16)
  final DateTime createdat;
  @HiveField(17)
  final DateTime? updatedat;
  @HiveField(18)
  final String? updatedby;
  @HiveField(19)
  final String imageurl;
  @HiveField(20)
  final Map<String, dynamic> modes;
  @HiveField(21)
  final String wminqty;
  @HiveField(22)
  final String sminqty;
  @HiveField(23)
  final String staff;
  @HiveField(24)
  final bool modemore;
  @HiveField(25)
  final DateTime? deletedat;
  @HiveField(26)
  final String? deletedby;


  ItemModel({
    required this.id,
    required this.no,
    required this.name,
    required this.barcode,
    required this.cp,
    required this.retailmarkup,
    required this.wholesalemarkup,
    required this.retailprice,
    required this.wholesaleprice,
    required this.producttype,
    required this.pricingmode,
    required this.pcategory,
    required this.warehouse,
    required this.openingstock,
    required this.company,
    required this.companyid,
    required this.createdat,
     this.updatedby,
    required this.imageurl,
    required this.modes,
     this.updatedat,
    required this.wminqty,
    required this.sminqty,
    required this.staff,
    required this.modemore,
     this.deletedat,
     this.deletedby,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no': no,
      'name': name,
      'barcode': barcode,
      'cp': cp,
      'retailmarkup': retailmarkup,
      'wholesalemarkup': wholesalemarkup,
      'retailprice': retailprice,
      'wholesaleprice': wholesaleprice,
      'producttype': producttype,
      'pricingmode': pricingmode,
      'pcategory': pcategory,
      'warehouse': warehouse,
      'openingstock': openingstock,
      'company': company,
      'companyid': companyid,
      'createdat': createdat,
      'updatedat': updatedat,
      'updatedby': updatedby,
      'image': imageurl,
      'modes': modes,
    };
  }

  factory ItemModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return ItemModel(
      id: doc.id  ?? '',
      no: doc.id  ?? '',
      name: d['name'] ?? '',
      barcode: d['barcode'] ?? '',
      cp: d['cp'] ?? '0',
      retailmarkup: d['retailmarkup'] ?? '0',
      wholesalemarkup: d['wholesalemarkup'] ?? '0',
      retailprice: d['retailprice'] ?? '0',
      wholesaleprice: d['wholesaleprice'] ?? '0',
      producttype: d['producttype'] ?? 'product',
      pricingmode: d['pricingmode'] ?? '',
      pcategory: d['pcategory'] ?? '',
      warehouse: d['warehouse'] ?? '',
      openingstock: d['openingstock'] ?? '0',
      company: d['company'] ?? '',
      companyid: d['companyid'] ?? '',
      imageurl: d['image'] ?? '',
      createdat: d['createdat'] != null ? (d['createdat'] as Timestamp).toDate(): DateTime.now(),
      updatedby: d['updatedby'] ,
      modes: d['modes'] is Map ? Map<String, dynamic>.from(d['modes']) : {},
      wminqty: d['wminqty'],
      sminqty: d['sminqty'],
      staff: d['staff'],
      modemore: d['modemore'] == true,
      deletedat: d['deletedat'] != null ? (d['deletedat'] as Timestamp).toDate() : null,
      deletedby: d['deletedby'],
    );
  }

  factory ItemModel.fromMap(Map<String, dynamic> d) {
    return ItemModel(
      id: d['id'] ?? '',
      no: d['no'] ?? '',
      name: d['name'] ?? '',
      barcode: d['barcode'] ?? '',
      cp: d['cp'] ?? '0',
      retailmarkup: d['retailmarkup'] ?? '0',
      wholesalemarkup: d['wholesalemarkup'] ?? '0',
      retailprice: d['retailprice'] ?? '0',
      wholesaleprice: d['wholesaleprice'] ?? '0',
      producttype: d['producttype'] ?? 'product',
      pricingmode: d['pricingmode'] ?? '',
      pcategory: d['pcategory'] ?? '',
      warehouse: d['warehouse'] ?? '',
      openingstock: d['openingstock'] ?? '0',
      company: d['company'] ?? '',
      companyid: d['companyid'] ?? '',
      imageurl: d['image'] ?? '',
      modes: d['modes'] is Map ? Map<String, dynamic>.from(d['modes']) : {},
      wminqty: d['wminqty'] ?? '',
      sminqty: d['sminqty'] ?? '',
      staff: d['staff'] ?? '',
      modemore: d['modemore'] == true,
      deletedat: d['deletedat'] is Timestamp
          ? (d['deletedat'] as Timestamp).toDate()
          : d['deletedat'] is DateTime
          ? d['deletedat']
          : null,
      deletedby: d['deletedby'] ?? '',
      createdat: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : d['createdAt'] is DateTime
          ? d['createdAt']
          : DateTime.now(),
    );
  }
}
