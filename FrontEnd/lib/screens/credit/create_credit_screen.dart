import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/controllers/user_controller.dart';
import 'package:flutter_amortiza/models/user_model.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';
import 'package:flutter_amortiza/screens/home_screen/home_screen.dart';
import 'package:flutter_amortiza/screens/settings/settings.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreateCreditScreen extends StatefulWidget {
  final User user;
  CreateCreditScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CreateCreditScreen> createState() => _CreateCreditScreenState();
}

class _CreateCreditScreenState extends State<CreateCreditScreen> {
  final Dio dio = GetIt.instance<Dio>();

  // index 1 represents the screen create credit
  int _currentIndex = 1;
  DateTime? _selectedDate;
  late String dateText;
  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy', 'pt_PT').format(d);
  final Color bgColor = Colors.transparent;

  final List<Widget> _navigationItem = [
    const Icon(Icons.home, color: Colors.white),
    const Icon(Icons.add, color: Colors.white),
    const Icon(Icons.settings, color: Colors.white),
  ];

  // Controlers for the text inputs
  final montanteController = TextEditingController();
  final prazoController = TextEditingController();
  final entradaController = TextEditingController();
  final despesasController = TextEditingController();
  final spreadController = TextEditingController();
  //final euriborController = TextEditingController();
  final seguroController = TextEditingController();
  final outrosController = TextEditingController();
  final bancoController = TextEditingController();
  final nameController = TextEditingController();
  final tanController = TextEditingController();
  final FixedTermController = TextEditingController();

  final List<String> _TipoEuribor = ['3 meses', '6 meses', '12 meses'];
  final List<String> _TipoDeTaxa = ['Fixa', 'Variável', 'Mista'];
  String? _selectedEuribor;
  String? _selectedTipoTaxa;
  final List<TextEditingController> _insuranceNameCtrls = [];
  final List<TextEditingController> _insuranceAmountCtrls = [];
  bool visibleTaxas = false;
  bool visibleTaxaFixa = false;
  bool visibleTaxaMista = false;


  List<DateTime> calculateEuriborPeriods(DateTime start, int monthsStep) {
    final now = DateTime.now();
    List<DateTime> dates = [];

    DateTime reset = start;
    int k = 0;
    while (reset.isBefore(now)) {
      if (k == 0) {
        // first fixing → same month as start
        dates.add(DateTime(reset.year, reset.month, 1));
      } else {
        // subsequent fixings → previous month of the reset month
        dates.add(DateTime(reset.year, reset.month - 1, 1));
      }
      reset = addMonths(reset, monthsStep);
      k++;
    }
    return dates;
  }

