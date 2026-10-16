import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/pos_provider.dart';
import '../../data/models/product_model.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  // Paleta de colores temáticos de Heladería Barrilito
  static const Color primaryNavy = Color(0xFF0F2C59);
  static const Color accentTurquoise = Color(0xFF00A8CC);
  static const Color vanillaBackground = Color(0xFFF7F9FC);
  static const Color priceGreen = Color(0xFF2ECC71);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Helados':
        return const Color(0xFF00A8CC); // Turquesa fresco
      case 'Paletas':
        return const Color(0xFFFF9800); // Naranja mango
      default:
        return const Color(0xFF795548); // Marrón artesanal
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Helados':
        return Icons.icecream_outlined;
      case 'Paletas':
        return Icons.auto_awesome;
      default:
        return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    void showProductDialog({Product? product}) {
      final nameController = TextEditingController(text: product?.name ?? '');
      final priceController = TextEditingController(
        text: product?.price.toString() ?? '',
      );
      String selectedCategory = product?.category ?? 'Helados';

      // Lista de tamaños comunes para facilitar el llenado rápido
      final List<String> quickSizes = [
        'Chico',
        'Mediano',
        'Grande',
        '1/2 Litro',
        '1 Litro',
      ];

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          elevation: 8,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Encabezado Azul Marino
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        width: double.infinity,
                        color: primaryNavy,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(
                                product == null
                                    ? Icons.add_business
                                    : Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                product == null
                                    ? 'Nuevo Producto'
                                    : 'Editar Producto',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Cuerpo del formulario adaptativo
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo Nombre del Producto
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Producto',
                                hintText: 'Ej. Vaso de Vainilla',
                                prefixIcon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: primaryNavy,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primaryNavy,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Accesos rápidos de tamaños
                            const Text(
                              'Añadir Tamaño Rápidamente:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: quickSizes.map((size) {
                                return ActionChip(
                                  label: Text(
                                    size,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  visualDensity: VisualDensity
                                      .compact, // ✅ equivalente moderno
                                  backgroundColor: Colors.grey[200],
                                  onPressed: () {
                                    if (!nameController.text.contains(size)) {
                                      nameController.text =
                                          '${nameController.text} $size'.trim();
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Selección de Categoría con WRAP (Evita desbordamientos)
                            const Text(
                              'Categoría:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              children: ['Helados', 'Paletas', 'Otros'].map((
                                cat,
                              ) {
                                final isSelected = selectedCategory == cat;
                                final color = _getCategoryColor(cat);
                                return ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : primaryNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: color,
                                  backgroundColor: Colors.grey[100],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setStateDialog(
                                        () => selectedCategory = cat,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Campo Precio
                            TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Precio (\$)',
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  color: priceGreen,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: priceGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botones de Confirmación y Cancelación
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () async {
                                      final name = nameController.text.trim();
                                      final price =
                                          double.tryParse(
                                            priceController.text,
                                          ) ??
                                          0.0;

                                      if (name.isNotEmpty && price > 0) {
                                        if (product == null) {
                                          await posProvider.addProduct(
                                            name,
                                            selectedCategory,
                                            price,
                                          );
                                        } else {
                                          await posProvider.updateProduct(
                                            product.id!,
                                            name,
                                            selectedCategory,
                                            price,
                                          );
                                        }
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Guardar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: vanillaBackground,
      appBar: AppBar(
        title: const Text(
          'Catálogo de Productos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: posProvider.products.isEmpty
          ? const Center(
              child: Text(
                'No hay productos en el catálogo',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              itemCount: posProvider.products.length,
              itemBuilder: (context, index) {
                final product = posProvider.products[index];
                final color = _getCategoryColor(product.category);

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(product.category),
                        color: color,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryNavy,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          product.category,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currencyFormat.format(product.price),
                          style: const TextStyle(
                            color: priceGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: accentTurquoise,
                            size: 22,
                          ),
                          onPressed: () => showProductDialog(product: product),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text('Eliminar Producto'),
                                content: Text(
                                  '¿Deseas eliminar "${product.name}"?',
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
                            if (confirm == true && product.id != null) {
                              await posProvider.deleteProduct(product.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'NUEVO PRODUCTO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => showProductDialog(),
      ),
    );
  }
}
