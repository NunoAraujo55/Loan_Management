import 'package:pdf/widgets.dart';

class CustomInfo extends StatelessWidget {
  final String begin;
  final String end;

  CustomInfo({required this.begin, required this.end});

  @override
  Widget build(Context context) {
    return Container(
      width: double.infinity,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(begin,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(
            end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }
}
