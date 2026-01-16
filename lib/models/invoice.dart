enum PaymentStatus { pending, paid, failed, refunded }

class Invoice {
  final String id;
  final String workplaceId;
  final String invoiceNumber;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final PaymentStatus status;
  final String? bankReference;
  final DateTime? paymentDate;
  final String description;

  Invoice({
    required this.id,
    required this.workplaceId,
    required this.invoiceNumber,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.bankReference,
    this.paymentDate,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workplaceId': workplaceId,
      'invoiceNumber': invoiceNumber,
      'amount': amount,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.index,
      'bankReference': bankReference,
      'paymentDate': paymentDate?.toIso8601String(),
      'description': description,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      workplaceId: json['workplaceId'],
      invoiceNumber: json['invoiceNumber'],
      amount: json['amount'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      status: PaymentStatus.values[json['status']],
      bankReference: json['bankReference'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      description: json['description'],
    );
  }
}
