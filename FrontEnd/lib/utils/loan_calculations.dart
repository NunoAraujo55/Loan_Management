import 'dart:math';

import 'package:flutter_amortiza/controllers/contract_values_controller.dart';
import 'package:flutter_amortiza/models/RatePlanPeriod.dart';
import 'package:flutter_amortiza/screens/credit/amortization.dart';

double calculatePMT({
  required double principal,
  required double annualRate,
  required int totalMonths,
}) {
  final double i = (annualRate / 100) / 12;
  final double numerator = principal * i * pow(1 + i, totalMonths);
  final double denominator = pow(1 + i, totalMonths) - 1;
  return numerator / denominator;
}

DateTime addOneMonth(DateTime date) {
  final nextMonth = DateTime(date.year, date.month + 1, 1);
  final day =
      min(date.day, DateTime(nextMonth.year, nextMonth.month + 1, 0).day);
  return DateTime(nextMonth.year, nextMonth.month, day);
}

DateTime addMonths(DateTime date, int monthsToAdd) {
  final newYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
  final newMonth = ((date.month + monthsToAdd - 1) % 12) + 1;

  final day = date.day;
  final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
  final newDay = day > lastDayOfNewMonth ? lastDayOfNewMonth : day;

  return DateTime(newYear, newMonth, newDay);
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

int monthsBetween(DateTime start, DateTime end) {
  int months = (end.year - start.year) * 12 + (end.month - start.month);

  if (end.day < start.day) {
    months -= 1;
  }

  return months;
}

List<AmortEntry> simulateLoan({
  required double principal,
  required int totalMonths,
  required DateTime startingDate,
  required List<ContractValues> contractValues,
  List<ExtraPayment> extraPayments = const [],
  bool reduceTerm = false,
  required double fallbackTan,
  required double spread,
}) {
  double balance = principal;
  int month = 1;
  int remainingTerm = totalMonths;
  DateTime currentDate = startingDate;
  final schedule = <AmortEntry>[];
  print('Simulação começa em: $startingDate');

  final bool isFixedRate = contractValues.isEmpty && fallbackTan > 0;

  final double? fixedPmt = isFixedRate
      ? calculatePMT(
          principal: principal,
          annualRate: fallbackTan,
          totalMonths: totalMonths,
        )
      : null;

  double lastAppliedRate = -1;
  double currentPMT = 0;
  while (balance > 0.01 && month <= totalMonths) {
    double annualRate;
    if (!isFixedRate) {
      if (contractValues.isNotEmpty) {
        final matchedRate = contractValues.firstWhere(
          (r) => r.isInPeriod(currentDate),
          orElse: () => contractValues.last,
        );
        annualRate = matchedRate.value + spread;

        if (lastAppliedRate != annualRate) {
          currentPMT = calculatePMT(
            principal: balance,
            annualRate: annualRate,
            totalMonths: remainingTerm,
          );
          lastAppliedRate = annualRate;
        }
      } else {
        print("No contract values found, falling back to TAN: $fallbackTan");
        annualRate = fallbackTan;
      }
    } else {
      annualRate = fallbackTan;
    }

    final double monthlyRate = (annualRate / 100) / 12;

    final double pmt = isFixedRate ? fixedPmt! : currentPMT;

    final extra = extraPayments
        .firstWhere((e) => e.month == month,
            orElse: () => ExtraPayment(month: month, amount: 0.0))
        .amount;

    final interest = balance * monthlyRate;
    final principalPay = min(pmt - interest, balance);
    balance = balance - principalPay - extra;

    if (extra > 0 && !isFixedRate) {
      if (reduceTerm) {
        final nume = log(pmt / (pmt - balance * monthlyRate));
        final deno = log(1 + monthlyRate);
        remainingTerm = (nume / deno).floor();
      } else {
        remainingTerm = totalMonths - month;
      }
    }

    schedule.add(AmortEntry(
      month: month,
      payment: pmt,
      interest: interest,
      principal: principalPay,
      extraPayment: extra,
      balance: max(balance, 0),
      appliedRate: annualRate,
    ));

    month++;
    currentDate = addOneMonth(currentDate);
    remainingTerm--;
  }

  return schedule;
}

List<AmortEntry> simulateLoanMixed({
  required double principal,
  required int totalMonths,
  required DateTime startingDate,
  required List<RatePlanPeriod> periods,
  List<ExtraPayment> extraPayments = const [],
  bool reduceTerm = false,
}) {
  double balance = principal;
  int month = 1;
  int remainingTerm = totalMonths;
  DateTime currentDate = startingDate;
  final schedule = <AmortEntry>[];

  RatePlanPeriod active(DateTime d) =>
      periods.firstWhere((p) => p.contains(d), orElse: () => periods.last);

  double lastRate = -1;
  double pmt = 0;

  while (balance > 0.01 && month <= totalMonths) {
    final period = active(currentDate);

    // taxa efetiva: (variável) euribor + spread  ou  (fixo) tan
    double annualRate;
    if (period.values.isNotEmpty) {
      final cv = period.values.firstWhere(
        (r) => r.isInPeriod(currentDate),
        orElse: () => period.values.last,
      );
      annualRate = cv.value + period.spread;
    } else {
      annualRate = period.tan;
    }

    if (annualRate != lastRate) {
      pmt = calculatePMT(principal: balance, annualRate: annualRate, totalMonths: remainingTerm);
      lastRate = annualRate;
    }

    final monthlyRate = (annualRate / 100) / 12;
    final extra = extraPayments
        .firstWhere((e) => e.month == month, orElse: () => ExtraPayment(month: month, amount: 0))
        .amount;

    final interest = balance * monthlyRate;
    final principalPay = min(pmt - interest, balance);
    balance = balance - principalPay - extra;

    if (extra > 0) {
      if (reduceTerm) {
        final nume = log(pmt / (pmt - balance * monthlyRate));
        final deno = log(1 + monthlyRate);
        remainingTerm = (nume / deno).floor();
      } else {
        remainingTerm = totalMonths - month;
      }
    }

    schedule.add(AmortEntry(
      month: month,
      payment: pmt,
      interest: interest,
      principal: principalPay,
      extraPayment: extra,
      balance: max(balance, 0),
      appliedRate: annualRate,
    ));

    month++;
    remainingTerm--;
    currentDate = addOneMonth(currentDate);
  }

  return schedule;
}
