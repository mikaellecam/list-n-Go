import 'package:get_it/get_it.dart';
import 'package:listngo/services/database_service.dart';
import 'package:listngo/services/product_list_service.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);

  getIt.registerLazySingleton<ProductListService>(() => ProductListService());
}
