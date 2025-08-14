import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';

class TaxaDeJuro extends StatefulWidget {
  final Loan selectedLoan;
  final double spread;
  final double euribor;
  final double tan;
  final int periodicidade;
  const TaxaDeJuro(
      {super.key,
      required this.selectedLoan,
      required this.euribor,
      required this.spread,
      required this.tan,
      required this.periodicidade});

  @override
  State<TaxaDeJuro> createState() => _TaxaDeJuroState();
}

final status = "Ativo";

class _TaxaDeJuroState extends State<TaxaDeJuro> {
  @override
  Widget build(BuildContext context) {
    bool tanVisible = false;
    bool euriborVisible = false;

    if (widget.tan != 0) {
      tanVisible = true;
    } else {
      euriborVisible = true;
    }
    //final selectedLoan = widget.selectedLoan;
    num taxas = widget.spread + widget.euribor;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título com ícone
            Row(
              children: [
                Text(
                  "%",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(width: 8),
                Text(
                  'Taxa de Juro',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linhas de detalhes
            Visibility(
              visible: euriborVisible,
              child: Column(
                children: [
                  _buildDetailRow('TAN', '${taxas.toStringAsFixed(2)} %'),
                  const SizedBox(height: 8),
                  const Divider(
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            Visibility(
                visible: tanVisible,
                child: Column(
                  children: [
                    _buildDetailRow(
                        'TAN', '${widget.tan.toStringAsFixed(2)} %'),
                    const SizedBox(height: 8),
                    const Divider(
                      color: Colors.grey,
                    ),
                  ],
                )),

            Visibility(
              visible: euriborVisible,
              child: Column(
                children: [
                  _buildDetailRow(
                      'Spread', '${widget.spread.toStringAsFixed(2)}%'),
                  const SizedBox(height: 8),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Euribor',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.grey,
                          )),
                      Row(
                        children: [
                          Text(
                            '${widget.euribor.toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0, left: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${widget.periodicidade} meses",
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
                  const SizedBox(height: 8),
                  const Divider(
                    color: Colors.grey,
                  ),
                  _buildDetailRow('Próxima revisão', '10 Jan 2025'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.grey,
            )),
        Text(
          value,
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