  DateTime _lastAvailableEuriborDate(DateTime date) {
      // Move backwards until we find a weekday (no weekends/holidays)
      DateTime eval = date;
      while (eval.weekday == DateTime.saturday || eval.weekday == DateTime.sunday) {
        eval = eval.subtract(Duration(days: 1));
      }
      // For actual banking rules you might check official publication calendar here
      return eval;
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

  DateTime addMonths(DateTime date, int monthsToAdd) {
    final newYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
    final newMonth = ((date.month + monthsToAdd - 1) % 12) + 1;

    final day = date.day;
    final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > lastDayOfNewMonth ? lastDayOfNewMonth : day;

    return DateTime(newYear, newMonth, newDay);
  }

  int _euriborMonths(String? sel) {
  switch (sel) {
    case '3 meses':  return 3;
    case '6 meses':  return 6;
    case '12 meses': return 12;
    default:         return 0;
  }
}

String _euriborSlug(String? sel) {
  switch (sel) {
    case '3 meses':  return '3meses';
    case '6 meses':  return '6meses';
    case '12 meses': return '12meses';
    default:         return '';
  }
}


  Future<void> _creatloan() async {
    final user = Provider.of<UserController>(context, listen: false).user;

    if (user == null) {
      print("User not found");
      return;
    }

    try {
      final downPayment = double.tryParse(entradaController.text);
      final creditTerm = double.tryParse(prazoController.text);
      //var euribor = double.tryParse(euriborController.text);
      var euribor = 0;
      var spread = double.tryParse(spreadController.text);
      final amount = double.tryParse(montanteController.text);
      final name = nameController.text;
      var tan = double.tryParse(tanController.text);
      var fixedTerm = int.tryParse(FixedTermController.text);
      /*print('downPayment: $downPayment');
      print('creditTerm: $creditTerm');
      print('euribor: $euribor');
      print('spread: $spread');
      print('amount: $amount');
      print('name: "$name"');
      print('valorAtual: $valorAtual');*/

      if (downPayment == null ||
          creditTerm == null ||
          name == '' ||
          amount == null ||
          _selectedDate == null) {
        print("One or more fields contain invalid numbers.");
        showTopSnackBar(
          Overlay.of(context),
          AwesomeSnackbarContent(
            title: 'Erro',
            message: 'Preencha todos os campos',
            contentType: ContentType.failure,
          ),
          displayDuration: Duration(seconds: 3),
        );
        return;
      }

      if (_selectedTipoTaxa == _TipoDeTaxa[0]) {
        // Fixa
        if (tan == null) {
          showTopSnackBar(
            Overlay.of(context),
            AwesomeSnackbarContent(
              title: 'Erro',
              message: 'Defina um valor para a TAN.',
              contentType: ContentType.failure,
            ),
            displayDuration: Duration(seconds: 3),
          );
          return;
        }
      } else {
        // Variável or Mista
        if (spread == null) {
          showTopSnackBar(
            Overlay.of(context),
            AwesomeSnackbarContent(
              title: 'Erro',
              message: 'Defina os valores de Spread.',
              contentType: ContentType.failure,
            ),
            displayDuration: Duration(seconds: 3),
          );
          return;
        }
      }

      final insurances = <Map<String, dynamic>>[];
      for (int i = 0; i < _insuranceNameCtrls.length; i++) {
        final name = _insuranceNameCtrls[i].text;
        final amt = double.tryParse(_insuranceAmountCtrls[i].text);
        if (name.isNotEmpty && amt != null) {
          insurances.add({"Insurance": amt, "name": name});
        }
      }

      if (_selectedTipoTaxa == _TipoDeTaxa[0]) {
        // Fixa
        spread = 0;
        euribor = 0;
      } else if (_selectedTipoTaxa == _TipoDeTaxa[1]) {
        tan = 0;
      }

      final response = await dio.post('credit/add', data: {
        'DownPayment': downPayment,
        'CreditTerm': creditTerm,
        'userId': double.parse(user.id),
        'amount': amount,
        'name': name,
        'startingDate': _selectedDate?.toIso8601String(),
        'insurances': insurances,
      });

      print(response);

      if (response.statusCode == 201 && _selectedTipoTaxa == _TipoDeTaxa[1]) {
        final loanId = response.data['id'];

        final term = response.data['CreditTerm'];
        final termInMonths = (term * 12).toInt();
        DateTime startingDate = _selectedDate!;
        DateTime endingDate = addMonths(startingDate, termInMonths);

        /*if (_selectedEuribor == _TipoEuribor[0]) {
          endingDate = DateTime(
              startingDate.year, startingDate.month + 3, startingDate.day);
        } else if (_selectedEuribor == _TipoEuribor[1]) {
          endingDate = DateTime(
              startingDate.year, startingDate.month + 6, startingDate.day);
        } else if (_selectedEuribor == _TipoEuribor[2]) {
          endingDate = DateTime(
              startingDate.year, startingDate.month + 12, startingDate.day);
        }*/

        print('loanId: $loanId');
        print('startingDate: $startingDate');
        print('endingDate: $endingDate');
        print('spread: $euribor');

        final contractResponse = await dio.post('contract/add', data: {
          "loanId": loanId,
          "startingDate": startingDate.toIso8601String(),
          "endingDate": endingDate.toIso8601String(),
          "spread": spread,
          "tan": 0,
        });

        if (contractResponse.statusCode == 201) {
          final contractId = contractResponse.data['id'];

            final int months = _euriborMonths(_selectedEuribor);
          final String termSlug = _euriborSlug(_selectedEuribor);
          if (months == 0 || termSlug.isEmpty) {
            print('Escolhe a periodicidade da Euribor.');
            return;
          }

          // calcular datas de troca de euribor
          final List<DateTime> dates =
              calculateEuriborPeriods(_selectedDate!, months);
          print(dates);

          //get values da euribor para essas datas
          final List<double> values = await getEuriborValues(termSlug, dates);
          for (int i = 0; i < dates.length; i++) {
            print('${dates[i].toIso8601String()} → ${values[i]}');
          }

          for (int i = 0; i < dates.length; i++) {
            print('${dates[i].toIso8601String()} → ${values[i]}');
          }

          for (int i = 0; i < values.length; i++) {
            final evaluationDate = dates[i];
            print("evaluationDate: ${evaluationDate.toIso8601String()}");
            final DateTime periodStart = (i == 0)
                ? DateTime(_selectedDate!.year, _selectedDate!.month, 1)
                : DateTime(
                    addMonths(_selectedDate!, i * months).year,
                    addMonths(_selectedDate!, i * months).month,
                    1,
                  );

            final DateTime periodEnd = addMonths(periodStart, months);
            print(contractId);
            print(periodEnd);
            print(periodStart);
            print(values[i]);
            

            await dio.post('contract/value/add', data: {
              "contract_Id": contractId,
              "startingDate": periodStart.toIso8601String(),
              "endingDate": periodEnd.toIso8601String(),
              "value": values[i],
              "term": months, 
            });
          }
        }

        showTopSnackBar(
          Overlay.of(context),
          AwesomeSnackbarContent(
            title: 'Crédito Adicionado',
            message: 'Crédito adicionado com sucesso',
            contentType: ContentType.success,
          ),
          displayDuration: Duration(seconds: 3),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        });
      } else if (response.statusCode == 201 &&
          _selectedTipoTaxa == _TipoDeTaxa[0]) {
        final loanId = response.data['id'];
        final term = response.data['CreditTerm'];
        final termInMonths = (term * 12).toInt();
        DateTime startingDate = _selectedDate!;

        DateTime endingDate = addMonths(startingDate, termInMonths);

        // ignore: unused_local_variable
        final contractResponse = await dio.post('contract/add', data: {
          "loanId": loanId,
          "startingDate": startingDate.toIso8601String(),
          "endingDate": endingDate.toIso8601String(),
          "spread": 0,
          "tan": tan,
        });

        showTopSnackBar(
          Overlay.of(context),
          AwesomeSnackbarContent(
            title: 'Crédito Adicionado',
            message: 'Crédito adicionado com sucesso',
            contentType: ContentType.success,
          ),
          displayDuration: Duration(seconds: 3),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        });
        // adicionar if para a taxa mista, Taxa Mista é o numero [2]
        // verificar o numero de contratos existentes, guardar em array
        // verificar por datas de finalização de contratos
        // caso periodo fixo ja tenha acabado, chamar o contract value
      } else if (response.statusCode == 201 &&
          _selectedTipoTaxa == _TipoDeTaxa[2]) {
        final loanId = response.data['id'];
        final term = response.data['CreditTerm'];
        final termInMonths = (term * 12).toInt();
        DateTime startingDate = _selectedDate!;
        if (fixedTerm == null || tan == null || spread == null) {
          print("Periodo fixo precisa de ser definido");
          return;
        } else if (tan == 0) {
          print("TAN tem de ser superior a 0");
        }
        final fixedtermInMonths = fixedTerm * 12;
        DateTime endingDateFixa = addMonths(startingDate, fixedtermInMonths);

        print("\n\n--------- Fixa --------");
        print("periodo fixo em meses: $fixedtermInMonths");
        print("Inicio do periodo de taxa fixa: $startingDate");
        print("Fim do periodo de taxa fixa: $endingDateFixa");
        print(tan);
        print(spread);

        final contractResponseFixa = await dio.post('contract/add', data: {
          "loanId": loanId,
          "startingDate": startingDate.toIso8601String(),
          "endingDate": endingDateFixa.toIso8601String(),
          "spread": 0,
          "tan": tan,
        });
        print(contractResponseFixa);

        DateTime startingDateVariavel = endingDateFixa;

        final termAfterFixed = termInMonths - fixedtermInMonths;
        DateTime endingDateVariavel =
            addMonths(startingDateVariavel, termAfterFixed);

        //Calcular data finalVariavel - periodo de credito menos tempo de taxa fixa.
        // Parte Variável

        print("\n\n--------- Variável --------");
        print('loanId: $loanId');
        print('startingDate: $startingDateVariavel');
        print('endingDate: $endingDateVariavel');
        print('spread: $spread');
        print('tan: 0');

        final contractResponseVariavel = await dio.post('contract/add', data: {
          "loanId": loanId,
          "startingDate": startingDateVariavel.toIso8601String(),
          "endingDate": endingDateVariavel.toIso8601String(),
          "spread": spread,
          "tan": 0,
        });

        if (contractResponseVariavel.statusCode == 201) {
          final contractId = contractResponseVariavel.data['id'];

          final int months = _euriborMonths(_selectedEuribor);
          final String termSlug = _euriborSlug(_selectedEuribor);

        if (months == 0 || termSlug.isEmpty) {
          print('Escolhe a periodicidade da Euribor.');
          return;
        }

          // calcular datas de troca de euribor
          final List<DateTime> dates =
              calculateEuriborPeriods(startingDateVariavel, months);
          print("datas da euribor: $dates");

          //get values da euribor para essas datas
          final List<double> values = await getEuriborValues(termSlug, dates);
          for (int i = 0; i < dates.length; i++) {
            print("${dates[i].toIso8601String()} → ${values[i]}");
          }


          for (int i = 0; i < dates.length; i++) {
            print('${dates[i].toIso8601String()} → ${values[i]}');
          }

          for (int i = 0; i < values.length; i++) {
            final evaluationDate = dates[i];
            final periodStart =
                DateTime(evaluationDate.year, evaluationDate.month + 1, 1);
            final periodEnd = DateTime(
              periodStart.year,
              periodStart.month + months,
              periodStart.day,
            );
            print(contractId);
            print(periodEnd);
            print(periodStart);
            print(values[i]);
            await dio.post('contract/value/add', data: {
              "contract_Id": contractId,
              "startingDate": periodStart.toIso8601String(),
              "endingDate": periodEnd.toIso8601String(),
              "value": values[i],
              "term": months,
            });
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          });
        }
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      print('⚠️  HTTP $status → $body');
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops',
          message: 'fill all the fields and check the data type',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _insuranceNameCtrls.add(TextEditingController());
    _insuranceAmountCtrls.add(TextEditingController());
    _selectedDate = DateTime.now();
    dateText = _fmt(_selectedDate!);
  }

