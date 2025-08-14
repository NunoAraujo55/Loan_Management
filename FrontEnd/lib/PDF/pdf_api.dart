import 'dart:io';

import 'package:flutter_amortiza/PDF/save_and_open_pdf.dart';
import 'package:flutter_amortiza/PDF/widgets/custom_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class Pdfapi {
  static Future<File> generatePdf(String nome, String valor, String garantia,
      String prestacao, String euribor, String spread, String prazo) async {
    final pdf = Document();

    pdf.addPage(Page(
        build: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Text(
                  "Nome da App",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),*/
                SizedBox(height: 40),
                Text(
                  "Resultado da Simulação",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Container(
                    color: PdfColors.grey200,
                    padding: EdgeInsets.all(10), //"Nome", nome
                    child: CustomInfo(begin: "Nome", end: nome)),
                Container(
                    color: PdfColors.grey200,
                    padding: EdgeInsets.all(10),
                    child:
                        CustomInfo(begin: "Valor do Empréstimo", end: valor)),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  color: PdfColors.grey200,
                  padding: EdgeInsets.all(10),
                  child: Text("Resultado da Simulação",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Container(
                    color: PdfColors.grey200,
                    padding: EdgeInsets.all(10),
                    child: CustomInfo(
                        begin: "Valor da Prestação", end: prestacao)),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  color: PdfColors.grey200,
                  padding: EdgeInsets.all(10),
                  child: Text("Dados do crédito",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 10),
                Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              color: PdfColors.grey200,
                              padding: EdgeInsets.all(10),
                              child: Column(children: [
                                CustomInfo(
                                    begin: "Finalidade", end: "Habitação"),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Valor do crédito", end: valor),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Garantia Financeira",
                                    end: garantia),
                                SizedBox(height: 10),
                                CustomInfo(begin: "Prazo", end: prazo),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Periodicidade", end: "Mensal"),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Prestações constantes",
                                    end: "Mensal"),
                                SizedBox(height: 25),
                              ])),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                              color: PdfColors.grey200,
                              padding: EdgeInsets.all(10),
                              child: Column(children: [
                                CustomInfo(begin: "Taxa de Juro", end: ""),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "tipo de taxa", end: "Variável"),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin:
                                        "Indexante: Média Euribor 12M (Base 360) ",
                                    end: '$euribor%'),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Spread (Margem) ", end: '$spread%'),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "Taxa Anual Nominal", end: "4.436%"),
                                SizedBox(height: 10),
                                CustomInfo(
                                    begin: "TAE (Taxa Anual Efectiva)",
                                    end: "4.836%"),
                              ])),
                        ),
                      ],
                    ))
              ],
            )));
    return Saveandopenpdf.savePdf(name: 'simulation.pdf', pdf: pdf);
  }
}
