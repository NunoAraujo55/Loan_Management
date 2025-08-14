import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';

class LoanController with ChangeNotifier {
  final List<Loan> _loans = [];

  List<Loan> get loans => _loans;

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void clearLoans() {
    _loans.clear();
    notifyListeners();
  }
}
