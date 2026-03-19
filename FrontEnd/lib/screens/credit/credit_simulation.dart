import 'package:dio/dio.dart';
import 'package:flutter_amortiza/PDF/pdf_api.dart';
import 'package:flutter_amortiza/PDF/save_and_open_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/credit_info_row.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/credit_info_row_title.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';
import 'package:flutter_amortiza/screens/home_costs/house_costs.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get_it/get_it.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:math';

class CreditSimulation extends StatefulWidget {
  const CreditSimulation({Key? key}) : super(key: key);

  @override
  State<CreditSimulation> createState() => _CreditSimulationState();
}

class _CreditSimulationState extends State<CreditSimulation> {
  final Dio dio = GetIt.instance<Dio>();

  double? euriborRate;

  final montanteController = TextEditingController();
  final prazoController = TextEditingController();
  final entradaController = TextEditingController();
  final despesasController = TextEditingController();
  final spreadController = TextEditingController();
  final salarioController = TextEditingController();



  final List<String> _euribor = ['3 meses', '6 meses', '12 meses'];

  String? _selectedEuribor;

  double prestacao = 0.0;
  double taxaDeEsforco = 0.0;
  double montanteContratado = 0.0;
  double prazoEmMeses = 0;

  bool showDetails = false;
 
  final Color bgColor = Colors.transparent;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();

