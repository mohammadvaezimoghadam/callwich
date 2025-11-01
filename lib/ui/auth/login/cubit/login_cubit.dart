import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';

import 'package:callwich/data/repository/auth_repository.dart';

import 'package:equatable/equatable.dart';


part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.authRepository) : super(LoginInitial());
  final IAuthRepository authRepository;

  login({required String userName, required String password}) async {
    emit(LoginLoading());
    try {
      await authRepository.login(userName: userName, password: password);
     
      emit(LoginSuccess());
          
    } catch (e) {
      emit(LoginError(e is AppException?e:AppException()));
    }
  }
}
