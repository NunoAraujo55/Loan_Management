import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/controllers/contract_values_controller.dart';
import 'package:flutter_amortiza/controllers/user_controller.dart';
import 'package:flutter_amortiza/extensions/string_casing_extension.dart';
import 'package:flutter_amortiza/models/RatePlanPeriod.dart';
import 'package:flutter_amortiza/models/loan_model.dart';
import 'package:flutter_amortiza/screens/credit/amortization.dart';
import 'package:flutter_amortiza/screens/credit/create_credit_screen.dart';
import 'package:flutter_amortiza/screens/credit/credit_screen.dart';
import 'package:flutter_amortiza/screens/credit/credit_simulation.dart';
import 'package:flutter_amortiza/screens/credit/widgets/charts/line_char_widget.dart';
import 'package:flutter_amortiza/screens/home_screen/widgets/credit_widget_detailed.dart';
import 'package:flutter_amortiza/screens/home_screen/widgets/seguro_de_vida.dart';
import 'package:flutter_amortiza/screens/settings/settings.dart';
import 'package:flutter_amortiza/utils/loan_calculations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key})
      : super(
          key: key,
        );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  List<ContractValues> _rates = [];
  double _percentChange = 0;
  final Dio dio = GetIt.instance<Dio>();
  late Future<List<Loan>> futureLoans;
  final List<String> _euribor = ['3 meses', '6 meses', '12 meses'];
  bool isPositive = false;
  bool isNegative = false;
  String? _selectedEuribor;
  // ignore: unused_field
  double _tan = 0;
  // ignore: unused_field
  late double _nextPmt;
  Map<int, List<AmortEntry>> allSchedules = {};
  Map<int, double> loanSpreads = {};
  Map<int, double> loanTans = {};
  Map<int, int> loanPeriodicities = {};
  Map<int, List<ContractValues>> loanRates = {}; 
  
  late int periodicidade;
  @override
  void initState() {
    super.initState();
    _selectedEuribor = _euribor[0];
    final user = Provider.of<UserController>(context, listen: false).user;
    if (user == null) {
      print('User not found');
      return;
    }

    int userId = int.parse(user.id);

    // store the future for the FutureBuilder
    futureLoans = _fetchLoans(userId);

    // once fetched, run the simulations for all loans
    _simulateAllLoans(userId);
  }

  Future<List<double>> getEuriborValues(
      String term, List<DateTime> dates) async {
    try {
      final response = await dio.get('euribor/rate/$term');
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        final dataArray = json['data'] as List<dynamic>;

        if (dataArray.isNotEmpty) {
          final seriesObject = dataArray.first as Map<String, dynamic>;
          final timeSeries = seriesObject['Data'] as List<dynamic>;

          if (timeSeries.isEmpty) {
            throw Exception('Euribor time series is empty.');
          }

          // Agrupa e calcula média por mês (yyyy-MM)
          final Map<String, List<double>> grouped = {};

          for (var entry in timeSeries) {
            final date = DateTime.fromMillisecondsSinceEpoch(entry[0]);
            final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';

            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add((entry[1] as num).toDouble());
          }

          // Calcula média
          final Map<String, double> averagePerMonth = {
            for (var e in grouped.entries)
              e.key: e.value.reduce((a, b) => a + b) / e.value.length
          };

          // Mapeia as datas para os valores médios
          final DateFormat formatter = DateFormat('yyyy-MM');
          return dates.map((date) {
            final key = formatter.format(date);
            return averagePerMonth[key] ?? 0.0;
          }).toList();
        }

        throw Exception('No Euribor data returned.');
      } else {
        throw Exception('Server responded ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Euribor values: $e');
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Erro ao buscar Euribor',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
        displayDuration: const Duration(seconds: 3),
      );
      return List.filled(dates.length, 0.0);
    }
  }
  
  Future<Map<int, List<ContractValues>>> fetchContractValuesGroupedByContract(int loanId) async {
    try {
      final response = await dio.get('contract/value/fetch', queryParameters: {'loanId': loanId});
      // service devolve 200/201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        // precisamos do contract_Id do JSON original para agrupar
        final Map<int, List<ContractValues>> grouped = {};
        for (final raw in data) {
          final map = raw as Map<String, dynamic>;
          final int contractId = (map['contract_Id'] as num).toInt();

          final cv = ContractValues.fromJson(map);
          grouped.putIfAbsent(contractId, () => []);
          grouped[contractId]!.add(cv);
        }
        // ordenar cada lista por startingDate
        for (final entry in grouped.entries) {
          entry.value.sort((a, b) => a.start.compareTo(b.start));
        }
        return grouped;
      } else {
        throw Exception('Server responded ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Erro ao buscar taxas do contrato',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
        displayDuration: const Duration(seconds: 3),
      );
      return {};
    }
  }

  Future<void> _simulateAllLoans(int userId) async {
    try {
      final loans = await _fetchLoans(userId);

      Map<int, List<AmortEntry>> newSchedules = {};

      for (final loan in loans) {
        final now = DateTime.now();

        final contracts = await fetchContractsByLoanId(loan.id!);

        if (contracts.isEmpty) continue;

        contracts.sort((a, b) =>
            DateTime.parse(a['startingDate']).compareTo(DateTime.parse(b['startingDate'])));

        // 2) obter todas as taxas e agrupar por contract_Id
        final groupedByContract = await fetchContractValuesGroupedByContract(loan.id!);

               final periods = <RatePlanPeriod>[];
        for (final c in contracts) {
          final int contractId = c['id'] as int;
          final double spreadC = double.tryParse(c['spread'].toString()) ?? 0;
          final double tanC = double.tryParse(c['tan'].toString()) ?? 0;
          final DateTime startC = DateTime.parse(c['startingDate'].toString());
          final DateTime endC = DateTime.parse(c['endingDate'].toString());

          final values = groupedByContract[contractId] ?? <ContractValues>[];
          periods.add(RatePlanPeriod(
            start: startC,
            end: endC,
            spread: spreadC,
            tan: tanC,
            values: values,
          ));
        }

        // 4) se existir contrato variável, gerir renovação automática de ContractValue nesse contrato
        final variablePeriod = periods.firstWhere(
          (p) => p.values.isNotEmpty,
          orElse: () => periods.last, // se não houver variável, ignora
        );
        if (variablePeriod.values.isNotEmpty) {
          final variableContract = contracts.firstWhere(
            (c) => (groupedByContract[c['id'] as int] ?? const []).isNotEmpty,
          );
          final int variableContractId = variableContract['id'] as int;
          final rates = groupedByContract[variableContractId]!;
          // ordenar por endingDate
          rates.sort((a, b) => a.end.compareTo(b.end));
          final lastRate = rates.last;
          final int periodicidade = rates.first.term;

          final nextDueDate = addMonths(lastRate.end, periodicidade);

          if (!now.isBefore(nextDueDate)) {
            final newPeriodStart = lastRate.end;
            final newPeriodEnd = addMonths(newPeriodStart, periodicidade);
            final termStr = '${periodicidade}meses';

            final values = await getEuriborValues(termStr, [newPeriodEnd]);
            final newValue = values.isNotEmpty ? values.first : 0.0;

            final bool exists =
                rates.any((cv) => cv.start.isAtSameMomentAs(newPeriodStart));

            if (!exists) {
              await dio.post('contract/value/add', data: {
                "contract_Id": variableContractId,
                "startingDate": newPeriodStart.toIso8601String(),
                "endingDate": newPeriodEnd.toIso8601String(),
                "value": newValue,
                "term": periodicidade,
              });
              rates.add(ContractValues(
                start: newPeriodStart,
                end: newPeriodEnd,
                value: newValue,
                term: periodicidade,
              ));
              print(
                  "🟢 Novo ContractValue adicionado (contrato variável $variableContractId): $newValue de $newPeriodStart até $newPeriodEnd");
            } else {
              print("⚠️ ContractValue já existe para $newPeriodStart – ignorado.");
            }
          }
        }
        
        final P = loan.amount!.toDouble() - loan.downPayment!.toDouble();
        final N = loan.creditTerm!.toInt() * 12;
        final startingDate = loan.startingDate!;

        List<AmortEntry> schedule;
        if (periods.length >= 2) {
          schedule = simulateLoanMixed(
            principal: P,
            totalMonths: N,
            startingDate: startingDate,
            periods: periods,
          );
        } else {
          // retrocompatível (um contrato apenas: fixo OU variável simples)
          final single = periods.first;
          schedule = simulateLoan(
            principal: P,
            totalMonths: N,
            startingDate: startingDate,
            contractValues: single.values,
            fallbackTan: single.tan,
            spread: single.spread,
          );
        }
        newSchedules[loan.id!] = schedule;
        

        RatePlanPeriod activePeriod;
        try {
          activePeriod = periods.firstWhere((p) => p.contains(now));
        } catch (_) {
          // se já passou do fim do último período, usa o último
          activePeriod = periods.last;
        }
         loanSpreads[loan.id!] = activePeriod.spread;
        loanTans[loan.id!] = activePeriod.tan;
        loanPeriodicities[loan.id!] =
            activePeriod.values.isNotEmpty ? (activePeriod.values.first.term) : 0;
        loanRates[loan.id!] = periods.expand((p) => p.values).toList();

        print("✅ Simulated loan ${loan.id} → ${schedule.length} entries");
      }

      setState(() {
        allSchedules = newSchedules;
      });

      print("✅ All loan simulations done.");
    } catch (e) {
      print("Error simulating loans: $e");
    }
  }

  Future<List<ContractValues>> fetchContractValues(int loanId) async {
    try {
      final response = await dio.get(
        'contract/value/fetch',
        queryParameters: {'loanId': loanId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        periodicidade = data.isNotEmpty ? data[0]['term'] ?? 0 : 0;
        final values = data
            .map(
                (json) => ContractValues.fromJson(json as Map<String, dynamic>))
            .toList();

        return values;
      } else {
        throw Exception('Server responded ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Erro ao buscar taxas do contrato',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
        displayDuration: const Duration(seconds: 3),
      );
      return [];
    }
  }

  int _currentIndex = 0; // index 0 represents the homescreen
  final Color bgColor = Colors.transparent;

  final List<Widget> _navigationItem = [
    const Icon(Icons.home, color: Colors.white),
    const Icon(Icons.add, color: Colors.white),
    const Icon(Icons.settings, color: Colors.white),
  ];

  Future<List<Loan>> _fetchLoans(int userId) async {
    try {
      final response =
          await dio.get('credit/fetch', queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Loan> loans = data.map((json) => Loan.fromJson(json)).toList();
        print(loans);
        return loans;
      } else {
        throw Exception(
            'Erro ao carregar os loans. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchContractsByLoanId(int loanId) async {
    try {
      final response =
          await dio.get('contract/fetchByloanId', queryParameters: {
        'loanId': loanId,
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch contracts: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching contracts: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserController>(context).user;
    if (_percentChange <= 0) {
      isPositive = false;
      isNegative = true;
    } else {
      isPositive = true;
      isNegative = false;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Olá, ",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: (user?.name ?? '').capitalizeFirst(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1388BE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Os meus Créditos",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  "Faz a gestão dos teus créditos",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateCreditScreen(
                                              user: user!,
                                            )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Loan>>(
                      future: futureLoans,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        } else {
                          final loans = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: loans.length,
                            itemBuilder: (context, index) {
                              final loan = loans[index];

                              // 👉 Get this loan’s amortization schedule
                              final List<AmortEntry>? schedule =
                                  allSchedules[loan.id];

                              // Default fallback values
                              double spreadValue = 0;
                              double euriborValue = 0;
                              int rateTerm = 0;
                              double installment =
                                  loan.instalment?.toDouble() ?? 0;

                              if (schedule != null && schedule.isNotEmpty) {
                                euriborValue = schedule.last.appliedRate!;
                                spreadValue = loanSpreads[loan.id] ?? 0;
                                rateTerm = loanPeriodicities[loan.id] ?? 0;
                                // ✅ Aqui: calcula a prestação mais próxima de hoje
                                final now = DateTime.now();
                                final paidMonths =
                                    monthsBetween(loan.startingDate!, now);

                                final idx =
                                    (paidMonths).clamp(0, schedule.length - 1);
                                installment = schedule[idx].payment;
                                /*print(
                                    "idx: $idx | schedule[idx].payment: ${schedule[idx].payment} | rate: ${schedule[idx].appliedRate}");*/
                              }
                              print("✅ All loans spread and tan info ${loanSpreads[loan.id]} | ${loanTans[loan.id]} | ${loanPeriodicities[loan.id]}");
                              return GestureDetector(
                                onTap: () {
                                  final schedule = allSchedules[loan.id] ?? [];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreditScreen(selectedLoan: loan, schedule: schedule, rates: loanRates[loan.id] ?? [],
                                                        spread: loanSpreads[loan.id] ?? 0,
                                                        tan:    loanTans[loan.id] ?? 0, rateTerm: rateTerm,),
                                    ),
                                  );
                                },
                                child: CreditIBox(
                                  title: loan.name.toString(),
                                  amount: loan.amount.toString(),
                                  term: loan.creditTerm.toString(),
                                  spread: spreadValue.toStringAsFixed(2),
                                  euribor: euriborValue.toStringAsFixed(2),
                                  euriborDuration: _selectedEuribor ?? "",
                                  installment: installment.toStringAsFixed(2),
                                  rateTerm: rateTerm.toString(),
                                  tan: (loanTans[loan.id] ?? 0)
                                      .toStringAsFixed(2),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Evolução da Euribor",
                                      style: TextStyle(
                                        color: Color(0xFF002E8B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Visibility(
                                      visible: isPositive,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFFFBEB),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color:
                                                          Color(0xFFFEF4CE))),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Image.asset(
                                                      'assets/trend.png',
                                                      width: 13,
                                                      height: 13,
                                                      color: Color(0xFFC16F41),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_percentChange.toStringAsFixed(2)} %',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFC16F41),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: isNegative,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 235, 255, 235),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 206, 254, 220))),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Image.asset(
                                                      'assets/downtrend.png',
                                                      width: 13,
                                                      height: 13,
                                                      color: Color.fromARGB(
                                                          255, 65, 193, 95),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_percentChange.toStringAsFixed(2)} %',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 65, 193, 82),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(
                                        0xFFE6F0FA), // Light gray background
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: _selectedEuribor,
                                      onChanged: (val) => setState(
                                          () => _selectedEuribor = val),
                                      isDense: true,
                                      style: TextStyle(
                                          color: Color(0xFF0077CC),
                                          fontSize: 12),
                                      icon: Icon(Icons.arrow_drop_down,
                                          size: 18, color: Color(0xFF0077CC)),
                                      items: _euribor
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              'Valores dos últimos 12 meses',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Center(
                                        child: LineCharWidget(
                                  euribor:
                                      _selectedEuribor?.replaceAll(' ', '') ??
                                          '3meses',
                                  onPercentChange: (change) {
                                    setState(() {
                                      _percentChange = change;
                                    });
                                  },
                                ))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*const SizedBox(height: 30),
                    const Text(
                      "Evolução da Euribor no Último Ano",
                      style: TextStyle(
                        color: Color(0xFF002E8B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Consulte abaixo como os preços da Euribor variaram ao longo dos últimos 12 meses.",
                      style: TextStyle(
                        color: Color(0xFF1388BE),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Expanded(child: Center(child: LineCharWidget())),
                      ],
                    ),*/
                    const SizedBox(
                      height: 10,
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0283C7), Color(0xFF1D4FD8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            const Text(
                              "Simule um Novo Empréstimo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtítulo
                            const Text(
                              "Descubra as melhores condições para o seu próximo imóvel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Linha 1: Taxas competitivas
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF3698D3),
                                  ),
                                  child: const Icon(
                                    Icons.percent,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Teste diferentes taxas",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Spreads a partir de 0,95%",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Linha 2: Prazos flexíveis
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF3698D3),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Prazos flexíveis",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Até 40 anos para pagar",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Botão "Fazer Simulação"
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreditSimulation(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Fazer Simulação",
                                      style: TextStyle(
                                        color: Color(0xFF2182C2),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF2182C2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SeguroDeVidaCard(),
                    /*const SizedBox(height: 60),
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreditSimulation()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB700),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Simular Crédito",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),*/
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        color: const Color(0xFF002E8B),
        index: _currentIndex,
        items: _navigationItem,
        backgroundColor: bgColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          Future.delayed(const Duration(milliseconds: 600), () {
            if (index == 0) {
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateCreditScreen(
                          user: user!,
                        )),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                          user: user!,
                        )),
              );
            }
          });
        },
      ),
    );
  }
}
