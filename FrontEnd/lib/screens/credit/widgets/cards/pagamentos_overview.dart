import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:flutter_amortiza/screens/credit/amortization.dart';
import 'package:intl/intl.dart';

class DetalhesDoPagamento extends StatefulWidget {
  final AmortEntry entry;
  final DateTime date;
    final Loan selectedLoan;
  const DetalhesDoPagamento({Key ? key, required this.entry, required this.date, required this.selectedLoan}): super(key : key);

  @override
  State<DetalhesDoPagamento> createState() => _DetalhesDoPagamentoState();
}

final status = "Ativo";

class _DetalhesDoPagamentoState extends State<DetalhesDoPagamento> {
  @override
  Widget build(BuildContext context) {
    final insList = widget.selectedLoan.insurances ?? [];
    final formattedDate = DateFormat('dd MMM yyyy').format(widget.date);
     final totalInsurance = insList.fold<double>(0.0, (sum, ins) => sum + ins.value!);
     final total = totalInsurance + widget.entry.payment;
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
            const SizedBox(height: 16),
            // Linhas de detalhes
            _buildDetailRow('Data', formattedDate),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('valor total', '${total.toStringAsFixed(2)}€'),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildDetailRowSecondary('Prestação', '${widget.entry.payment.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildDetailRowSecondary('Capital', '${widget.entry.principal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildDetailRowSecondary('Juros', '${widget.entry.interest.toStringAsFixed(2)}€'),
            const SizedBox(height: 8),
            _buildDetailRowSecondary('Seguros', '${totalInsurance.toStringAsFixed(2)}€'),
            
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

  Widget _buildDetailRowSecondary(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey,
            )),
        Text(
          value,
          style: TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
