import 'package:bloc/bloc.dart';
import 'package:callwich/data/models/auth.dart';
import 'package:callwich/data/repository/auth_repository.dart';

import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  
  AuthCubit() : super(AuthInitialState()) {
    Future.delayed(Duration(seconds: 4)).then((_) {
      if (AuthRepository.authChangeNotifier.value == null) {
        emit(AuthLoggedOutState());
      } else if (AuthRepository.authChangeNotifier.value != null ||
          AuthRepository.authChangeNotifier.value!.accessToken.isNotEmpty) {
        emit(AuthLoggedInState());
      }
    });
  }

  

 

  void authChanged(AuthEntity? authEntity) {
    if (authEntity == null || authEntity.tokenType.isEmpty) {
      emit(AuthLoggedOutState());
    } else {
      emit(AuthLoggedInState());
    }
  }
}
