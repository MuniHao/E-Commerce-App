import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';

class SQLiteService {
  static Database? _database;
  final Uuid _uuid = Uuid();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cart_database.db');

    if (!await databaseExists(path)) {
      try {
        await Directory(dirname(path)).create(recursive: true);
        final data = await rootBundle.load('assets/cart_database.db');
        await File(path).writeAsBytes(data.buffer.asUint8List(), flush: true);
      } catch (e) {
        print("Error while getting database: $e");
      }
    }

    final db = await openDatabase(path);
    await _createTable(db);
    return db;
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS carts (
        id TEXT PRIMARY KEY,
        userId TEXT,
        productId TEXT,
        title TEXT,
        size TEXT,
        quantity INTEGER,
        price REAL,
        imageUrl TEXT,
        state TEXT
      ) ''');
    print("Table execution successful");
  }

  Future<List<CartItem>> fetchCartItemsByState(
      String userId, String state) async {
    final db = await database;
    final maps = await db.query('carts',
        where: 'userId = ? AND state = ?', whereArgs: [userId, state]);

    if (maps.isEmpty) {
      print("🔍 There are no products with $state state");
      //return [];
    }
    return maps.map(CartItem.fromJson).toList();
  }

  Future<void> addCartItem(CartItem cartItem, String userId) async {
    final db = await database;

    // Uuid
    final cartId = cartItem.id ?? _uuid.v4();

    await db.insert(
      'carts',
      {...cartItem.toJson(), 'id': cartId, 'userId': userId,},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Product added to cart: ${cartItem.toJson()}");
  }

  Future<void> updateCartItemQuantity(
      String id, String userId, int quantity) async {
    final db = await database;
    await db.update(
      'carts',
      {'quantity': quantity},
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
    print("Product quantity updated: ID $id, quantity: $quantity");
  }

  Future<List<CartItem>> fetchCartItems(String userId) async {
    final db = await database;
    final maps =
        await db.query('carts', where: 'userId = ?', whereArgs: [userId]);
    return maps.map(CartItem.fromJson).toList();
  }
}
