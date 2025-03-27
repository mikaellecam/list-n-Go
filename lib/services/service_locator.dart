import 'package:get_it/get_it.dart';
import 'package:listngo/repositories/product_list_repository.dart';
import 'package:listngo/state/product_list_manager.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<ProductListRepository>(
    () => ProductListRepository(),
  );

  getIt.registerLazySingleton<ProductListManager>(() => ProductListManager());
}
