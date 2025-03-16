import '../../models/cart_item.dart';
import '../../models/order_item.dart';

import 'package:flutter/foundation.dart';
import '../../services/orders_service.dart';

class OrdersManager with ChangeNotifier {
  final OrdersService _ordersService = OrdersService();
  final List<OrderItem> _orders = [
    // OrderItem(
    //   id: 'o1',
    //   amount: 59.98,
    //   products: [
    //     // CartItem(
    //     //   id: 'c1',
    //     //   title: 'Red Shirt',
    //     //   imageUrl:
    //     //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //     //   price: 29.99,
    //     //   quantity: 2,
    //     //   size: 'X', // add size variable
    //     // )
    //   ],
    //   dateTime: DateTime.now(),
    // )
  ];
  int get orderCount {
    return _orders.length;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  // void addOrder(List<CartItem> cartProducts, double total) {
  //   _orders.insert(
  //       0,
  //       OrderItem(
  //         id: 'o${DateTime.now().toIso8601String()}',
  //         amount: total,
  //         products: cartProducts,
  //         dateTime: DateTime.now(),
  //       ));
  //   notifyListeners();
  // }
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    print('Adding order: total=$total, products=${cartProducts.length}');
    for (var item in cartProducts) {
      if (item.id == null) {
        print('Error: Cart item has no ID');
        return;
      }
    }
    final newOrder = OrderItem(
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );

    final addedOrder = await _ordersService.addOrder(newOrder);
    if (addedOrder != null) {
      print('Order successfully added: ${addedOrder.toJson()}');
      _orders.insert(0, addedOrder);
      notifyListeners();
    } else {
      print('Failed to add order');
    }
  }


  Future<void> fetchOrders() async {
    print("Fetching orders...");
    final fetchedOrders =
        await _ordersService.fetchOrders(filteredByUser: true);
    if (fetchedOrders.isEmpty) {
      print("No orders found or failed to fetch.");
    }
    _orders.clear();
    _orders.addAll(fetchedOrders);
    notifyListeners();
  }
}
