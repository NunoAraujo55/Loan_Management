import 'package:flutter/material.dart';

class DetalhesDoImovel extends StatefulWidget {
  const DetalhesDoImovel({super.key});

  @override
  State<DetalhesDoImovel> createState() => _DetalhesDoImovelState();
}

final status = "Ativo";

class _DetalhesDoImovelState extends State<DetalhesDoImovel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título com ícone
            Row(
              children: [
                Image.asset(
                  'assets/building.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detalhes do Imovel',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linhas de detalhes
            _buildDetailRow('Morada', 'Av.da Liberdade, 120, 3ºE'),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Localidade', 'Lisboa'),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('Código Postal', '1250-142'),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
            ),
            _buildDetailRow('valor da avaliação', '200,000 €'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.grey,
            )),
        Text(
          value,
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
