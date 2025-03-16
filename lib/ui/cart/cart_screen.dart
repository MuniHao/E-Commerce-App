import 'package:flutter/material.dart';

import 'cart_manager.dart';
import 'cart_item_card.dart';

import 'package:provider/provider.dart';

import '../orders/orders_manager.dart';
import '../../services/database_helper_service.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

    @override
  void initState() {
    super.initState();
    debugFetchCartItems();
    _fetchCartItems();
  }

    Future<void> debugFetchCartItems() async {
     final db = await SQLiteService().database;
     final List<Map<String, dynamic>> result = await db.query('carts');
     print("📋 Dữ liệu trong bảng carts:");
     for (var row in result) {
       print(row);
     }
   }

    Future<void> _fetchCartItems() async {
      setState(() {
        _isLoading = true;
      });


      try {
        await context.read<CartManager>().fetchCartItems();
      } catch (error) {
        print("Error fetching cart: $error");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    //final cart = CartManager();
    final cart = context.watch<CartManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(children: <Widget>[
        CartSummary(
            cart: cart,
            onOrderNowPressed:
                // Implement logic to place order
                //print('An order has been added');
                cart.totalAmount <= 0
                    ? null
                    : () {
                        context.read<OrdersManager>().addOrder(
                              cart.products,
                              cart.totalAmount,
                            );
                        cart.clearAllItems();
                      }),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // Hiển thị loading
              : cart.productEntries.isEmpty
                  ? const Center(child: Text('Your cart is empty'))
                  : CartItemList(cart),
        ),
      ]),
    );
  }
}

class CartItemList extends StatelessWidget {
  const CartItemList(this.cart, {super.key});

  final CartManager cart;

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: cart.productEntries
            .map(
              (entry) =>
                  CartItemCard(productId: entry.key, cartItem: entry.value),
            )
            .toList());
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.cart,
    this.onOrderNowPressed,
  });

  final CartManager cart;
  final void Function()? onOrderNowPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(15),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                TextButton(
                    onPressed: onOrderNowPressed,
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    child: const Text('Order now'))
              ],
            )));
  }
}
