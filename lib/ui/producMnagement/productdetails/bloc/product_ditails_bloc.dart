import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

part 'product_ditails_event.dart';
part 'product_ditails_state.dart';

class ProductDitailsBloc
    extends Bloc<ProductDitailsEvent, ProductDitailsState> {
  final IProductRepository productRepository;
  ProductDitailsBloc(this.productRepository)
    : super(
        ProductDitailsSuccess(deletBtnIsLoading: false, recipesLoading: false),
      ) {
    on<ProductDitailsEvent>((event, emit) async {
      if (event is DeleteBtnIsClicked) {
        emit(
          ProductDitailsSuccess(deletBtnIsLoading: true, recipesLoading: false),
        );
        try {
          await productRepository.deletProduct(event.productId);
          GetIt.instance<AppStateManager>().triggerAllPagesReload();
          emit(WhemDeleIsCom());
        } catch (e) {
          emit(
            ProductDitailsError(
              appException: e is AppException ? e : AppException(),
            ),
          );
        }
      } else if (event is RecipeaStarted) {}
    });
  }
}
