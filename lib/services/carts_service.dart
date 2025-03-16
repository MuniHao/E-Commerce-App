import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import 'database_helper_service.dart';
import 'pocketbase_client.dart';

class CartsService {
  final SQLiteService _sqliteService = SQLiteService();

  // _fetchProductImage
  Future<String> _fetchProductImage(String productId) async {
    try {
      final pb = await getPocketbaseInstance();
      final productModel = await pb.collection('products').getOne(productId);
      final imageName = productModel.getStringValue('featuredImage');
      return pb.files.getUrl(productModel, imageName).toString();
    } catch (error) {
      print("Error fetching product image: $error");
      return '';
    }
  }

    Future<String?> _getUserId() async {
    final pb = await getPocketbaseInstance();
    return pb.authStore.record?.id;
  }

  Future<bool> _hasCheckedOutItems(String userId) async {
    final checkedOutItems =
        await _sqliteService.fetchCartItemsByState(userId, 'checked_out');
    return checkedOutItems.isNotEmpty;
  }

  CartItem? _findExistingCartItem(
      List<CartItem> waitingItems, CartItem cartItem) {
    return waitingItems.firstWhere(
      (item) =>
          item.productId == cartItem.productId && item.size == cartItem.size,
      orElse: () => CartItem(
          id: null, productId: '', title: '', price: 0, quantity: 0, size: ''),
    );
  }

  Future<CartItem?> _updateCartItemQuantity(
      CartItem existingItem, CartItem cartItem, String userId) async {
    if (existingItem.id == null) {
      print("Existing cart item ID is null.");
      return null;
    }
    final updatedQuantity = existingItem.quantity + cartItem.quantity;
    await _sqliteService.updateCartItemQuantity(
        existingItem.id!, userId, updatedQuantity);
    return existingItem.copyWith(quantity: updatedQuantity);
  }

  Future<CartItem?> _createNewCartItem(CartItem cartItem, String userId) async {
    final imageUrl = await _fetchProductImage(cartItem.productId);
    final newCartItem = cartItem.copyWith(
      imageUrl: imageUrl,
      state: 'waiting',
      id: cartItem.id ?? UniqueKey().toString(),
    );
    await _sqliteService.addCartItem(newCartItem, userId);
    return newCartItem;
  }

  Future<CartItem?> addCartItem(CartItem cartItem) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        print("User ID is null. User might not be logged in.");
        return null;
      }

      if (await _hasCheckedOutItems(userId)) {
        final newCartItem = cartItem.copyWith(state: 'waiting');
        await _sqliteService.addCartItem(newCartItem, userId);
        return newCartItem;
      }

      final waitingItems =
          await _sqliteService.fetchCartItemsByState(userId, 'waiting');
      final existingItem = _findExistingCartItem(waitingItems, cartItem);

      if (existingItem != null && existingItem.productId.isNotEmpty) {
        return await _updateCartItemQuantity(existingItem, cartItem, userId);
      } else {
        return await _createNewCartItem(cartItem, userId);
      }
    } catch (error) {
      print("Error adding item to cart: \$error");
      return null;
    }
  }

  // addCartItem
  // Future<CartItem?> addCartItem(CartItem cartItem) async {
  //   try {
  //     final pb = await getPocketbaseInstance();
  //     final userId = pb.authStore.record?.id;
  //     if (userId == null) {
  //       print("User ID is null. User might not be logged in.");
  //       return null;
  //     }

  //     final checkedOutItems = await _sqliteService.fetchCartItemsByState(userId, 'checked_out');
  //     if (checkedOutItems.isNotEmpty) {
  //       final newCartItem = cartItem.copyWith(state: 'waiting');
  //       await _sqliteService.addCartItem(newCartItem, userId);
  //       return newCartItem;
  //     }

  //     final waitingItems = await _sqliteService.fetchCartItemsByState(userId, 'waiting');

  //     final existingItem = waitingItems.firstWhere(
  //       (item) => item.productId == cartItem.productId && item.size == cartItem.size,
  //       orElse: () => CartItem(
  //         id: null, productId: '', title: '', price: 0, quantity: 0, size: '',
  //       ),
  //     );

  //     if (existingItem.productId.isNotEmpty) {
  //       if (existingItem.id == null) {
  //         print("Existing cart item ID is null.");
  //         return null;
  //       }

  //       final updatedQuantity = existingItem.quantity + cartItem.quantity;
  //       await _sqliteService.updateCartItemQuantity(existingItem.id!, userId, updatedQuantity);
        
  //       return existingItem.copyWith(quantity: updatedQuantity);
  //     } else {
  //       // Nếu sản phẩm chưa tồn tại, thêm mới với trạng thái 'waiting'
  //       final imageUrl = await _fetchProductImage(cartItem.productId);
  //       final newCartItem = cartItem.copyWith(
  //         imageUrl: imageUrl,
  //         state: 'waiting',
  //         id: cartItem.id ?? UniqueKey().toString(),
  //       );
  //       await _sqliteService.addCartItem(newCartItem, userId);
  //       return newCartItem;
  //     }
  //   } catch (error) {
  //     print("Error adding item to cart: $error");
  //     return null;
  //   }
  // }

  // fetch
  Future<List<CartItem>> fetchCartItems({bool filteredByUser = false}) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;

      if (userId == null) {
        print("User ID is null. User might not be logged in.");
        return [];
      }

      return await _sqliteService.fetchCartItemsByState(userId, 'waiting');
    } catch (error) {
      print("Error fetching cart items: $error");
      return [];
    }
  }

  // Edit Quantity
  Future<CartItem?> updateCartItem(CartItem cartItem) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;

      if (userId == null) {
        print("User ID is null. User might not be logged in.");
        return null;
      }

      await _sqliteService.updateCartItemQuantity(
          cartItem.id!, userId, cartItem.quantity);
      return cartItem;
    } catch (error) {
      print("Error updating cart: $error");
      return null;
    }
  }
}
