import 'package:flutter/material.dart';

class SliderMontante extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;

  const SliderMontante({
    Key? key,
    required this.onChanged,
    this.initialValue = 20000.0,
  }) : super(key: key);

  @override
  _SliderMontanteState createState() => _SliderMontanteState();
}

class _SliderMontanteState extends State<SliderMontante> {
  double _valorAtual = 0;
  late TextEditingController _controller;

  final double minValue = 300.0;
  final double maxValue = 100000.0;

  @override
  void initState() {
    super.initState();
    _valorAtual = widget.initialValue;
    _controller = TextEditingController(text: _valorAtual.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Called as the user types: updates the slider if the value can be parsed.
  void _onTextChanged(String text) {
    final double? newValue = double.tryParse(text);
    if (newValue != null) {
      final double clamped = newValue.clamp(minValue, maxValue);
      setState(() {
        _valorAtual = clamped;
      });
      widget.onChanged(_valorAtual);
    }
  }

  // Called when editing is complete to ensure the text field reflects a valid value.
  void _onTextSubmitted(String text) {
    final double? newValue = double.tryParse(text);
    if (newValue != null) {
      final double clamped = newValue.clamp(minValue, maxValue);
      setState(() {
        _valorAtual = clamped;
      });
      widget.onChanged(_valorAtual);
      _controller.text = clamped.toStringAsFixed(2);
    } else {
      // Reset the field if input was invalid.
      _controller.text = _valorAtual.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF), // Light blue background
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'montante em euros',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF002E8B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          // TextField allows user input and updates slider on each keystroke.
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              color: Color(0xFF002E8B),
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            onChanged: _onTextChanged,
            onSubmitted: _onTextSubmitted,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 1.0),
          Slider(
            value: _valorAtual,
            min: minValue,
            max: maxValue,
            divisions: (maxValue - minValue).toInt(),
            activeColor: const Color(0xFF002E8B),
            onChanged: (double value) {
              setState(() {
                _valorAtual = value;
                _controller.text = _valorAtual.toStringAsFixed(2);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '300€',
                style: TextStyle(
                  color: const Color(0xFF002E8B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '100,000.0',
                style: TextStyle(
                  color: const Color(0xFF002E8B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