  @override
  void dispose() {
    montanteController.dispose();
    prazoController.dispose();
    entradaController.dispose();
    despesasController.dispose();
    spreadController.dispose();
    //euriborController.dispose();
    seguroController.dispose();
    outrosController.dispose();
    bancoController.dispose();
    nameController.dispose();
    tanController.dispose();
    FixedTermController.dispose();
    for (final c in _insuranceNameCtrls) {
      c.dispose();
    }
    for (final c in _insuranceAmountCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _showCupertinoDatePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.40, // a little taller
          child: Column(
            children: [
              // 1) The date picker itself
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.light,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: _selectedDate ?? DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                    mode: CupertinoDatePickerMode.date,
                  ),
                ),
              ),

              // 3) The confirmation button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          dateText = _fmt(_selectedDate ?? DateTime.now());
                        });
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: CupertinoColors.activeBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Selecionar Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isSubmitting = false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),*/
        title: const Text(
          'Adicionar Crédito',
          style: TextStyle(
              color: Color(0xFF457E95),
              fontSize: 13,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF002E8B),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Adicionar Crédito',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Nuno',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      ', queremos ajudar a dar vida aos teus projetos.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 80),
                          child: Text(
                            'Simplifique a gestão dos\nseus créditos com facilidade.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Positioned(
                    bottom: -5,
                    right: 0,
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.asset(
                        'assets/loan.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.creditcard,
                      color: CupertinoColors.activeBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Detalhes do Crédito',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.label,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: nameController,
                  name: "Nome do crédito",
                  inputType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  controller: montanteController,
                  name: "Montante contratado",
                  inputType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  controller: entradaController,
                  name: "Montante de entrada",
                  inputType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: prazoController,
                        name: "Prazo",
                        inputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        value: _selectedTipoTaxa,
                        hint: const Text(
                          'Tipo de Taxa',
                          style: TextStyle(color: Colors.black),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black54),
                        items: _TipoDeTaxa.map((e) {
                          return DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedTipoTaxa = val);
                          // TAXA FIXA
                          if (_selectedTipoTaxa == _TipoDeTaxa[0]) {
                            visibleTaxas = false;
                            visibleTaxaFixa = true;
                            visibleTaxaMista = false;
                            //TAXA VARIÁVEL
                          } else if (_selectedTipoTaxa == _TipoDeTaxa[1]) {
                            visibleTaxas = true;
                            visibleTaxaFixa = false;
                            visibleTaxaMista = false;
                            //TAXA MISTA
                          } else {
                            visibleTaxaFixa = false;
                            visibleTaxas = true;
                            visibleTaxaMista = true;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: visibleTaxas,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: spreadController,
                          name: "Spread(%)",
                          inputType: TextInputType.number,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          value: _selectedEuribor,
                          hint: const Text(
                            'Periodicidade',
                            style: TextStyle(color: Colors.black),
                          ),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black54),
                          items: _TipoEuribor.map((e) {
                            return DropdownMenuItem<String>(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedEuribor = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: visibleTaxaFixa,
                  child: CustomTextField(
                    controller: tanController,
                    name: "TAN",
                    inputType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: visibleTaxaMista,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: FixedTermController,
                          name: "Periodo de taxa fixa (Anos)",
                          inputType: TextInputType.number,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: tanController,
                          name: "TAN (%)",
                          inputType: TextInputType.number,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      color: CupertinoColors.activeBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Data de Contratação',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.label,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _showCupertinoDatePicker,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      dateText,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Card(
                  elevation: 0,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.shield_lefthalf_fill,
                                color: CupertinoColors.activeBlue),
                            const SizedBox(width: 10),
                            Text(
                              'Seguros Associados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        for (int i = 0; i < _insuranceNameCtrls.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              tilePadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.circle_fill,
                                    size: 10,
                                    color: i == 0
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Seguro ${i + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _insuranceNameCtrls.removeAt(i);
                                        _insuranceAmountCtrls.removeAt(i);
                                      });
                                    },
                                    child: Icon(CupertinoIcons.delete_solid,
                                        size: 20,
                                        color: CupertinoColors.inactiveGray),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _insuranceNameCtrls[i],
                                        name: "Nome do Seguro",
                                        inputType: TextInputType.text,
                                      ),
                                      const SizedBox(height: 12),
                                      CustomTextField(
                                        controller: _insuranceAmountCtrls[i],
                                        name: "Valor Mensal",
                                        inputType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _insuranceNameCtrls.add(TextEditingController());
                              _insuranceAmountCtrls
                                  .add(TextEditingController());
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.add,
                                      color: CupertinoColors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Adicionar Seguro',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.white,
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
                const SizedBox(
                  height: 20,
                ),
              ],
            ),

            // Botão para adicionar crédito
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () async {
    await _creatloan();
  },
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(15)),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.blue)))),
                  child: const Text(
                    "ADICIONAR CRÉDITO",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            )
          ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else if (index == 1) {
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                          user: widget.user,
                        )),
              );
            }
          });
        },
      ),
    );
  }
}
