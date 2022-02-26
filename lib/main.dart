import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopie/providers/orders.dart';
import 'package:shopie/screens/cart_screen.dart';
import 'package:shopie/screens/edit_product_screen.dart';

import 'package:shopie/screens/products_overview_screen.dart';
import 'package:shopie/screens/product_detail_screen.dart';
import 'package:shopie/screens/orders_screen.dart';
import 'package:shopie/screens/user_products_screen.dart';
import 'providers/products.dart';
import 'providers/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Orders(),
        )
      ],
      child: MaterialApp(
          title: 'MyShop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Colors.white,
              fontFamily: 'Lato'),
          home: ProductsOverviewScreen(),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen()
          }),
    );
  }
}
