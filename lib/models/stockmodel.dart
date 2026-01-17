  class StockModel {
  String id;
  String stockid;
  String invoicenumber;
  String waybillnumber;
  String suppliername;
  String supplierid;
  String branchname;
  String branchid;
  String itemname;
  String itembarcode;
  String stockingmode;
  String itemcategory;
  String producttype;
  String companyid;
  DateTime date;
  String? updatedby;
  DateTime? updatedat;
  String? deletedby;
  DateTime? deletedat;
  String staff;

  StockModel({
    required this.id,
    required this.stockid,
    required this.invoicenumber,
    required this.waybillnumber,
    required this.suppliername,
    required this.supplierid,
    required this.branchname,
    required this.branchid,
    required this.itemname,
    required this.itembarcode,
    required this.stockingmode,
    required this.itemcategory,
    required this.producttype,
    required this.companyid,
    required this.date,
    this.updatedby,
    this.deletedby,
    required this.staff,
    required this.updatedat,
    required this.deletedat,

  });

  Map<String, dynamic> toMap (){
    return {
      'id': id,
      'stockid': stockid,
      'invoicenumber': invoicenumber,
      'waybillnumber': waybillnumber,
      'suppliername': suppliername,
      'supplierid': supplierid,
      'branchName': branchname,
      'branchId': branchid,
      'itemname': itemname,
      'itembarcode': itembarcode,
      'stockingmode': stockingmode,
      'itemcategory': itemcategory,
      'producttype': producttype,
      'companyId': companyid,
      'date': date.toIso8601String(),
      'updatedby': updatedby,
      'updatedat': updatedat,
      'deletedby': deletedby,
      'deletedat': deletedat,
      'staff': staff,
      'created_at': DateTime.now(),
    };
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] ?? '',
      stockid: json['stockid'] ?? '',
      invoicenumber: json['invoicenumber'] ?? '',
      waybillnumber: json['waybillnumber'] ?? '',
      suppliername: json['suppliername'] ?? '',
      supplierid: json['supplierid'] ?? '',
      branchname: json['branchName'] ?? '',
      branchid: json['branchId'] ?? '',
      itemname: json['itemname'] ?? '',
      itembarcode: json['itembarcode'] ?? '',
      stockingmode: json['stockingmode'] ?? '',
      itemcategory: json['itemcategory'] ?? '',
      producttype: json['producttype'] ?? '',
      companyid: json['companyId'] ?? '',
      date: json['date'],
      updatedby: json['updatedby'] ?? '',
      updatedat: json['updatedat'] ?? '',
      deletedby: json['deletedby'] ?? '',
      deletedat: json['deletedat'] ?? '',
      staff: json['staff'] ?? '',
    );
  }

}