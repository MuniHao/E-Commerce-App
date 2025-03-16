import '../models/order_item.dart';
import 'pocketbase_client.dart';
import 'database_helper_service.dart';
import '../models/cart_item.dart';

class OrdersService {
  final SQLiteService _sqliteService = SQLiteService();

  // ========== addOrder ==========
  Future<OrderItem?> addOrder(OrderItem order) async {
    try {
      final db = await _sqliteService.database;
      final pb = await getPocketbaseInstance();
      final userId = _getUserId(pb);
      if (userId == null) return null;

      final waitingItems = await _getWaitingCartItems(db, userId);
      if (waitingItems.isEmpty) return null;

      final cartItems = _convertCartItemsToJson(waitingItems);
      final orderModel =
          await _createOrderOnPocketBase(pb, order, userId, cartItems);
      if (orderModel.id == null) return null;

      await _updateCartItemsToDone(db, waitingItems);
      return order.copyWith(id: orderModel.id);
    } catch (error) {
      print("Error adding order: $error");
      return null;
    }
  }

  // ========== fetch ==========
  Future<List<OrderItem>> fetchOrders({bool filteredByUser = false}) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = _getUserId(pb);
      if (filteredByUser && userId == null) return [];

      final orderModels =
          await _fetchOrderModelsFromPB(pb, userId, filteredByUser);
      return _convertOrderModelsToOrderItems(orderModels);
    } catch (error) {
      print("Error when getting order list: $error");
      return [];
    }
  }

  // ========== Help Function ==========
  String? _getUserId(dynamic pb) {
    final userId = pb.authStore.record?.id;
    if (userId == null) {
      print("Error: User ID is null. User might not be logged in.");
    }
    return userId;
  }

  Future<List<Map<String, dynamic>>> _getWaitingCartItems(
      dynamic db, String userId) async {
    return await db.query(
      'carts',
      where: 'state = ? AND userId = ?',
      whereArgs: ['waiting', userId],
    );
  }

  List<Map<String, dynamic>> _convertCartItemsToJson(
      List<Map<String, dynamic>> waitingItems) {
    return waitingItems.map((item) {
      return {
        'productId': item['productId'],
        'title': item['title'],
        'price': item['price'],
        'quantity': item['quantity'],
        'size': item['size'],
      };
    }).toList();
  }

  Future<dynamic> _createOrderOnPocketBase(dynamic pb, OrderItem order,
      String userId, List<Map<String, dynamic>> cartItems) async {
    return await pb.collection('orders').create(
      body: {
        'amount': order.amount,
        'dateTime': order.dateTime.toIso8601String(),
        'userId': userId,
        'products': cartItems,
      },
    );
  }

  Future<void> _updateCartItemsToDone(
      dynamic db, List<Map<String, dynamic>> waitingItems) async {
    for (var item in waitingItems) {
      await db.update(
        'carts',
        {'state': 'done'},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
      print("Updating cart item ID ${item['id']} to 'done'");
    }
  }

  Future<List<dynamic>> _fetchOrderModelsFromPB(
      dynamic pb, String? userId, bool filteredByUser) async {
    final filter = filteredByUser ? "userId='$userId'" : null;
    return await pb.collection('orders').getFullList(filter: filter);
  }

  List<OrderItem> _convertOrderModelsToOrderItems(List<dynamic> orderModels) {
    return orderModels.map((orderModel) {
      final orderJson = orderModel.toJson();
      List<CartItem> products = (orderJson['products'] ?? [])
          .map<CartItem>((p) => CartItem.fromJson(p))
          .toList();
      return OrderItem(
        id: orderJson['id'],
        amount: orderJson['amount'],
        dateTime: DateTime.parse(orderJson['dateTime']),
        products: products,
      );
    }).toList();
  }
}
