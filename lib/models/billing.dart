class BillingModel {
  String itemName;
  String id;
  String category;
  String billingType;
  double amount;
  int selectedYear;
  String staff;
  DateTime dateCreated;

  BillingModel({
    this.itemName = '',
    this.id = '',
    this.category = '',
    this.billingType = '',
    double? amount,
    int? selectedYear,
    this.staff = '',
    DateTime? dateCreated,
  })  : this.amount = amount ?? 0,
        this.selectedYear = selectedYear ?? DateTime.now().year,
        this.dateCreated = dateCreated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'revenueitem': itemName,
      'workspaceclass': category,
      'id': id,
      'billingtype': billingType,
      'amount': amount,
      'year': selectedYear,
      'staff': staff,
      'datecreated': dateCreated,
    };
  }
}
