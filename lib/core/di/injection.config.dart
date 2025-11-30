// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:offline_ecommerce/data/local/daos/products_dao_di.dart'
    as _i149;
import 'package:offline_ecommerce/data/local/db/app_database_di.dart' as _i769;
import 'package:offline_ecommerce/data/repositories/product_repository_di.dart'
    as _i556;
import 'package:offline_ecommerce/domain/repositories/product_repository.dart'
    as _i375;
import 'package:offline_ecommerce/domain/usecases/product/add_product_usecase.dart'
    as _i368;
import 'package:offline_ecommerce/domain/usecases/product/delete_product_usecase.dart'
    as _i941;
import 'package:offline_ecommerce/domain/usecases/product/get_product_usecase.dart'
    as _i426;
import 'package:offline_ecommerce/domain/usecases/product/get_products_usecase.dart'
    as _i959;
import 'package:offline_ecommerce/domain/usecases/product/update_product_usecase.dart'
    as _i892;
import 'package:offline_ecommerce/presentation/cubits/product/product_cubit.dart'
    as _i902;
import 'package:offline_ecommerce/presentation/cubits/product/product_cubit_di.dart'
    as _i776;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i769.AppDatabaseProvider>(
      () => _i769.AppDatabaseProvider(),
    );
    gh.lazySingleton<_i149.ProductsDaoDI>(
      () => _i149.ProductsDaoDI(gh<_i769.AppDatabaseProvider>()),
    );
    gh.lazySingleton<_i375.ProductRepository>(
      () => _i556.ProductRepositoryDI(gh<_i149.ProductsDaoDI>()),
    );
    gh.factory<_i368.AddProductUseCase>(
      () => _i368.AddProductUseCase(gh<_i375.ProductRepository>()),
    );
    gh.factory<_i941.DeleteProductUseCase>(
      () => _i941.DeleteProductUseCase(gh<_i375.ProductRepository>()),
    );
    gh.factory<_i426.GetProductUseCase>(
      () => _i426.GetProductUseCase(gh<_i375.ProductRepository>()),
    );
    gh.factory<_i959.GetProductsUseCase>(
      () => _i959.GetProductsUseCase(gh<_i375.ProductRepository>()),
    );
    gh.factory<_i892.UpdateProductUseCase>(
      () => _i892.UpdateProductUseCase(gh<_i375.ProductRepository>()),
    );
    gh.factory<_i902.ProductCubit>(
      () => _i902.ProductCubit(
        gh<_i959.GetProductsUseCase>(),
        gh<_i426.GetProductUseCase>(),
        gh<_i368.AddProductUseCase>(),
        gh<_i892.UpdateProductUseCase>(),
        gh<_i941.DeleteProductUseCase>(),
      ),
    );
    gh.factory<_i776.ProductCubitDI>(
      () => _i776.ProductCubitDI(
        gh<_i959.GetProductsUseCase>(),
        gh<_i426.GetProductUseCase>(),
        gh<_i368.AddProductUseCase>(),
        gh<_i892.UpdateProductUseCase>(),
        gh<_i941.DeleteProductUseCase>(),
      ),
    );
    return this;
  }
}
