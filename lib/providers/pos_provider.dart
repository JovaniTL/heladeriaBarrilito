import 'package:flutter/foundation.dart';

import '../data/database/db_helper.dart';
import '../data/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class PosProvider with ChangeNotifier {
  List<Product> _products = [];
  final Map<int, CartItem> _cart = {};
  List<Map<String, dynamic>> _dailySummary = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cart.values.toList();
  List<Map<String, dynamic>> get dailySummary => _dailySummary;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _cashCutsHistory = [];
  List<Map<String, dynamic>> get cashCutsHistory => _cashCutsHistory;
  List<Map<String, dynamic>> _dailySalesList = [];
  List<Map<String, dynamic>> get dailySalesList => _dailySalesList;

  double get totalCartAmount {
    return _cart.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final data = await DatabaseHelper.instance.getProducts();
    _products = data.map((map) => Product.fromMap(map)).toList();

    _isLoading = false;
    notifyListeners();
  }

  void addToCart(Product product) {
    if (_cart.containsKey(product.id!)) {
      _cart[product.id!]!.quantity++;
    } else {
      _cart[product.id!] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cart.containsKey(product.id)) {
      if (_cart[product.id]!.quantity > 1) {
        _cart[product.id]!.quantity--;
      } else {
        _cart.remove(product.id);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_cart.isEmpty) return false;

    try {
      List<Map<String, dynamic>> itemsList = _cart.values
          .map(
            (item) => {
              'name': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
            },
          )
          .toList();

      await DatabaseHelper.instance.insertSale(totalCartAmount, itemsList);
      clearCart();
      return true;
    } catch (e) {
      debugPrint('Error al registrar venta: $e');
      return false;
    }
  }

  Future<void> loadDailySummary() async {
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _dailySummary = await DatabaseHelper.instance.getDailySummary(dateStr);
    notifyListeners();
  }

  // Agregar producto
  Future<void> addProduct(String name, String category, double price) async {
    await DatabaseHelper.instance.insertProduct({
      'name': name,
      'category': category,
      'price': price,
      'is_active': 1,
    });
    await loadProducts();
  }

  // Editar producto
  Future<void> updateProduct(
    int id,
    String name,
    String category,
    double price,
  ) async {
    await DatabaseHelper.instance.updateProduct({
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'is_active': 1,
    });
    await loadProducts();
  }

  // Eliminar producto
  Future<void> deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    await loadProducts();
  }

  // Cargar historial de cortes guardados
  Future<void> loadCashCutsHistory() async {
    _cashCutsHistory = await DatabaseHelper.instance.getCashCutsHistory();
    notifyListeners();
  }

  // Cerrar el día actual, guardarlo en el historial y limpiar ventas
  Future<bool> closeAndSaveDay(double totalAmount, int totalItems) async {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Guardar en la tabla cash_cuts
      await DatabaseHelper.instance.saveCashCut(
        dateStr,
        now.toIso8601String(),
        totalAmount,
        totalItems,
        _dailySummary.toString(), // O un JSON formateado si prefieres
      );

      // Limpiar las ventas actuales para iniciar un nuevo día
      await DatabaseHelper.instance.clearCurrentSales();
      await loadDailySummary();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al cerrar caja: $e');
      return false;
    }
  }

  // Cargar las ventas individuales del día actual
  Future<void> loadDailySales() async {
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _dailySalesList = await DatabaseHelper.instance.getSalesByDate(dateStr);

    notifyListeners();
  }

  // Editar el total de una venta registrada por error
  Future<void> editSaleTotal(int saleId, double newTotal) async {
    await DatabaseHelper.instance.updateSale(saleId, newTotal);
    await loadDailySales();
  }

  Future<void> removeSale(int saleId) async {
    await DatabaseHelper.instance.deleteSale(saleId);
    await loadDailySales();
  }
}
