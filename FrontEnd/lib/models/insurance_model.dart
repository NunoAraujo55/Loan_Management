class Insurance {
  final num? value;
  final String name;

  Insurance({
    required this.value,
    required this.name,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    return Insurance(
      value: parseNum(json['Insurance']),
      name: json['name'] as String,
    );
  }
}
