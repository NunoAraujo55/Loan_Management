import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amortiza/models/imi.model.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';

class HouseCosts extends StatefulWidget {
  @override
  _CalcHouseCostsState createState() => _CalcHouseCostsState();
}

class _CalcHouseCostsState extends State<HouseCosts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final vptController = TextEditingController();
  final emprestimoController = TextEditingController();
  final valorDeCompraController = TextEditingController();

  String? _selectedTipoImovel = "Urbano";
  String? _selectedIdade = "Menos de 5 anos";
  String? _selectedDistrito;
  List<String> _municipios = [];
  String? _selectedMunicipio;
  bool visible = false;
  double imi = 0;
  double taxaIMI = 0;
  double taxaEmPercentagem = 0;
  double isEmprestimo = 0;
  double isCompra = 0;
  double isTotal = 0;
  double total = 0;

  final List<String> _tipos = [
    'Urbano',
    'Rústico',
    'Misto',
  ];
  final List<String> _idades = [
    'Menos de 5 anos',
    'Entre 5 e 10 anos',
    'Entre 10 a 20 anos',
    'Mais de 20 anos',
  ];

  late List<ImiRecord> _records;
  List<String> _distritos = [];
  Map<String, List<String>> _munMap = {};

  Future<void> _loadImiData() async {
    final jsonStr = await rootBundle.loadString('assets/JSON/imi_2024.json');
    final List<dynamic> data = json.decode(jsonStr);

    _records = data.map((j) => ImiRecord.fromJson(j)).toList();

    // 1. extract unique districts, sorted
    _distritos = _records.map((r) => r.distrito).toSet().toList()..sort();

    // 2. group municipios by distrito
    for (var rec in _records) {
      _munMap.putIfAbsent(rec.distrito, () => []).add(rec.municipio);
    }
    // dedupe & sort each list
    _munMap.forEach((d, list) {
      _munMap[d] = list.toSet().toList()..sort();
    });

    // 3. initialize selections
    _selectedDistrito = _distritos.first;
    _municipios = _munMap[_selectedDistrito]!;
    _selectedMunicipio = _municipios.first;

    setState(() {});
  }

  double taxa() {
    if (_selectedDistrito == null || _selectedMunicipio == null) {
      return 0.0;
    }
    final rec = _records.firstWhere(
        (r) =>
            r.distrito == _selectedDistrito &&
            r.municipio == _selectedMunicipio,
        orElse: () => throw StateError(
            'Nenhum registo IMI para $_selectedDistrito / $_selectedMunicipio'));

    return rec.taxa / 100;
  }

  double calcImi(double taxa) {
    double vpt = double.parse(vptController.text);
    if (vpt <= 0 || _selectedDistrito == null || _selectedMunicipio == null) {
      return 0.0;
    }
    final rec = _records.firstWhere(
        (r) =>
            r.distrito == _selectedDistrito &&
            r.municipio == _selectedMunicipio,
        orElse: () => throw StateError(
            'Nenhum registo IMI para $_selectedDistrito / $_selectedMunicipio'));

    //IMI = VPT × (taxa IMI / 100)
    final fraction = rec.taxa / 100;
    return vpt * fraction;
  }

  double calcISEmprestimo() {
    double emprestimo = double.parse(emprestimoController.text);
    double impostoSelo = emprestimo * 0.006;
    return impostoSelo;
  }

  double calcISCompra() {
    double valorDeCompra = double.parse(valorDeCompraController.text);
    double impostoSelo = valorDeCompra * 0.008;
    return impostoSelo;
  }

  @override
  void initState() {
    super.initState();
    _loadImiData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    vptController.dispose();
    valorDeCompraController.dispose();
    emprestimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
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
              'Custos Associados',
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Calculadora'),
                  Tab(text: 'Informações'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 1,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: const [
                                    const Icon(
                                      Icons.home,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Detalhes do Imóvel',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      controller: valorDeCompraController,
                                      name: "Valor de Compra",
                                      inputType: TextInputType.number,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomTextField(
                                      controller: emprestimoController,
                                      name: "Valor do empréstimo",
                                      inputType: TextInputType.number,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomTextField(
                                      controller: vptController,
                                      name: "VPT",
                                      inputType: TextInputType.number,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Tipo de imovel",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      dropdownColor: Colors.white,
                                      value: _selectedTipoImovel,
                                      items: _tipos
                                          .map((tipo) => DropdownMenuItem(
                                                value: tipo,
                                                child: Text(tipo),
                                              ))
                                          .toList(),
                                      onChanged: (novo) {
                                        setState(
                                            () => _selectedTipoImovel = novo);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Idade do Imóvel",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      dropdownColor: Colors.white,
                                      value: _selectedIdade,
                                      items: _idades
                                          .map((tipo) => DropdownMenuItem(
                                                value: tipo,
                                                child: Text(tipo),
                                              ))
                                          .toList(),
                                      onChanged: (novo) {
                                        setState(() => _selectedIdade = novo);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Distrito",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      dropdownColor: Colors.white,
                                      value: _selectedDistrito,
                                      items: _distritos
                                          .map((tipo) => DropdownMenuItem(
                                                value: tipo,
                                                child: Text(tipo),
                                              ))
                                          .toList(),
                                      onChanged: (novo) {
                                        if (novo == null) {
                                          return;
                                        }
                                        setState(() {
                                          _selectedDistrito = novo;

                                          _municipios = _munMap[novo] ?? [];

                                          _selectedMunicipio =
                                              _municipios.isNotEmpty
                                                  ? _municipios.first
                                                  : null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Municipio",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      dropdownColor: Colors.white,
                                      value: _selectedMunicipio,
                                      items: _municipios
                                          .map((tipo) => DropdownMenuItem(
                                                value: tipo,
                                                child: Text(tipo),
                                              ))
                                          .toList(),
                                      onChanged: (novo) {
                                        setState(
                                            () => _selectedMunicipio = novo);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    taxaIMI = taxa();
                                    taxaEmPercentagem = taxaIMI * 100;
                                    double result = calcImi(taxaIMI);
                                    double isCompra = calcISCompra();
                                    double isEmprestimo = calcISEmprestimo();
                                    double isTotal = isCompra + isEmprestimo;
                                    double total = isTotal + 600 + 250 + 1200 + result; 
                                    setState(() {
                                      imi = result;
                                      this.isCompra = isCompra;
                                      this.isEmprestimo = isEmprestimo;
                                      this.isTotal = isTotal;
                                      this.total = total;
                                      //visible = true;
                                    });
                                    print(imi);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 16, 38, 148),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                        Visibility(
                          visible: imi > 0,
                          child: Card(
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resumo dos custos',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  Text(
                                    'Impostos e despesas associados à sua compra',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFE0F2FE),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/building.png',
                                                width: 20,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                            ),
                                            child: const Text(
                                              'IMI (Imposto Municipal sobre Imóveis)',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 232, 246, 252),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 78, 135, 201),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Anual',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 78, 135, 201),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Card(
                                    elevation: 0,
                                    color: Color(0xFFF8FAFC),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Valor Anual Estimado',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('$imi €',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey[200],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Taxa Aplicada',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('$taxaEmPercentagem %',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              // Optional: Add a subtle border
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255,
                                                    198,
                                                    222,
                                                    253), // Adjust to your preference
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
                                                  color: Color(0xFF315BD8),
                                                ),
                                                const SizedBox(width: 8),
                                                // Text on the right
                                                Expanded(
                                                  child: Text(
                                                    'O IMI é cobrado anualmente e pode ser liquidado numa só vez ou fracionado em várias prestações, consoante o montante.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF315BD8)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color.fromARGB(
                                                  255, 203, 252, 216),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/building.png',
                                                width: 20,
                                                height: 20,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'IS (Imposto de Selo)',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
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
                                            color: const Color(0xFFECFDF5),
                                            border: Border.all(
                                              color: const Color.fromARGB(255,
                                                  91, 247, 174), // dark blue
                                              width:
                                                  1, // adjust thickness as needed
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Único',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 103, 148, 105)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Card(
                                    elevation: 0,
                                    color: Color(0xFFF8FAFC),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'IS sobre o empréstimo(0.6%)',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('$isEmprestimo €',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey[200],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('IS sobre a compra',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('$isCompra €',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey[200],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Total Imposto do Selo',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('$isTotal €',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color.fromARGB(
                                                  255, 247, 236, 222),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/building.png',
                                                width: 20,
                                                height: 20,
                                                color: Colors.orangeAccent,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Outros custos',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Card(
                                    elevation: 0,
                                    color: Color(0xFFF8FAFC),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Escritura',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('~600.00€',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey[200],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Registo Predial',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('~250.00€',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey[200],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Comissões Bancárias',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14)),
                                              Text('~1.200.00€',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    // remove the solid color
                                    child: Container(
                                      // apply your gradient here
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromARGB(255, 33, 171,
                                                236), // light blue
                                            Colors.blueAccent
                                                .shade700, // darker blue
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total de Custos Iniciais',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '$total €',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Inclui o custo de IMI para o primeiro ano',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpansionTile(
                          title: Text('IMI – Imposto Municipal sobre Imóveis',
                              style: TextStyle(color: Colors.black)),
                          children: [
                            DefaultTextStyle(
                              style: const TextStyle(
                                  color: Colors.black), // <–– tudo herda preto
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'O IMI incide sobre o valor patrimonial tributário (VPT) dos imóveis e é cobrado anualmente pelos municípios.'),
                                    SizedBox(height: 8),
                                    Text(
                                        '• Prédios urbanos: 0,3% a 0,45% (dependendo do município)'),
                                    Text('• Prédios rústicos: 0,8%'),
                                    SizedBox(height: 8),
                                    Text('Pagamento:'),
                                    Text('• Até 100€: pagamento em maio'),
                                    Text(
                                        '• Entre 100€ e 500€: pagamento em maio e novembro'),
                                    Text(
                                        '• Superior a 500€: pagamento em maio, agosto e novembro'),
                                    SizedBox(height: 8),
                                    Card(
                                      color: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'Isenção para habitação própria e permanente: Imóveis com VPT até 125.000€ podem beneficiar de isenção de IMI durante 3 anos (sujeito a condições).',
                                          style: TextStyle(
                                              color:
                                                  Colors.blue), // mantém azul
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('IS - Imposto do Selo',
                              style: TextStyle(color: Colors.black)),
                          children: [
                            DefaultTextStyle(
                              style: const TextStyle(color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Aplica-se sobre diversos atos, no contexto da compra de casa:'),
                                    SizedBox(height: 8),
                                    Text(
                                        '• Aquisição onerosa de imóveis: 0,8% sobre o valor'),
                                    Text(
                                        '• Contratos de empréstimo: 0,6% sobre o montante'),
                                    Text(
                                        '• Utilização de crédito (≥5 anos): 0,6%'),
                                    Text('• Garantias: entre 0,04% e 0,6%'),
                                    SizedBox(height: 8),
                                    Card(
                                      color: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'O IS é pago uma única vez no momento da transação ou da contratação do empréstimo, não sendo um imposto recorrente como o IMI.',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text(
                              'IMT - Imposto Municipal sobre Transmissões',
                              style: TextStyle(color: Colors.black)),
                          children: [
                            DefaultTextStyle(
                              style: const TextStyle(color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Incide sobre as transmissões onerosas do direito de propriedade sobre imóveis.'),
                                    SizedBox(height: 8),
                                    Text(
                                        'Taxas para habitação própria e permanente:'),
                                    Text('• Até 92.407€: 0%'),
                                    Text('• 92.407€ a 126.403€: 2%'),
                                    Text('• 126.403€ a 172.348€: 5%'),
                                    Text('• 172.348€ a 287.213€: 7%'),
                                    Text('• 287.213€ a 574.323€: 8%'),
                                    Text('• Superior a 574.323€: 6%'),
                                    SizedBox(height: 8),
                                    Card(
                                      color: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'O IMT deve ser pago antes da escritura ou do ato que determina a transmissão do imóvel.',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('Outros Custos Associados',
                              style: TextStyle(color: Colors.black)),
                          children: [
                            DefaultTextStyle(
                              style: const TextStyle(color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '• Escritura: 400€ a 1.000€, dependendo do imóvel e do notário'),
                                    Text('• Registo Predial: ~250€'),
                                    Text('• Comissões Bancárias:'),
                                    Text(
                                        '  - Abertura: 0,25% a 1% do valor do empréstimo'),
                                    Text('  - Avaliação: 200€ a 400€'),
                                    Text(
                                        '  - Processamento da prestação: 1€ a 3€/mês'),
                                    Text('• Seguros Obrigatórios:'),
                                    Text(
                                        '  - Seguro de vida: depende da idade, valor e prazo'),
                                    Text(
                                        '  - Seguro multirriscos: depende do valor do imóvel'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.info, color: Color(0xFF856404)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Os valores apresentados são estimativas e podem variar. Para informações precisas, consulte um advogado especializado em direito imobiliário ou um consultor fiscal.',
                                  style: TextStyle(color: Color(0xFF856404)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
