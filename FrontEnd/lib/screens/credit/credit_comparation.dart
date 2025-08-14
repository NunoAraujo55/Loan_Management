import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/credit/widgets/charts/chart_widget.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/display_input._widget.dart';
import 'package:flutter_amortiza/screens/credit/widgets/tab_item_widget.dart';

class CreditComparation extends StatelessWidget {
  CreditComparation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFD8EAF2),
      appBar: AppBar(
        backgroundColor: Color(0xFFD8EAF2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const SizedBox(height: 10),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFF7F9FA),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: Color(0xFF002E8B),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black54,
                            tabs: const [
                              TabItemWidget(title: "Manter Prazo"),
                              TabItemWidget(title: "Reduzir Prazo"),
                              TabItemWidget(title: "Sumário"),
                            ],
                          ),
                        ),
                      ),
                      // O TabBarView precisa ocupar o espaço restante
                      Expanded(
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Column(
                                      children: [
                                        const ListTile(
                                          title: Text(
                                            'Manter o prazo',
                                            style: TextStyle(
                                              color: Color(0xFF002E8B),
                                              fontSize: 25,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Mantenha o prazo e verifique as alterações na prestação e juros',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF1388BE),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 40,),
                                        Card(
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Antes da Amortização",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                DisplayInputField(
                                                  info: "25000",
                                                  label: "Montante",
                                                ),
                                                DisplayInputField(
                                                  info: "2.0",
                                                  label: "Spread",
                                                ),
                                                DisplayInputField(
                                                  info: "30",
                                                  label: "Prazo (anos)",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Depois da Amortização",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                              ),
                                            ),
                                            DisplayInputField(
                                              info: "25000",
                                              label: "Montante",
                                            ),
                                            DisplayInputField(
                                              info: "2.0",
                                              label: "Spread",
                                            ),
                                            DisplayInputField(
                                              info: "30",
                                              label: "Prazo (anos)",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SingleChildScrollView(   //graphs Tab
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ListTile(
                                        title: Text(
                                          'Reduzir ao prazo',
                                          style: TextStyle(
                                            color: Color(0xFF002E8B),
                                            fontSize: 25,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Reduza ao prazo e verifique as alterações no prazo e nos juros',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF1388BE),
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 40,),
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: ChartWidget(
                                            title: "Prestação Mensal",
                                            subtitle1: "Amortizado",
                                            subtitle2: "Existente",
                                          ),
                                        ),
                                        SizedBox(
                                          height: 40,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: ChartWidget(
                                            title: "Valor do Crédito",
                                            subtitle1: "Amortizado",
                                            subtitle2: "Existente",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Card(
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              "Sumário da Amortização",
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                color: Color(
                                                                    0xFF002E8B),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Valor Original",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "100,000.0€",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Novo valor",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "90,000.0€",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Prestação Original",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "500.00€",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Nova Prestação",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "470.00€",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Poupança por mês",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "30.00€",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
