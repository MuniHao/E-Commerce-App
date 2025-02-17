import 'package:flutter/material.dart';
import 'package:myshop/ui/products/edit_product_screen.dart';

import 'user_product_list_tile.dart';
import 'products_manager.dart';
import '../shared/app_drawer.dart';

import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_products';
  const UserProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          // Bắt sự kiện cho nút add
          AddUserProductButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const UserProductList(),
    );
  }
}

class UserProductList extends StatelessWidget {
  const UserProductList({super.key});

  @override
  Widget build(BuildContext context) {
    // final productsManager = ProductsManager(); // Khởi tạo ProductsManager

    // return ListView.builder(
    //   itemCount: productsManager.items.length,
    //   itemBuilder: (ctx, i) => Column(
    //     children: [
    //       UserProductListTile(productsManager.items[i]),
    //       const Divider(),
    //     ],
    //   ),
    // );
    return Consumer<ProductsManager>(builder: (ctx, productsManager, child) {
      return ListView.builder(
          itemCount: productsManager.itemCount,
          itemBuilder: (ctx, i) => Column(
                children: [
                  UserProductListTile(
                    productsManager.items[i],
                  ),
                  const Divider(),
                ],
              ));
    });
  }
}

class AddUserProductButton extends StatelessWidget {
  const AddUserProductButton({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}
