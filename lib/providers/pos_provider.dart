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
}
