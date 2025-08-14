import 'package:flutter/material.dart';

class TipoImovelField extends StatefulWidget {
  final String label;

  final String? initialValue;

  final ValueChanged<String?>? onChanged;

  const TipoImovelField({
    Key? key,
    required this.label,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  _TipoImovelFieldState createState() => _TipoImovelFieldState();
}

class _TipoImovelFieldState extends State<TipoImovelField> {
  String? _selectedTipo = 'Urbano';
  final List<String> _tipos = [
    'Menos de 5 anos',
    'Entre 5 e 10 anos',
    'Entre 10 a 20 anos',
    'Mais de 20 anos',
    'Urbano'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: _selectedTipo,
          items: _tipos
              .map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  ))
              .toList(),
          onChanged: (novo) {
            setState(() => _selectedTipo = novo);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
          ),
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
