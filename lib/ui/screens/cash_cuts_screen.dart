import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/pos_provider.dart';

class CashCutsScreen extends StatefulWidget {
  const CashCutsScreen({super.key});

  @override
  State<CashCutsScreen> createState() => _CashCutsScreenState();
}

class _CashCutsScreenState extends State<CashCutsScreen> {
  static const Color primaryNavy = Color(0xFF0F2C59);
  static const Color priceGreen = Color(0xFF2ECC71);
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosProvider>(context, listen: false).loadCashCutsHistory();
    });
  }

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final history = posProvider.cashCutsHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Cortes de Caja',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No hay cortes de caja guardados aún',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final cut = history[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Corte #${cut['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(cut['start_date']),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(cut['total_amount']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: priceGreen,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          'Total de productos vendidos: ${cut['total_items']} unidades',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Detalle: ${cut['summary_json']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                final totalController = TextEditingController(
                                  text: (cut['total_amount'] as num).toString(),
                                );
                                final itemsController = TextEditingController(
                                  text: (cut['total_items'] as int).toString(),
                                );

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Editar corte de caja'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: totalController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText: 'Total',
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: itemsController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Productos vendidos',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final total =
                                              double.tryParse(
                                                totalController.text,
                                              ) ??
                                              0.0;
                                          final items =
                                              int.tryParse(
                                                itemsController.text,
                                              ) ??
                                              0;

                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }

                                          await posProvider.updateCashCut(
                                            cut['id'],
                                            total,
                                            items,
                                            cut['summary_json'].toString(),
                                          );
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Modificar'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar corte'),
                                    content: Text(
                                      '¿Deseas eliminar el corte #${cut['id']}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await posProvider.deleteCashCut(cut['id']);
                                }
                              },
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
