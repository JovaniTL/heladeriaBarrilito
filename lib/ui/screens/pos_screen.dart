import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../providers/pos_provider.dart';
import 'summary_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Cargamos los productos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '🍦 Heladería Barrilito - POS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63), // Color rosa/fresa alegre
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.fileText, color: Colors.white),
            tooltip: 'Corte de Caja Diario',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: posProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Catálogo de Productos (Izquierda)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catálogo de Productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: posProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = posProvider.products[index];
                              return InkWell(
                                onTap: () => posProvider.addToCart(product),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          product.category == 'Helados'
                                              ? LucideIcons.iceCream
                                              : LucideIcons.sparkles,
                                          color: const Color(0xFFE91E63),
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormat.format(product.price),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
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
                ),

                // Carrito de Compras (Derecha)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFFF1F3F4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ticket Actual',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (posProvider.cartItems.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.trash2,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => posProvider.clearCart(),
                                  tooltip: 'Vaciar carrito',
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: posProvider.cartItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'El carrito está vacío\nToca un producto para agregar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: posProvider.cartItems.length,
                                  itemBuilder: (context, index) {
                                    final cartItem =
                                        posProvider.cartItems[index];
                                    return ListTile(
                                      title: Text(
                                        cartItem.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${currencyFormat.format(cartItem.product.price)} x ${cartItem.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currencyFormat.format(
                                              cartItem.subtotal,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              LucideIcons.minusCircle,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () =>
                                                posProvider.removeFromCart(
                                                  cartItem.product,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              LucideIcons.plusCircle,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            onPressed: () => posProvider
                                                .addToCart(cartItem.product),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total a Pagar:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(
                                      posProvider.totalCartAmount,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.banknote),
                                  label: const Text(
                                    'COBRAR EN EFECTIVO',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: posProvider.cartItems.isEmpty
                                      ? null
                                      : () async {
                                          bool success = await posProvider
                                              .checkout();
                                          if (success && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '¡Venta registrada con éxito!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
