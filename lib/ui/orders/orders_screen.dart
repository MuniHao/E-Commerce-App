import 'package:flutter/material.dart';

import 'orders_manager.dart';
import 'order_item_card.dart';
import '../shared/app_drawer.dart';

import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  late Future<void> _fetchOrders;

    @override
  void initState() {
    super.initState();
    _fetchOrders = context.read<OrdersManager>().fetchOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<OrdersManager>(context, listen: false)
          .fetchOrders()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }


  
  @override
  Widget build(BuildContext context) {
    // final ordersManager = OrdersManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<OrdersManager>(
        builder: (ctx, ordersManager, child) {
          return ListView.builder(
            itemCount: ordersManager.orderCount,
            itemBuilder: (ctx, i) => OrderItemCard(ordersManager.orders[i]),
          );
        },
      )
    );
  }
}
