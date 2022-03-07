import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopie/providers/auth.dart';
import 'package:shopie/providers/orders.dart';
import 'package:shopie/screens/cart_screen.dart';
import 'package:shopie/screens/edit_product_screen.dart';

import 'package:shopie/screens/products_overview_screen.dart';
import 'package:shopie/screens/product_detail_screen.dart';
import 'package:shopie/screens/orders_screen.dart';
import 'package:shopie/screens/splash_screen.dart';
import 'package:shopie/screens/user_products_screen.dart';
import 'package:shopie/screens/auth_screen.dart';
import 'providers/products.dart';
import 'providers/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products('', [], ''),
              update: (ctx, auth, previousProducts) => Products(
                  auth.token,
                  previousProducts == null ? [] : previousProducts.items,
                  auth.userId)),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (_) => Orders('', [], ''),
              update: (ctx, auth, previousOrders) => Orders(
                  auth.token,
                  previousOrders == null ? [] : previousOrders.orders,
                  auth.userId)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
              title: 'MyShop',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primarySwatch: Colors.teal,
                  accentColor: Colors.white,
                  fontFamily: 'Lato'),
              home: auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                      future: auth.tryAutoLogin(),
                    ),
              routes: {
                ProductDetailScreen.routeName: (context) =>
                    ProductDetailScreen(),
                CartScreen.routeName: (context) => CartScreen(),
                OrdersScreen.routeName: (context) => OrdersScreen(),
                UserProductsScreen.routeName: (context) => UserProductsScreen(),
                EditProductScreen.routeName: (context) => EditProductScreen()
              }),
        ));
  }
}
