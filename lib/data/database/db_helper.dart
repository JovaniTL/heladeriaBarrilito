import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('heladeria_barrilito.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'Efectivo'
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');

    // Productos predefinidos iniciales
    await db.insert('products', {
      'name': 'Cono Chico',
      'category': 'Helados',
      'price': 15.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Cono Mediano',
      'category': 'Helados',
      'price': 25.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Cono Grande',
      'category': 'Helados',
      'price': 35.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Vaso Chico',
      'category': 'Helados',
      'price': 18.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Vaso Mediano',
      'category': 'Helados',
      'price': 28.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Paleta de Agua',
      'category': 'Paletas',
      'price': 12.0,
      'is_active': 1,
    });
    await db.insert('products', {
      'name': 'Paleta de Leche',
      'category': 'Paletas',
      'price': 16.0,
      'is_active': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products', where: 'is_active = ?', whereArgs: [1]);
  }

  Future<int> insertSale(double total, List<Map<String, dynamic>> items) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      final saleId = await txn.insert('sales', {
        'date': DateTime.now().toIso8601String(),
        'total': total,
        'payment_method': 'Efectivo',
      });

      for (var item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_name': item['name'],
          'quantity': item['quantity'],
          'unit_price': item['price'],
        });
      }
      return saleId;
    });
  }

  Future<List<Map<String, dynamic>>> getDailySummary(String dateStr) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT product_name, SUM(quantity) as total_qty, SUM(quantity * unit_price) as total_amount
      FROM sale_items
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.date LIKE ?
      GROUP BY product_name
    ''',
      ['$dateStr%'],
    );
  }
}
