import 'package:flutter/material.dart';

class CreditWidget extends StatelessWidget {
  final String amount;
  final String name;
  final String rate;
  final String status;

  const CreditWidget({
    required this.amount,
    required this.name,
    required this.rate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, right: 25),
      child: Container(
          width: 300,
          height: 106,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x753976AC),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Image.asset(
                  'assets/home.jpg', // substitua pelo caminho da sua imagem
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF002E8B),
                        ),
                      ),
                      Text(
                        "Taxas nominais: $rate",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF002E8B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: status == "Ativo"
                        ? const Color(0xFF309C4F).withAlpha(60)
                        : const Color(0xFFFF4800).withAlpha(60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == "Ativo"
                          ? const Color(0xFF309C4F)
                          : const Color(0xFFFF4800),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
