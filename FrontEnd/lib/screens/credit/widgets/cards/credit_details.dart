import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:intl/intl.dart';

class CreditDetails extends StatefulWidget {
  final Loan selectedLoan;
  const CreditDetails({super.key, required this.selectedLoan});

  @override
  State<CreditDetails> createState() => _CreditDetailsState();
}

final status = "Ativo";

class _CreditDetailsState extends State<CreditDetails> {
  @override
  Widget build(BuildContext context) {
    DateTime endingDate = DateTime(
      widget.selectedLoan.startingDate!.year +
          widget.selectedLoan.creditTerm!.toInt(),
      widget.selectedLoan.startingDate!.month,
      widget.selectedLoan.startingDate!.day,
    );

    String formattedDate = DateFormat('dd/MM/yy').format(endingDate);
    String startingDate =
        DateFormat('dd/MM/yy').format(widget.selectedLoan.startingDate!);

    final selectedLoan = widget.selectedLoan;
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
                Image.asset(
                  'assets/building.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detalhes do Empréstimo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linhas de detalhes
            _buildDetailRow('Finalidade', 'Habitação Própria'),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Data de início', startingDate.toString()),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Prazo', selectedLoan.creditTerm.toString()),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Data de término', formattedDate.toString()),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Modalidade', 'Taxa variável'),
            const SizedBox(height: 8),
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
