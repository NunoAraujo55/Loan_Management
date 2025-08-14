import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/controllers/contract_values_controller.dart';
import 'package:flutter_amortiza/extensions/string_casing_extension.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:flutter_amortiza/screens/credit/amortization.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/credit_card_detailed.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/credit_details.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/detalhes_do_imovel.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/pagamentos_overview.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/seguros_associados.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/taxa_de_juro.dart';
import 'package:flutter_amortiza/screens/home_screen/home_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreditScreen extends StatefulWidget {
  final Loan selectedLoan;
  final List<AmortEntry> schedule;
  final List<ContractValues> rates;
  final double spread;
  final double tan;
  final int rateTerm;
  const CreditScreen({Key? key, required this.selectedLoan, required this.schedule, required this.rates, required this.spread, required this.tan, required this.rateTerm}) : super(key: key);

  @override
  _CreditScreenState createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  double _tan = 0;
  final Dio dio = GetIt.instance<Dio>();
  late double _nextPmt;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  late List<AmortEntry> _filteredSchedule;


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchTerm = _searchController.text.trim().toLowerCase();
      _filterSchedule();
    });

    setState(() {
      _nextPmt = widget.schedule.isNotEmpty ? widget.schedule.first.payment : 0;
      _filteredSchedule = List.from(widget.schedule);
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _tan;

  }



  Future<void> _removeLoan() async {
    try {
      if (widget.selectedLoan.id != null) {
        final response = await dio.post(
          'credit/remove',
          queryParameters: {
            'loanId': widget.selectedLoan.id,
          },
        );
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.statusCode == 201) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Loan Deleted'),
              content: Text('The loan was successfully removed.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Failed'),
              content: Text('Could not remove the loan. Please try again.'),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while removing the loan.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  
  DateTime addMonths(DateTime from, int months) {
    // compute the raw year/month offset
    final int year = from.year + (from.month - 1 + months) ~/ 12;
    final int month = (from.month - 1 + months) % 12 + 1;
    // clamp the day so we don’t overflow past the end of the month
    final int day = min(
      from.day,
      DateTime(year, month + 1, 0).day,
    );
    return DateTime(year, month, day);
  }

  void _filterSchedule() {
    setState(() {
      _filteredSchedule = widget.schedule.where((entry) {
        final dueDate =
            addMonths(widget.selectedLoan.startingDate!, entry.month);

        DateTime? userInputDate;
        try {
          userInputDate = DateFormat('dd/MM/yyyy').parseStrict(_searchTerm);
        } catch (_) {
          userInputDate = null;
        }

        final formattedDueDate =
            DateFormat('dd MMM yyyy', 'en_US').format(dueDate).toLowerCase();

        bool matchesExactDate = userInputDate != null &&
            userInputDate.year == dueDate.year &&
            userInputDate.month == dueDate.month &&
            userInputDate.day == dueDate.day;

        return _searchTerm.isEmpty ||
            formattedDueDate.contains(_searchTerm.toLowerCase()) ||
            matchesExactDate;
      }).toList();
    });
  }

  int monthsBetween(DateTime start, DateTime end) {
    int months = (end.year - start.year) * 12 + (end.month - start.month);

    if (end.day < start.day) {
      months -= 1; 
    }

    return months;
  }

  @override
  Widget build(BuildContext context) {
    
    print("✅ Values in the Credit Screen ${widget.spread} | ${widget.tan}");
    final loan = widget.selectedLoan;
    final now = DateTime.now();

    // 1) Figure out which month we’re in (0-based index)
    final paidMonths = monthsBetween(loan.startingDate!, now);

    //final showCount = (paidMonths.clamp(0, _schedule.length - 1)) + 1;

    // 2) Clamp it so we don’t go out of bounds
    final idx = paidMonths.clamp(0, widget.schedule.length - 1);

    print(
        "CreditScreen → idx: $idx | payment: ${widget.schedule[idx].payment} | rate: ${widget.schedule[idx].appliedRate}");

    // 3) Grab that amortization entry
    final AmortEntry current = widget.schedule[idx];

    final List<AmortEntry> paidEntries = widget.schedule.sublist(0, idx + 1);

    final double totalInterestPaid =
        paidEntries.fold(0.0, (sum, entry) => sum + entry.interest);

    final double totalPrincipalPaid =
        paidEntries.fold(0.0, (sum, entry) => sum + entry.principal);

    final double currentBalance = widget.schedule[idx].balance;

    /*final amortSchedule = _schedule;
    final today = DateTime.now();*/

    final double currentEuribor = widget.rates.isNotEmpty ? widget.rates.last.value : 0.0;
    final bool hasRates = widget.rates.isNotEmpty;

    
    if (widget.rates.isNotEmpty) {
      final lastRate = widget.rates.last;
      final startDate = lastRate.start;
      final endDate = lastRate.end;

      print("ContractValues.start = $startDate");
      print("ContractValues.end   = $endDate");

      print("Periodicidade (meses) = ${widget.rateTerm}");
    } else {
      print("No rates available yet.");
    }

    final start = widget.selectedLoan.startingDate!;
    final entryDate = addMonths(start, current.month);

    final int daysDiff = entryDate.difference(now).inDays;

    final String daysLabel;
    if (daysDiff > 0) {
      daysLabel = 'Em $daysDiff dias';
    } else {
      daysLabel = 'Hoje';
    }

    /*
    print("Total juros pagos até hoje: €${totalInterestPaid.toStringAsFixed(2)}");
    print("Capital amortizado até hoje: €${totalPrincipalPaid.toStringAsFixed(2)}");
    print("Saldo atual do crédito: €${currentBalance.toStringAsFixed(2)}");
    */
    /*AmortEntry? monthBefore;
    if (idx > 0) {
      monthBefore = _schedule[idx - 1];
    }*/

    /*print(monthBefore!.balance);
    print(monthBefore.payment);
    print(monthBefore.interest);
    print(monthBefore.month);
    print(monthBefore.extraPayment);
    print(monthBefore.principal);
    print("  ");
    print("--  ^ month before ^ --");
    print(" ");
    print(current.balance);
    print(current.payment);
    print(current.interest);
    print(current.month);
    print(current.extraPayment);
    print(current.principal);*/

    print("schedule length: ${widget.schedule.length} from home screen");

    for (var entry in widget.schedule) {
    print('Month: ${entry.month}, Payment: ${entry.payment}, Interest: ${entry.interest}, Principal: ${entry.principal}, Balance: ${entry.balance}');
  }
    return Scaffold(
      
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 50),
            child: Column(
              children: [
                ListTile(
                  leading: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                      )),
                  title: Text(
                    (widget.selectedLoan.name.toString()).capitalizeFirst(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Detalhes do crédito',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: Colors.white,
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        // Call your delete logic here
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Delete Loan'),
                            content: Text(
                                'Are you sure you want to delete this loan?'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  _removeLoan();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remove Loan',
                              style: TextStyle(
                                color: CupertinoColors.destructiveRed,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              CupertinoIcons.trash,
                              color: CupertinoColors.systemGrey,
                              size: 20,
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
                CreditCardDetailed(
                  selectedLoan: widget.selectedLoan,
                  instalment: _nextPmt,
                  totalInterestPaid: totalInterestPaid.toDouble(),
                  totalPrincipalPaid: totalPrincipalPaid.toDouble(),
                  currentBalance: currentBalance.toDouble(),
                ),
                const SizedBox(height: 10),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TabBar(
                          indicatorColor: const Color.fromARGB(255, 0, 0, 0),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black54,
                          dividerColor: Colors.white,
                          tabs: const [
                            Tab(
                              text: "Visão geral",
                            ),
                            Tab(
                              text: "Pagamentos",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 1100,
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                CreditDetails(
                                    selectedLoan: widget.selectedLoan),
                                SizedBox(height: 10),
                                TaxaDeJuro(
                                  selectedLoan: widget.selectedLoan,
                                  spread:widget.spread,
                                  euribor: currentEuribor,
                                  tan: widget.tan,
                                  periodicidade: widget.rateTerm,
                                ),
                                SizedBox(height: 10),
                                SegurosAssociadosCard(
                                  selectedLoan: widget.selectedLoan,
                                ),
                                SizedBox(height: 10),
                                DetalhesDoImovel(),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.zero,
                                            child: Icon(
                                              Icons.calendar_month,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Próximo Pagamento',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 0, left: 5),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(daysLabel,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFFD18B2F))),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  DetalhesDoPagamento(
                                    entry: current,
                                    date: entryDate,
                                    selectedLoan: widget.selectedLoan,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/piggybank.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Opções de Amortização',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Simule uma amortização ao seu crédito',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 231, 241, 250),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD1FAE5),
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: Icon(
                                          Icons.arrow_downward,
                                          size: 30,
                                          color: Color(0xFF3BB08A),
                                        ),
                                      ),
                                      title: const Text(
                                        'Amortização Parcial',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      subtitle: const Text(
                                        'Reduza o valor em dívida',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      onTap: () {
                                        // Handle tap event here
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 231, 241, 250),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Color(0xFF1B90CD),
                                        ),
                                      ),
                                      title: const Text(
                                        'Pagamento extra',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      subtitle: const Text(
                                        'Subtitle',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      onTap: () {
                                        // Handle tap event here
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  //aviso
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 251, 242, 204),
                                      borderRadius: BorderRadius.circular(8),
                                      // Optional: Add a subtle border
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255,
                                            246,
                                            215,
                                            135), // Adjust to your preference
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Icon on the left
                                        Icon(
                                          Icons
                                              .error_outline, // or Icons.info_outline
                                          color: Colors.orangeAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        // Text on the right
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Comissão de amortização',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFFAF8172)),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'A amortização antecipada está sujeita a uma comissão de 0,5% sobre o valor amortizado.',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFAF8172)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          CupertinoIcons.clock,
                                          size: 20,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      Text(
                                        "Histórico de Pagamentos",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: CupertinoSearchTextField(
                                          controller: _searchController,
                                          backgroundColor:
                                              CupertinoColors.white,
                                          placeholder: 'Pesquisar pagamentos',
                                          // force the input text to be black
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          // optional: make the placeholder grey
                                          placeholderStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 14,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          prefixIcon: Icon(
                                            CupertinoIcons.search,
                                            color: CupertinoColors.systemGrey,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: IconButton(
                                          icon: Icon(
                                            CupertinoIcons.slider_horizontal_3,
                                            size: 24,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                          onPressed: () {
                                            // Open your filter sheet or dialog here
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      itemCount: _filteredSchedule.length,
                                      itemBuilder: (context, index) {
                                        final entry = _filteredSchedule[index];

                                        final dueDate = addMonths(
                                            widget.selectedLoan.startingDate!,
                                            entry.month);

                                        double rate = 0;
                                        if (widget.spread != 0) {
                                          rate = entry.appliedRate! + widget.spread;
                                        } else {
                                          rate = entry.appliedRate!;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: PaymentCard(
                                            date: dueDate,
                                            description: 'Prestação mensal',
                                            method: 'Débito Direto',
                                            amount: entry.payment,
                                            instalment: entry.payment,
                                            principal: entry.principal,
                                            interest: entry.interest,
                                            appliedRate: rate,
                                            onReceiptTap: () {
                                              // optionally fetch/download the receipt for this month
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                final nonZeroRates = widget.rates.where((r) => r.value != 0).toList();
                /*for (int i = 0; i < nonZeroRates.length; i++) {
                  print(nonZeroRates[i]);
                }
                print('TAN: $_tan');
                print('Spread: $spread');*/

                Navigator.push(
                    (context),
                    MaterialPageRoute(
                        builder: (context) => Amortization(
                              selectedLoan: widget.selectedLoan,
                              spread: widget.spread,
                              tan: _tan,
                              rateHistory: nonZeroRates,
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4FD8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simular Amortização',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final DateTime date;
  final String description;
  final String method;
  final double amount;
  final String currency;
  final VoidCallback? onReceiptTap;
  final double instalment;
  final double principal;
  final double interest;
  final double appliedRate;
  const PaymentCard(
      {Key? key,
      required this.date,
      required this.description,
      required this.method,
      required this.amount,
      this.currency = '€',
      this.onReceiptTap,
      required this.instalment,
      required this.interest,
      required this.principal,
      required this.appliedRate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    Color statusColor;

    statusColor = date.isBefore(now)
        ? const Color.fromARGB(255, 222, 248, 218) // date > now
        : const Color(0xFFFFFBEB); // date ≤ now

    String paymentState;

    paymentState = date.isBefore(now) ? "Pago" : "Pagar";

    Color paymentStateColor;

    paymentStateColor = date.isBefore(now)
        ? const Color.fromARGB(255, 67, 207, 24) // date > now
        : const Color(0xFFD18B2F); // date ≤ now

    return Card(
      color: Color.fromARGB(255, 236, 244, 251),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text('${instalment.toStringAsFixed(2)}€',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Prestação Mensal",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.normal)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(paymentState,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: paymentStateColor)),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              color: Colors.grey[400],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mais Informações",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.normal)),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return CupertinoActionSheet(
                          title: Text(
                            'Detalhes da Prestação',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          message: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text(
                                'Data: ${DateFormat('dd MMM yyyy').format(date)}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Valor: ${instalment.toStringAsFixed(2)} €',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Valor Amortizado: ${principal.toStringAsFixed(2)} €',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Juros: ${interest.toStringAsFixed(2)} €',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Taxa Aplicada: ${appliedRate.toStringAsFixed(2)} %',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Descrição: $description',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Método: $method',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Fechar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text, // outline version
                        size: 20,
                        color: Colors.lightBlueAccent,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Info",
                          style: TextStyle(
                              color: Colors.lightBlueAccent, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
