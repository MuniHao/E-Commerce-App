import 'package:flutter/material.dart';
import 'package:myshop/ui/cart/cart_screen.dart';
import 'package:myshop/ui/products/products_overview_screen.dart';
import 'ui/products/user_products_screen.dart';
import 'ui/orders/orders_screen.dart';
import 'ui/products/product_detail_screen.dart';
import 'ui/products/products_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shadowColor: colorScheme.shadow,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ProductsManager(),
        )
      ],
      child: MaterialApp(
        title: 'MyShop',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: const ProductsOverviewScreen(),
        routes: {
          CartScreen.routeName: (ctx) => const SafeArea(
                child: CartScreen(),
              ),
          OrdersScreen.routeName: (ctx) => const SafeArea(
                child: OrdersScreen(),
              ),
          UserProductsScreen.routeName: (ctx) => const SafeArea(
                child: UserProductsScreen(),
              ),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ProductDetailScreen.routeName) {
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              // settings: settings,
              builder: (ctx) {
                return SafeArea(
                  child: ProductDetailScreen(
                    //ProductsManager().findById(productId)!,
                    ctx.read<ProductsManager>().findById(productId)!,
                  ),
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}
