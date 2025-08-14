import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:flutter_amortiza/screens/credit/widgets/progress_bar/custom_progress_bar.dart';
import 'package:intl/intl.dart';

class CreditCardDetailed extends StatefulWidget {
  final Loan selectedLoan;
  final double? instalment;
  final double? totalInterestPaid;
  final double? totalPrincipalPaid;
  final double? currentBalance;
  const CreditCardDetailed(
      {super.key,
      required this.selectedLoan,
      this.instalment,
      this.totalInterestPaid,
      this.currentBalance,
      this.totalPrincipalPaid});

  @override
  State<CreditCardDetailed> createState() => _CreditCardDetailedState();
}

final status = "Ativo";

class _CreditCardDetailedState extends State<CreditCardDetailed> {
  String _safeFormatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'pt_PT').format(date);
    } catch (e) {
      print('⚠️ Date formatting failed: $e');
      return DateFormat('dd MMM yyyy').format(date); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPaid = widget.totalInterestPaid!.toDouble() +
        widget.totalPrincipalPaid!.toDouble();
    final selectedLoan = widget.selectedLoan;
    final paidFraction =
        1.0 - (widget.currentBalance!.toDouble() / selectedLoan.amount!);
    final progress = paidFraction.clamp(0.0, 1.0);

    final percentPaid = (progress * 100).toStringAsFixed(1);

    DateTime startingDate = widget.selectedLoan.startingDate!;
    int creditTermYears = widget.selectedLoan.creditTerm!.toInt();
    DateTime currentDate = DateTime.now();

    DateTime endDate = DateTime(
      startingDate.year + creditTermYears,
      startingDate.month,
      startingDate.day,
    );

    // diferença em meses
    int remainingMonths = (endDate.year - currentDate.year) * 12 +
        (endDate.month - currentDate.month);

    // Corrige se o dia atual for depois do dia de início
    if (currentDate.day > startingDate.day) {
      remainingMonths -= 1;
    }

    // Protege contra valores negativos se já passou o prazo
    remainingMonths = remainingMonths.clamp(0, creditTermYears * 12);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0283C7), Color(0xFF1D4FD8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                //borderRadius: BorderRadius.circular(12),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Montante do empréstimo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == "Ativo"
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color(0xFFFF4800).withAlpha(60),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == "Ativo"
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : const Color(0xFFFF4800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                // Subtítulo
                Text(
                  "${selectedLoan.amount.toString()} €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Linha 1: Taxas competitivas
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Prestação Mensal Inicial",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            "${widget.instalment!.toStringAsFixed(2)} €",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Data de contrato",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            selectedLoan.startingDate != null
                                ? _safeFormatDate(selectedLoan.startingDate!)
                                : '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Progresso do empréstimo",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomProgressBar(
                  progress: progress,
                  leftText: '$percentPaid% Pago',
                  rightText: '$remainingMonths meses restantes',
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Capital em dívida",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            "${widget.currentBalance!.toStringAsFixed(2)}€",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Capital Amortizado",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${widget.totalPrincipalPaid!.toStringAsFixed(2)} €',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Juros Pagos",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${widget.totalInterestPaid!.toStringAsFixed(2)} €',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Pago",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            "${totalPaid.toStringAsFixed(2)} €",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
