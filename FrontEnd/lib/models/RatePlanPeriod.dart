import 'package:flutter_amortiza/controllers/contract_values_controller.dart';

class RatePlanPeriod {
  final DateTime start;
  final DateTime end;            
  final double spread;          
  final double tan;            
  final List<ContractValues> values; 

  RatePlanPeriod({
    required this.start,
    required this.end,
    required this.spread,
    required this.tan,
    required this.values,
  });

  bool contains(DateTime d) =>
      !d.isBefore(start) && d.isBefore(end); // [start, end)
}
