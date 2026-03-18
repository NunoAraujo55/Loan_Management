import 'package:flutter/material.dart';
import 'package:flutter_amortiza/controllers/contract_values_controller.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:flutter_amortiza/screens/credit/amortization_plan.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';
import 'package:flutter_amortiza/utils/loan_calculations.dart';
import 'package:intl/intl.dart';

class Amortization extends StatefulWidget {
  final Loan selectedLoan;
  final spread;
  final tan;
  final List<ContractValues> rateHistory;

  const Amortization(
      {Key? key,
      required this.selectedLoan,
      required this.spread,
      required this.tan,
      required this.rateHistory})
      : super(key: key);

  @override
  _AmortizationState createState() => _AmortizationState();
}

class _AmortizationState extends State<Amortization> {
  final List<DateTime?> _selectedDates = [];
  final List<TextEditingController> _amountCtrls = [];

  final montanteController = TextEditingController();
  final spreadController = TextEditingController();
  final termController = TextEditingController();
  final euriborController = TextEditingController();
  final tanController = TextEditingController();
  bool visibleSE = false;
  bool visibleTAN = false;
  // Store the selected slider value
  //double _montanteSelecionado = 20000.0;

  bool reduceTerm = true;

  int? _computeAmortMonth({
    required DateTime? selectedData,
    required DateTime startDate,
    required int totalMonths,
    required BuildContext context,
  }) {
    if (selectedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escolha uma data')),
      );
      return null;
    }

    final target = selectedData;
    final amortMonth = ((target.year - startDate.year) * 12 +
            (target.month - startDate.month)) +
        1;

