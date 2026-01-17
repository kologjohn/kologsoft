class CustomerRegModel {
  String id;
  String branchname;
  String branchid;
  String name;
  String contact;
  String customertype;
  String? creditlimit;
  String? paymentduration;
  String companyid;
  DateTime date;
  String? updatedby;
  DateTime? updatedat;
  String? deletedby;
  DateTime? deletedat;
  String staff;

  CustomerRegModel({
    required this.id,
    required this.branchname,
    required this.branchid,
    required this.name,
    required this.contact,
    required this.customertype,
    this.creditlimit,
    this.paymentduration,
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
      'branchName': branchname,
      'branchId': branchid,
      'name': name,
      'contact': contact,
      'customertype': customertype,
      'creditlimit': creditlimit,
      'paymentduration': paymentduration,
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
  factory CustomerRegModel.fromJson(Map<String, dynamic> json) {
    return CustomerRegModel(
      id: json['id'] ?? '',
      branchname: json['branchName'] ?? '',
      branchid: json['branchId'] ?? '',
      name: json['contact'] ?? '',
      contact: json['contact'] ?? '',
      customertype: json['customertype'] ?? '',
      creditlimit: json['creditlimit'] ?? '',
      paymentduration: json['paymentduration'] ?? '',
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