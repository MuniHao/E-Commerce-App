import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'product_detail_screen.dart';

import 'package:provider/provider.dart';
import '../products/products_manager.dart';
import '../cart/cart_manager.dart';

class ProductGridTile extends StatelessWidget {
  const ProductGridTile(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
          footer: ProductGridFooter(
            product: product,
            onFavoritePressed: () {
              //print('Toggle a favorite product');
              context.read<ProductsManager>().updateProduct(product.copyWith(
                    isFavorite: !product.isFavorite,
                  ));
            },
            onAddToCartPressed: () {
              //print('Add item to cart');
              final cart = context.read<CartManager>();
              //cart.addItem(product);
              cart.addItem(product, 1, 'M');

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Item added to cart'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeItem(product.id!);
                      },
                    ),
                  ),
                );
            },
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
            },
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          )),
    );
  }
}

class ProductGridFooter extends StatelessWidget {
  const ProductGridFooter({
    required this.product,
    this.onFavoritePressed,
    this.onAddToCartPressed,
    super.key,
  });

  final Product product;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToCartPressed;

  @override
  Widget build(BuildContext context) {
    return GridTileBar(
      backgroundColor: Colors.black87,
      leading: IconButton(
        icon: Icon(
          product.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: onFavoritePressed,
      ),
      title: Text(
        product.title,
        textAlign: TextAlign.center,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: onAddToCartPressed,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
