import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/credit/amortization.dart';

class AmortizationPlan extends StatefulWidget {
  final List<AmortEntry> schedule;
  final double newInterest;
  final double originalInterest;
  final double savings;
  final double totalCost;
  final int months;
  final int amortMonth;
  final double amount;
  final int monthsOriginal;

  const AmortizationPlan({
    Key? key,
    required this.schedule,
    required this.newInterest,
    required this.originalInterest,
    required this.savings,
    required this.totalCost,
    required this.months,
    required this.amortMonth,
    required this.amount,
    required this.monthsOriginal,
  }) : super(key: key);

  @override
  _AmortizationPlanState createState() => _AmortizationPlanState();
}

class _AmortizationPlanState extends State<AmortizationPlan> {
  double avgPrice() {
    if (widget.schedule.isEmpty) return 0.0;

    final total =
        widget.schedule.fold(0.0, (sum, entry) => sum + entry.payment);
    return total / widget.schedule.length;
  }

  @override
  Widget build(BuildContext context) {
    final totalOriginal = widget.amount + widget.originalInterest;
    final totalNew = widget.amount + widget.newInterest;
    // ignore: unused_local_variable
    final monthsNew = widget.months;
    final avgprice = avgPrice();

    final filteredSchedule =
        widget.schedule.where((e) => e.month >= widget.amortMonth - 1).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BFF),
        elevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Blue Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    color: Color(0xFF1E5BFF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Plano de Amortizações',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Consulta o resultado da amortização ao longo do tempo.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeaderCards(
                          avgprice,
                          totalOriginal,
                          totalNew,
                          widget.schedule[widget.amortMonth - 2].payment,
                          widget.originalInterest,
                          widget.newInterest,
                          widget.monthsOriginal,
                          widget.months,
                          widget.savings,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Prestações Mensais',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final entry = filteredSchedule[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mês ${entry.month}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 223, 240, 255),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entry.payment.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 24,
                              runSpacing: 8,
                              children: [
                                _infoItem('Juros:',
                                    '${entry.interest.toStringAsFixed(2)} €'),
                                _infoItem('Capital Amortizado:',
                                    '${entry.principal.toStringAsFixed(2)} €'),
                                _infoItem('Extra:',
                                    '${entry.extraPayment.toStringAsFixed(2)} €'),
                                _infoItem('Saldo devedor:',
                                    '${entry.balance.toStringAsFixed(2)} €'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredSchedule.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoColumn(String label, String value, Color valueColor,
    {CrossAxisAlignment align = CrossAxisAlignment.start}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255, 191, 190, 190),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _infoItem(String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style:
            TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
      ),
      SizedBox(width: 4),
      Text(
        value,
        style:
            TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    ],
  );
}

Widget _buildHeaderCards(
  double avgprice,
  double totalOriginal,
  double totalNew,
  double monthlyPayment,
  double originalInterest,
  double newInterest,
  int monthsOriginal,
  int monthsNew,
  double savings,
) {
  return Card(
    elevation: 2,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resultados da Simulação',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 8),
          Text('Verifique os novos valores',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _infoColumn('Prestação',
                      '${monthlyPayment.toStringAsFixed(2)} €', Colors.black)),
              SizedBox(width: 16),
              Expanded(
                  child: _infoColumn('Avg. Prestação',
                      '${avgprice.toStringAsFixed(2)} €', Colors.blueAccent)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _infoColumn('Custo Total',
                      '${totalOriginal.toStringAsFixed(2)} €', Colors.black)),
              SizedBox(width: 16),
              Expanded(
                  child: _infoColumn('Custo Total',
                      '${totalNew.toStringAsFixed(2)} €', Colors.blueAccent)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _infoColumn(
                      'Total de Juros',
                      '${originalInterest.toStringAsFixed(2)} €',
                      Colors.black)),
              SizedBox(width: 16),
              Expanded(
                  child: _infoColumn(
                      'Total de Juros',
                      '${newInterest.toStringAsFixed(2)} €',
                      Colors.blueAccent)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _infoColumn(
                      'Tempo Restante', '$monthsOriginal meses', Colors.black)),
              SizedBox(width: 16),
              Expanded(
                  child: _infoColumn(
                      'Tempo Restante', '$monthsNew meses', Colors.blueAccent)),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 223, 240, 254),
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total poupado',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('${savings.toStringAsFixed(2)} €',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
