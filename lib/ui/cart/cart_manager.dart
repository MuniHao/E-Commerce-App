import '../../models/cart_item.dart';

import '../../models/product.dart';

import 'package:flutter/foundation.dart';

import '../../services/carts_service.dart';

class CartManager with ChangeNotifier {
  final Map<String, CartItem> _items = {
    // 'p1': CartItem(
    //   id: 'c1',
    //   title: 'Red Shirt',
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   price: 29.99,
    //   quantity: 2,
    //   size: 'X',
    // ),
  };
  final CartsService _cartsService = CartsService();

  Future<void> fetchCartItems() async {
    final cartItems = await _cartsService.fetchCartItems(filteredByUser: true);
    // _items.clear();
    // for (final item in cartItems) {
    //   final key = _createKey(item.productId, item.size);
    //   _items[key] = item;
    // }
    _items
      ..clear()
      ..addEntries(cartItems.map(
          (item) => MapEntry(_createKey(item.productId, item.size), item)));
 
    notifyListeners();
  }

  String _createKey(String productId, String size) {
    return '$productId-$size';
  }

  int get productCount {
    return _items.length;
  }

  List<CartItem> get products {
    return _items.values.toList();
  }

  Iterable<MapEntry<String, CartItem>> get productEntries {
    return {..._items}.entries;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItembasic(Product product) {
    if (product.id == null) {
      print('Lỗi: product.id là null, không thể thêm vào giỏ hàng.');
      return;
    }

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id!,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id!,
        () => CartItem(
          id: 'c${DateTime.now().toIso8601String()}',
          productId: product.id!,
          title: product.title,
          imageUrl: product.imageUrl,
          price: product.price,
          quantity: 1,
          size: 'X',
        ),
      );
    }
    notifyListeners();
  }

  // void addItem2(Product product, int quantity, String? size) {
  //   if (size == null) return; // Đảm bảo có size được chọn

  //   final productKey = '${product.id}_$size';

  //   if (_items.containsKey(productKey)) {
  //     _items.update(
  //       productKey,
  //       (existingCartItem) => existingCartItem.copyWith(
  //         quantity: existingCartItem.quantity + quantity,
  //       ),
  //     );
  //   } else {
  //     _items.putIfAbsent(
  //       productKey,
  //       () => CartItem(
  //         id: 'c${DateTime.now().toIso8601String()}',
  //         productId: product.id!,
  //         title: product.title,
  //         imageUrl: product.imageUrl,
  //         price: product.price,
  //         quantity: quantity,
  //         size: size, // Thêm kích thước vào giỏ hàng
  //       ),
  //     );
  //   }
  //   notifyListeners();
  // }

    Future<void> addItem(Product product,
      int quantity, String ?size) async {
    final key = _createKey(product.id!, size!);

    // if products
    if (_items.containsKey(key)) {
      // final updatedQuantity = _items[key]!.quantity + quantity;
      // _items[key] = _items[key]!.copyWith(quantity: updatedQuantity);
      _items[key] = _items[key]!.copyWith(
        quantity: _items[key]!.quantity + quantity,
      );
      await _cartsService.updateCartItem(_items[key]!);
    } else {
      // Nếu sản phẩm chưa có trong giỏ hàng, thêm mới
      final newItem = CartItem(
        productId: product.id!,
        title: product.title,
        price: product.price,
        quantity: quantity,
        size: size,
        imageUrl: product.imageUrl,
      );

      // Thêm vào SQLite và nhận lại đối tượng từ SQLite
      final addedItem = await _cartsService.addCartItem(newItem);
      if (addedItem != null) {
        _items[key] = addedItem;
      }
    }
    notifyListeners(); // Cập nhật giao diện
  }


  void removeItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]?.quantity as num > 1) {
      _items.update(
        productId,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearAllItems() {
    //_items = {}; ->>> error, items with type final, can not be {}
    _items.clear();
    notifyListeners();
  }
}
