class BranchModel {
  String id = '';
  String branchname;
  String branchtype;
  String branchcontact;
  String companyid;
  String companyemail;
  DateTime? date;
  String staff;

  BranchModel({
    this.id = '',
    this.branchname = '',
    this.branchtype = '',
    this.branchcontact = '',
    this.staff = '',
    this.companyid = '',
    this.companyemail = '',
    this.date,
});

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'branchName': branchname,
      'branchType': branchtype,
      'branchContact': branchcontact,
      'staff': staff,
      'companyId': companyid,
      'companyEmail': companyemail,
      'date': date?.toIso8601String(),
    };
  }
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      branchname: json['branchName'] ?? '',
      branchtype: json['branchType'] ?? '',
      branchcontact: json['branchContact'] ?? '',
      staff: json['staff'] ?? '',
      companyid: json['companyId'] ?? '',
      companyemail: json['companyEmail'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : null,
    );
  }

}