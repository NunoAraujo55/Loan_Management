class ContractValues {
  final DateTime start;
  final DateTime end;
  final double value;
  final int term;

  ContractValues({
    required this.start,
    required this.end,
    required this.value,
    required this.term,
  });

  factory ContractValues.fromJson(Map<String, dynamic> json) {
    return ContractValues(
      start: DateTime.parse(json['startingDate']),
      end: DateTime.parse(json['endingDate']),
      value: double.parse(json['value']),
      term: json['term'] ?? 0,
    );
  }

  bool isInPeriod(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start);
  }

  @override
  String toString() {
    return 'ContractValues(value: $value, start: $start, end: $end, term: $term)';
  }
}
