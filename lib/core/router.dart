import 'package:go_router/go_router.dart';
import 'package:listngo/views/screens/barcode_scanner_screen.dart';

import '../views/screens/create_product_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/product_list_screen.dart';
import '../views/screens/product_screen.dart';
import '../views/screens/profile_screen.dart';
import '../views/screens/purchase_history_list_screen.dart';
import '../views/screens/purchase_history_screen.dart';
import '../views/screens/search_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/list', builder: (context, state) => ProductListScreen()),
    GoRoute(path: '/product', builder: (context, state) => ProductScreen()),
    GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
    GoRoute(
      path: '/create-product',
      builder: (context, state) => CreateProductScreen(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(
      path: '/purchase-history-list',
      builder: (context, state) => PurchaseHistoryListScreen(),
    ),
    GoRoute(
      path: '/purchase-history',
      builder: (context, state) => PurchaseHistoryScreen(),
    ),
    GoRoute(
      path: '/barcode-scanner',
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
  ],
);
