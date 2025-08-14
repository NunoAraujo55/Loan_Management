import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/insurance/insurance_screen.dart';

class SeguroDeVidaCard extends StatelessWidget {
  const SeguroDeVidaCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.security, color: Colors.blue),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguro de Vida',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proteção para você e sua família',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descrição
            Text(
              'Quer descobrir como os seguros de vida podem oferecer '
              'segurança e tranquilidade para o seu futuro?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Lista de tópicos (com ícones ou bullets)
            _buildListItem(
              context,
              'Proteção financeira em caso de invalidez',
            ),
            _buildListItem(
              context,
              'Coberturas adaptadas às suas necessidades',
            ),
            _buildListItem(
              context,
              'Tranquilidade para você e sua família',
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InsuranceScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Saiba Mais",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar um item de lista com ícone de check
  Widget _buildListItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.blue,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
