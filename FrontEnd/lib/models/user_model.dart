class User {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String? birthDate;
  final num? income;
  final num? monthlyExpenses;
  final String refreshToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    this.birthDate,
    this.income,
    this.monthlyExpenses,
    required this.refreshToken,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Convert int to String if necessary
      name: json['Name'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      birthDate: json['BirthDate'], // if it can be null
      income: json['Income'], // adjust conversion if needed
      monthlyExpenses: json['MonthlyExpenses'], // adjust conversion if needed
      refreshToken: json['RefreshToken'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
