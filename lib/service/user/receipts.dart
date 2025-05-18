class ReceiptModel {
  double amount;
  String email;
  String paidAt;
  String type;

  ReceiptModel({
    required this.amount,
    required this.email,
    required this.paidAt,
    required this.type,
  });

  factory ReceiptModel.fromMap(Map<String, dynamic> map) {
    return ReceiptModel(
      amount: map['amount'],
      email: map['email'],
      paidAt: map['paid_at'],
      type: map['type'],
    );
  }
}