  Future<double> getEuriborValue(String term) async {
    try {
      final response = await dio.get('euribor/rate/$term');
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        final dataArray = json['data'] as List<dynamic>;
        if (dataArray.isNotEmpty) {
          final seriesObject = dataArray.first as Map<String, dynamic>;
          final timeSeries = seriesObject['Data'] as List<dynamic>;
          if (timeSeries.isNotEmpty) {
            final lastPair = timeSeries.last as List<dynamic>;
            print(lastPair);
            return (lastPair[1] as num).toDouble();
          }
        }
        throw Exception('No Euribor data returned.');
      } else {
        throw Exception('Server responded ${response.statusCode}');
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Erro ao buscar Euribor',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
        displayDuration: const Duration(seconds: 3),
      );
      return 0.0;
    }
  }

  double calcmontanteContratado() {
    final double? montante = double.tryParse(montanteController.text);
    final double? entrada = double.tryParse(entradaController.text);

    if (montante == null || entrada == null) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Preencha todos os valores!',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );

      return 0.0;
    }
    return montante - entrada;
  }

  double calcLoan() {
    //converting the strings to doubles
    final double? montante = double.tryParse(montanteController.text);
    final double? prazo = double.tryParse(prazoController.text);
    final double? entrada = double.tryParse(entradaController.text);
    final double? despesas = double.tryParse(despesasController.text);
    final double? spread = double.tryParse(spreadController.text);
    final double? salario = double.tryParse(salarioController.text);

    //check if any value is null
    if (montante == null ||
        prazo == null ||
        entrada == null ||
        despesas == null ||
        spread == null ||
        euriborRate == null ||
        salario == null) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Preencha todos os valores!',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    } else if (entrada >= montante) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message:
              'O montante de entrada não pode ser superior ao valor do crédito!',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    } else if (despesas >= salario) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'As despesas não podem ser superiores ao salário!',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    } else if (prazo > 40) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'O prazo máximo é de 40 anos',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    }
    double meses = prazo * 12;
    double prestacaoMensal = 0.00;
    double taxaAnual = (spread + euriborRate!) / 100;
    double taxaMensal = taxaAnual / 12;
    double montanteAposEntrada = montante - entrada;
    //loan calc
    prestacaoMensal =
        (montanteAposEntrada * taxaMensal) / (1 - pow(1 + taxaMensal, -meses));

    return prestacaoMensal;
  }

  double calcTaxaDeEsforco() {
    final double? despesas = double.tryParse(despesasController.text);
    final double? salario = double.tryParse(salarioController.text);

    if (despesas == null || salario == null) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Os campos despesas e salario têm de estar preenchidos',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    } else if (despesas >= salario) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'As despesas não podem ser superiores ao salário',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return 0.0;
    }

    final double salarioSemSespesas = salario - despesas;
    // Use the already-computed prestacao instead of calling calcLoan() again
    final double prestacaoMensal = prestacao;

    final double taxadeesforco = (prestacaoMensal / salarioSemSespesas) * 100;

    if (taxadeesforco <= 35) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Taxa de esforço baixa',
          message: 'Alta probabilidade de ser aprovado',
          contentType: ContentType.success,
        ),
        displayDuration: Duration(seconds: 4),
      );
    } else if (taxadeesforco > 35 && taxadeesforco <= 49) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Taxa de esforço alta',
          message: 'Baixa probabilidade de ser aprovado',
          contentType: ContentType.warning,
        ),
        displayDuration: Duration(seconds: 4),
      );
    } else {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Taxa de esforço muito alta',
          message: 'O crédito não irá ser aprovado',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 4),
      );
    }
    return taxadeesforco;
  }

  // not permanent... just so that i dont forget
  double calcImpostoSelo() {
    double valordoImovel = 0.0;
    double IS = valordoImovel * 0.08;
    return IS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SafeArea(
            child: Text(
              'Simular Crédito',
              style: TextStyle(
                color: Color(0xFF457E95),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF002E8B)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Simular Crédito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
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
                          SizedBox(height: 15),
                          Text(
                            'Simplifique a gestão dos\nseus créditos com facilidade.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -10,
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
              CustomTextField(
                controller: montanteController,
                name: "Montante contratado",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              CustomTextField(
                controller: prazoController,
                name: "Prazo do crédito (em Anos)",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              CustomTextField(
                controller: entradaController,
                name: "Montante de entrada",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              CustomTextField(
                controller: salarioController,
                name: "Salário",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              CustomTextField(
                controller: despesasController,
                name: "Despesas mensais",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              CustomTextField(
                controller: spreadController,
                name: "valor do spread(%)",
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                value: _selectedEuribor,
                hint: const Text(
                  'Periodicidade',
                  style: TextStyle(color: Colors.black),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                items: _euribor.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedEuribor = val);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_selectedEuribor == null) {
                        showTopSnackBar(
                          Overlay.of(context),
                          AwesomeSnackbarContent(
                            title: 'Ops!',
                            message: 'Selecione o tipo de Euribor',
                            contentType: ContentType.failure,
                          ),
                          displayDuration: Duration(seconds: 3),
                        );
                        return;
                      }
                      try {
                        final term = _selectedEuribor!.replaceAll(' ', '');
                        final rate = await getEuriborValue(term);

                        setState(() {
                          euriborRate = rate;
                          prestacao = calcLoan();
                          taxaDeEsforco = calcTaxaDeEsforco();
                          montanteContratado = calcmontanteContratado();
                          showDetails = prestacao > 0;
                        });
                        if (showDetails) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_detailsKey.currentContext != null) {
                              Scrollable.ensureVisible(
                                _detailsKey.currentContext!,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        }
                      } catch (e) {
                        showTopSnackBar(
                          Overlay.of(context),
                          AwesomeSnackbarContent(
                            title: 'Erro',
                            message: e.toString(),
                            contentType: ContentType.failure,
                          ),
                          displayDuration: Duration(seconds: 5),
                        );
                      }
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "SIMULAR CRÉDITO",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          "assets/reload-arrow.png",
                          height: 25,
                          width: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Visibility(
                key: _detailsKey,
                visible: showDetails && prestacao != 0.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          icon: RotatedBox(
                            quarterTurns: 1,
                            child: Icon(
                              Icons.more_vert_outlined,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          onSelected: (value) async {
                            if (value == 'saveSimulation') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Exported to PDF")),
                              );
                            } else if (value == 'export') {
                              final double prazoEmAnos =
                                  double.tryParse(prazoController.text) ?? 0;
                              final int prazoEmMeses =
                                  (prazoEmAnos * 12).toInt();
                              final pdf = await Pdfapi.generatePdf(
                                'Nuno Araújo',
                                montanteContratado.toStringAsFixed(3),
                                montanteController.text,
                                prestacao.toStringAsFixed(2),
                                spreadController.text,
                                euriborRate.toString(),
                                prazoEmMeses.toString(),
                              );
                              Saveandopenpdf.openPdf(pdf);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'saveSimulation',
                                child: Text('Save'),
                              ),
                              PopupMenuItem<String>(
                                value: 'export',
                                child: Text('Export to pdf'),
                              ),
                            ];
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "A prestação mensal é de:",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "${prestacao.toStringAsFixed(2)} €",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Seguros e despesas incluídos",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInfoRowtitle(
                                begin: "Finalidade", end: "Habitação"),
                            CustomInfoRow(
                              begin: "Tan",
                              end: euriborRate != null &&
                                      spreadController.text.isNotEmpty
                                  ? "${(euriborRate! + double.parse(spreadController.text)).toStringAsFixed(2)} %"
                                  : "—",
                            ),

                            CustomInfoRow(
                                begin: "Prestação",
                                end: "${prestacao.toStringAsFixed(2)} €"),
                            CustomInfoRow(
                                begin: "Taxa de esforço",
                                end:
                                    "${taxaDeEsforco.toStringAsFixed(2)} %"), //"${montanteContratado.toStringAsFixed(2)} €"
                            CustomInfoRow(
                                begin: "Montante imputado",
                                end:
                                    "${montanteContratado.toStringAsFixed(2)} €"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2, // optional subtle shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Calcule os custos associados à compra de Habitação',
                              style: TextStyle(
                                color: Color(0xFF1388BE),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // "Distrito" dropdown
                            /*DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Distrito',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  // You can also customize the border color if needed:
                                  // borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: selectedValue1,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue1 = newValue!;
                                });
                              },
                              items: dropdownItems1
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),

                            // "Município" dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Município',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  // You can also customize the border color if needed:
                                  // borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: selectedValue2,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue2 = newValue!;
                                });
                              },
                              items: dropdownItems2
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),

                            const SizedBox(height: 24),
                            */
                            // Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseCosts(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 16, 38, 148),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Calcular',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons
                                          .home, // or Icons.arrow_forward, per your preference
                                      color: Colors.white,
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