    if (amortMonth < 1 || amortMonth > totalMonths) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data fora do prazo do crédito')),
      );
      return null;
    }

    return amortMonth;
  }

  @override
  void initState() {
    super.initState();
    _selectedDates.add(null);
    _amountCtrls.add(TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _amountCtrls) {
      c.dispose();
    }
    euriborController.dispose();
    spreadController.dispose();
    montanteController.dispose();
    termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tan == 0) {
      visibleSE = true;
    } else {
      visibleTAN = true;
    }
    print(widget.spread);
    print(widget.tan);
    for (int i = 0; i < widget.rateHistory.length; i++) {
      print(widget.rateHistory[i]);
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /*actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],*/
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              top: kToolbarHeight + 50, left: 20, right: 20, bottom: 50),
          child: Column(
            children: [
              Card(
                elevation: 1,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Detalhes do crédito",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Informação do crédito",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: montanteController,
                        name: "Montante",
                        inputType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        initialValue: widget.selectedLoan.amount.toString(),
                      ),
                      CustomTextField(
                        controller: termController,
                        name: "Prazo (anos)",
                        inputType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        initialValue: widget.selectedLoan.creditTerm.toString(),
                      ),
                      Visibility(
                        visible: visibleTAN,
                        child: CustomTextField(
                          controller: tanController,
                          name: "TAN (%)",
                          inputType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          initialValue: widget.tan.toString(),
                        ),
                      ),
                      Visibility(
                        visible: visibleSE,
                        child: Row(
                          children: [
                            /*Expanded(
                              child: CustomTextField(
                                controller: euriborController,
                                name: "Euribor (%)",
                                inputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                initialValue:
                                    widget.selectedLoan.euribor.toString(),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),*/
                            Expanded(
                              child: CustomTextField(
                                controller: spreadController,
                                name: "Spread (%)",
                                inputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                initialValue: widget.spread.toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Tipo de Amortização",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        title: const Text(
                          "Reduzir ao prazo",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        leading: Radio<bool>(
                          value: true,
                          groupValue: reduceTerm,
                          activeColor: Colors.blue,
                          onChanged: (v) => setState(() => reduceTerm = v!),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        title: const Text(
                          "Reduzir à prestação",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        leading: Radio<bool>(
                          activeColor: Colors.blue,
                          value: false,
                          groupValue: reduceTerm,
                          onChanged: (v) => setState(() => reduceTerm = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amortização Extra',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDates.add(null);
                                _amountCtrls.add(TextEditingController());
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                color: Colors.white,
                                // moved here
                                /*border: Border.all(
                                color: Colors.grey, // border color
                                width: 0.5, 
                              ),*/
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      for (int i = 0; i < _amountCtrls.length; i++)
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: i == 0 ? Colors.red : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Amortização ${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDates.removeAt(i);
                                      _amountCtrls.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: now,
                                          firstDate:
                                              widget.selectedLoan.startingDate!,
                                          lastDate: DateTime(now.year + 5),
                                        );
                                        if (picked != null) {
                                          setState(
                                              () => _selectedDates[i] = picked);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedDates[i] == null
                                                  ? 'Escolhe a data da amortização'
                                                  : DateFormat('dd/MM/yyyy')
                                                      .format(
                                                          _selectedDates[i]!),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            const Icon(Icons.calendar_month),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: _amountCtrls[i],
                                      name: "Amount (€)",
                                      inputType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          final principal =
                              widget.selectedLoan.amount!.toDouble() -
                                  widget.selectedLoan.downPayment!.toDouble();
                          final years = int.tryParse(termController.text) ?? 0;
                          // ignore: unused_local_variable
                          final totalMonths = years * 12;

                          int? firstAmortMonth;
                          final extras = <ExtraPayment>[];
                          for (int i = 0; i < _amountCtrls.length; i++) {
                            if(_selectedDates.isEmpty){
                              return;
                            }
                            final date = _selectedDates[i];
                            final amount =
                                double.tryParse(_amountCtrls[i].text) ?? 0;
                            if (date == null || amount <= 0) continue;

                            final amortMonth = _computeAmortMonth(
                              selectedData: date,
                              startDate: widget.selectedLoan.startingDate!,
                              totalMonths: totalMonths,
                              context: context,
                            );

                            if (amortMonth != null) {
                              firstAmortMonth ??= amortMonth;

                              extras.add(ExtraPayment(
                                  month: amortMonth, amount: amount));
                            }
                          }

                          if (extras.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Por favor, adicione uma amortização extra')),
                            );
                            return;
                          }

                          if (widget.rateHistory.isEmpty) {
                            debugPrint('[Simular] rateHistory vazio – não é possível calcular.');
                            return;
                          }

                          // 3) Simula

                          final schedule = simulateLoan(
                            principal: principal,
                            totalMonths: totalMonths,
                            startingDate: widget.selectedLoan.startingDate!,
                            contractValues: widget.rateHistory,
                            spread: (widget.spread ?? 0).toDouble(),
                            fallbackTan: (widget.tan ?? 0).toDouble(),
                            extraPayments: extras,
                            reduceTerm: reduceTerm,
                          );

                          final originalSchedule = simulateLoan(
                            principal: principal,
                            totalMonths: totalMonths,
                            startingDate: widget.selectedLoan.startingDate!,
                            contractValues: widget.rateHistory,
                            spread: (widget.spread ?? 0).toDouble(),
                            fallbackTan: (widget.tan ?? 0).toDouble(),
                            extraPayments: [],
                            reduceTerm: reduceTerm,
                          );

                          //for (final e in schedule) debugPrint(e.toString());

                          // 6) Calculate interest & savings
                          double interestWithExtras = schedule.fold(
                              0, (sum, entry) => sum + entry.interest);
                          double interestOriginal = originalSchedule.fold(
                              0, (sum, entry) => sum + entry.interest);
                          double savings =
                              interestOriginal - interestWithExtras;
                          double totalCost = principal + interestWithExtras;
                          int duration = schedule.last.month;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AmortizationPlan(
                                schedule: schedule,
                                newInterest: interestWithExtras,
                                originalInterest: interestOriginal,
                                savings: savings,
                                totalCost: totalCost,
                                months: duration,
                                amortMonth: (firstAmortMonth != null &&
                                        firstAmortMonth >= 1)
                                    ? firstAmortMonth
                                    : 1,
                                amount: principal,
                                monthsOriginal: totalMonths,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 7, 95, 202),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Simular',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExtraPayment {
  final int month;
  final double amount;
  const ExtraPayment({required this.month, required this.amount});
}

class AmortEntry {
  final int month;
  final double payment;
  final double interest;
  final double principal;
  final double extraPayment;
  final double balance;
  final double? appliedRate;

  AmortEntry({
    required this.month,
    required this.payment,
    required this.interest,
    required this.principal,
    required this.extraPayment,
    required this.balance,
    this.appliedRate,
  });

  @override
  String toString() {
    final rateStr =
        appliedRate != null ? '${appliedRate!.toStringAsFixed(2)}%' : 'N/A';
    return 'Month $month → payment: €${payment.toStringAsFixed(2)}, '
        'interest: €${interest.toStringAsFixed(2)}, '
        'principal: €${principal.toStringAsFixed(2)}, '
        'extra: €${extraPayment.toStringAsFixed(2)}, '
        'rate: $rateStr, '
        'balance: €${balance.toStringAsFixed(2)}';
  }
}
