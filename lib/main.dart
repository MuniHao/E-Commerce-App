import 'package:flutter/material.dart';
import 'package:myshop/ui/cart/cart_screen.dart';
import 'package:myshop/ui/products/products_overview_screen.dart';
import 'package:myshop/ui/screens.dart';
import 'ui/products/user_products_screen.dart';
import 'ui/orders/orders_screen.dart';
import 'ui/products/product_detail_screen.dart';
import 'ui/products/products_manager.dart';
import 'package:provider/provider.dart';
import 'ui/cart/cart_manager.dart';
import 'ui/products/edit_product_screen.dart';

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
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersManager(),
        ),
        // (1) create and provide an AuthManager object
        ChangeNotifierProvider(
          create: (ctx) => AuthManager(),
          )
      ],
      child: Consumer<AuthManager> (
        builder: (ctx, authManager, child) {
          return MaterialApp(
            title: 'MyShop',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            //home: const ProductsOverviewScreen(),
            //(2) consume/use the AuthManager object
            home: authManager.isAuth
             ? const SafeArea(child: ProductsOverviewScreen())
             : FutureBuilder(
                future: authManager.tryAutoLogin(), 
                builder: (ctx, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                    ? const SafeArea(child: SplashScreen())
                    : const SafeArea(child: AuthScreen());
                }
              ),
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
              if (settings.name == EditProductScreen.routeName) {
                final productId = settings.arguments as String?;
                return MaterialPageRoute(
                  // settings: settings,
                  builder: (ctx) {
                    return SafeArea(
                      child: EditProductScreen(
                        //ProductsManager().findById(productId)!,
                        productId != null
                            ? ctx.read<ProductsManager>().findById(productId)
                            : null,
                      ),
                    );
                  },
                );
              }
              if (settings.name == ProductDetailScreen.routeName) {
                final productId = settings.arguments as String;
                return MaterialPageRoute(
                  // settings: settings,
                  builder: (ctx) {
                    return SafeArea(
                      child: ProductDetailScreen(
                        ctx.read<ProductsManager>().findById(productId)!,
                      ),
                    );
                  },
                );
              }
              return null;
            }
          );
        
        }
      )
    );
  }
}
