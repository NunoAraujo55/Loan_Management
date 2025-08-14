import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/credit/credit_comparation.dart';
import 'package:flutter_amortiza/screens/credit/widgets/cards/credit_card_widget.dart';
import 'package:flutter_amortiza/screens/credit/widgets/sliders/slider_widget.dart';


class AmortizationFirst extends StatefulWidget {
  const AmortizationFirst({Key? key}) : super(key: key);

  @override
  _AmortizationFirstState createState() => _AmortizationFirstState();
}

class _AmortizationFirstState extends State<AmortizationFirst> {
  // Store the selected slider value
  double _montanteSelecionado = 20000.0;

  double manterPrazo() {
    double montanteInicial = 100000;
    double i = 1;
    double nRestantes = 300;
    double valorNovo = montanteInicial - _montanteSelecionado;

    final numerador = valorNovo * i * pow((1 + i), nRestantes);
    final denominador = pow((1 + i), nRestantes) - 1;

    return numerador / denominador;
  }

  double reduzirPrazo() {
    double montanteInicial = 100000;
    double i = 1;
    double prestacao = 350;
    double valorNovo = montanteInicial - _montanteSelecionado;

    return log((prestacao * (1 + i)) / (prestacao - valorNovo * i)) /
        log(1 + i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, 
      backgroundColor: const Color(0xFFD8EAF2),
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
              const CreditCardWidget(),
              const SizedBox(height: 50),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Montante a\nAmortizar",
                      style: TextStyle(
                        color: Color(0xFF002E8B),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Selecione o montante que deseja amortizar ao seu crédito e verifique as novas condições",
                      style: TextStyle(
                        color: Color(0xFF002E8B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    SliderMontante(
                      initialValue: _montanteSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _montanteSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 220,
                          child: FloatingActionButton(
                            onPressed: () {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreditComparation(),
                                ),
                              );
                            },
                            backgroundColor: const Color(0xFF002E8B),
                            foregroundColor: Colors.white,
                            child: const Text(
                              "Simular",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
