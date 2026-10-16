import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../providers/pos_provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosProvider>(context, listen: false).loadDailySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final summary = posProvider.dailySummary;

    double totalGeneral = summary.fold(
      0.0,
      (sum, item) => sum + (item['total_amount'] as num),
    );

    int totalUnidades = summary.fold(
      0,
      (sum, item) => sum + (item['total_qty'] as num).toInt(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Corte de Caja Diario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de Totales del Día
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.pink[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total en Efectivo',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormat.format(totalGeneral),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos Vendidos',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalUnidades un.',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Desglose por Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: summary.isEmpty
                  ? (const Center(
                      child: Text(
                        'No hay ventas registradas el día de hoy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ))
                  : ListView.builder(
                      itemCount: summary.length,
                      itemBuilder: (context, index) {
                        final item = summary[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFCE4EC),
                              child: Icon(
                                LucideIcons.iceCream,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            title: Text(
                              item['product_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Cantidad vendida: ${item['total_qty']} unidades',
                            ),
                            trailing: Text(
                              currencyFormat.format(item['total_amount']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
