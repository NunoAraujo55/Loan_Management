import 'package:flutter_amortiza/models/insurance_model.dart';

class Loan {
  final int? id;
  final num? downPayment;
  final num? creditTerm;
  final List<Insurance>? insurances;
  final num? userId;
  final num? bankId;
  final num? amount;
  final String? name;
  final num? instalment;
  final DateTime? startingDate;

  Loan(
      {required this.id,
      required this.downPayment,
      required this.creditTerm,
      required this.insurances,
      required this.userId,
      required this.bankId,
      required this.amount,
      required this.name,
      required this.instalment,
      required this.startingDate});

  factory Loan.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    List<Insurance>? insList;
    if (json['insurances'] is List) {
      insList = (json['insurances'] as List)
          .map((e) => Insurance.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Loan(
      id: json['id'],
      downPayment: parseNum(json['DownPayment']),
      creditTerm: parseNum(json['CreditTerm']),
      insurances: insList,
      userId: parseNum(json['userId']),
      bankId: parseNum(json['bankId']),
      amount: parseNum(json['amount']),
      name: json['name'],
      instalment: parseNum(json['instalment']),
      startingDate: json['startingDate'] == null
          ? null
          : DateTime.parse(json['startingDate']),
    );
  }
}
