import '../../models/cart_item.dart';

class CartManager {
  final Map<String, CartItem> _items = {
    'p1': CartItem(
      id: 'c1',
      title: 'Red Shirt',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
      price: 29.99,
      quantity: 2,
    ),
  };

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

//   void addItem(String productId, String title, String imageUrl, double price) {
//     if (_items.containsKey(productId)) {
//       _items.update(
//         productId,
//         (existingCartItem) => CartItem(
//           id: existingCartItem.id,
//           title: existingCartItem.title,
//           imageUrl: existingCartItem.imageUrl,
//           price: existingCartItem.price,
//           quantity: existingCartItem.quantity + 1,
//         ),
//       );
//     } else {
//       _items.putIfAbsent(
//         productId,
//         () => CartItem(
//           id: productId,
//           title: title,
//           imageUrl: imageUrl,
//           price: price,
//           quantity: 1,
//         ),
//       );
//     }
//   }

//   void removeItem(String productId) {
//     _items.remove(productId);
//   }

//   void clearCart() {
//     _items.clear();
//   }
}
