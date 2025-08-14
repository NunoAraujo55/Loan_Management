import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';

class SegurosAssociadosCard extends StatefulWidget {
  final Loan selectedLoan;
  const SegurosAssociadosCard({super.key, required this.selectedLoan});

  @override
  _SegurosAssociadosCardState createState() => _SegurosAssociadosCardState();
}

class _SegurosAssociadosCardState extends State<SegurosAssociadosCard> {
  @override
  Widget build(BuildContext context) {
    final insList = widget.selectedLoan.insurances ?? [];
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título com ícone
            Row(
              children: [
                Icon(Icons.security, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  'Seguros Associados',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (insList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Nenhum seguro associado',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ...insList.map((ins) {
              return _buildInsuranceRow(
                ins.name,
                '${ins.value} €/mês', 
                'Ativo', 
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para montar cada linha de seguro
  Widget _buildInsuranceRow(String title, String price, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nome do seguro
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          // Valor e status
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Color(0xFF1C8166),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
