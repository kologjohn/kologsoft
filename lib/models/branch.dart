class BranchModel {
  String id = '';
  String branchname;
  String branchtype;
  String branchcontact;
  String companyid;
  String companyemail;
  String updatedby;
  DateTime? date;
  DateTime? updatedat;
  String staff;


  BranchModel({
    this.id = '',
    this.branchname = '',
    this.branchtype = '',
    this.branchcontact = '',
    this.updatedby = '',
    this.staff = '',
    this.companyid = '',
    this.companyemail = '',
    this.date,
    this.updatedat
});

  Map<String, dynamic> toMap (){
    return {
      'id': id,
      'branchName': branchname,
      'branchType': branchtype,
      'branchContact': branchcontact,
      'updatedBy': updatedby,
      'staff': staff,
      'companyId': companyid,
      'companyEmail': companyemail,
      'date': date?.toIso8601String(),
      'updatedAt': updatedat?.toIso8601String(),
    };
  }
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      branchname: json['branchName'] ?? '',
      branchtype: json['branchType'] ?? '',
      updatedby: json['updatedBy'] ?? '',
      branchcontact: json['branchContact'] ?? '',
      staff: json['staff'] ?? '',
      companyid: json['companyId'] ?? '',
      companyemail: json['companyEmail'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : null,
      updatedat: json['updatedat'] != null ? DateTime.parse(json['updatedat']) : null,
    );
  }

}