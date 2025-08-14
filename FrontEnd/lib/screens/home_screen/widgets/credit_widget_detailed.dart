import 'package:flutter/material.dart';
import 'package:flutter_amortiza/extensions/string_casing_extension.dart';

class CreditIBox extends StatefulWidget {
  final String title;
  final String amount;
  final String term;
  final String spread;
  final String euribor;
  final String euriborDuration;
  final String installment;
  final String status;
  final String tan;
  final String rateTerm;

  const CreditIBox({
    super.key,
    required this.title,
    required this.amount,
    required this.term,
    required this.spread,
    required this.euribor,
    required this.euriborDuration,
    required this.installment,
    required this.tan,
    this.status = 'Ativo',
    required this.rateTerm,
  });
  @override
  State<CreditIBox> createState() => _CreditIBoxState();
}

final status = 'Ativo';

class _CreditIBoxState extends State<CreditIBox> {
  bool tanVisible = false;
  bool spreadVisible = false;

  @override
  Widget build(BuildContext context) {
    if (double.tryParse(widget.tan) == 0) {
      tanVisible = false;
      spreadVisible = true;
    } else {
      tanVisible = true;
      spreadVisible = false;
    }
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for the icon, title, and status
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0F2FE),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/building.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Text(
                  (widget.title).capitalizeFirst(),
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const Spacer(),
                // "Ativo" badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == "Ativo"
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFF4800).withAlpha(60),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == "Ativo"
                            ? const Color(0xFF1C8166)
                            : const Color(0xFFFF4800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row for the amount and duration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '€ Montante',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${widget.amount} €',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.calendar_month,
                              size: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Prazo',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.term} anos',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row for spread and euribor
            Visibility(
              visible: tanVisible,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tan %',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          widget.tan,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: spreadVisible,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '% Spread',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          widget.spread,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Image.asset(
                            'assets/trend.png',
                            width: 13,
                            height: 13,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Euribor',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.euribor,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 0, left: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.rateTerm} meses',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 91, 123, 160)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prestação',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${widget.installment} €',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      // "Ver detalhes" link
                      Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreditScreen(),
                                ),
                              );*/
                            },
                            child: const Text(
                              'Ver detalhes',
                              style: TextStyle(
                                  color: Color(0xFF1388BE),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                size: 12, color: Color(0xFF1388BE)),
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
