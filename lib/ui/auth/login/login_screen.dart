import 'dart:async';

import 'package:callwich/di/di.dart';
import 'package:callwich/data/repository/auth_repository.dart';
import 'package:callwich/ui/auth/login/cubit/login_cubit.dart';
import 'package:callwich/ui/auth/splash/cubit/auth_cubit.dart';

import 'package:flutter/material.dart';
import 'package:callwich/res/strings.dart';
import 'package:callwich/res/dimens.dart';
import 'package:callwich/widgets/custom_text_field_widget.dart';
import 'package:callwich/widgets/login_button_widget.dart';
import 'package:callwich/components/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late LoginCubit? loginBloc;
  late StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();

    AuthRepository.authChangeNotifier.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    BlocProvider.of<AuthCubit>(
      context,
    ).authChanged(AuthRepository.authChangeNotifier.value);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    AuthRepository.authChangeNotifier.removeListener(_onAuthChanged);
    _passwordController.dispose();
    loginBloc!.close();
    streamSubscription!.cancel();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocProvider<LoginCubit>(
      create: (context) {
        loginBloc = LoginCubit(getIt<IAuthRepository>());
        streamSubscription = loginBloc!.stream.listen((state) {
          if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.appException.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        });
        return loginBloc!;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.welcomeBack,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    AppDimens.small.toInt().heightBox,
                    Text(
                      AppStrings.loginSubtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppDimens.large.toInt().heightBox,
                    CustomTextFieldWidget(
                      controller: _usernameController,
                      hintText: AppStrings.username,
                      prefixIcon: Icons.person_outline,
                      autofocus: true,
                    ),
                    AppDimens.medium.toInt().heightBox,
                    CustomTextFieldWidget(
                      controller: _passwordController,
                      hintText: AppStrings.password,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon:
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                      onSuffixIconPressed: _togglePasswordVisibility,
                      obscureText: _obscurePassword,
                    ),
                    (AppDimens.medium + AppDimens.small).toInt().heightBox,
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        if (state is LoginInitial ||
                            state is LoginError ||
                            state is LoginSuccess) {
                          return LoginButtonWidget(
                            onPressed: () {
                              loginBloc!.login(
                                userName: _usernameController.text,
                                password: _passwordController.text,
                              );
                            },
                            mainColor: colorScheme.primary,
                          );
                        } else if (state is LoginLoading) {
                          return LoginButtonWidget(
                            loading: true,
                            onPressed: () {},
                            mainColor: colorScheme.primary,
                          );
                        } else {
                          throw Exception("stat not valid");
                        }
                      },
                    ),
                    AppDimens.medium.toInt().heightBox,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password logic
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
