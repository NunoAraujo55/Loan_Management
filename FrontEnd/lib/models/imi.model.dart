class ImiRecord {
  final String distrito;
  final String municipio;
  final double taxa;
  final int ano;

  ImiRecord({
    required this.distrito,
    required this.municipio,
    required this.taxa,
    required this.ano,
  });

  factory ImiRecord.fromJson(Map<String, dynamic> json) {
    final rawTaxa = json['taxa'];
    final parsedTaxa =
        rawTaxa is String ? double.parse(rawTaxa) : (rawTaxa as num).toDouble();
    final rawDistrito = json['distrito'] as String;
    final cleanDistrito = rawDistrito
        .replaceFirst(RegExp(r'^\d+'), '')
        .trim();
    return ImiRecord(
      distrito: cleanDistrito,
      municipio: json['municipio'] as String,
      taxa: parsedTaxa,
      ano: json['ano'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'distrito': distrito,
        'municipio': municipio,
        'taxa': taxa,
        'ano': ano,
      };
}
