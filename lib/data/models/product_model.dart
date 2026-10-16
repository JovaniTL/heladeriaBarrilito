class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int isActive;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    this.isActive = 1,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'is_active': isActive,
    };
  }
}
