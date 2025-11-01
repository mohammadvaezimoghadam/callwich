//import 'package:callwich/data/repository/auth_repository.dart';
//import 'package:callwich/ui/auth/splash/cubit/auth_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';

class SplahScreen extends StatefulWidget {
  const SplahScreen({super.key});

  @override
  State<SplahScreen> createState() => _SplahScreenState();
}

class _SplahScreenState extends State<SplahScreen> {
  @override
  void initState() {
    super.initState();
  //  AuthRepository.authChangeNotifier.addListener(_onAuthChanched);
  }

  @override
  void dispose() {
    super.dispose();
   // AuthRepository.authChangeNotifier.removeListener(_onAuthChanched);
  }

  // void _onAuthChanched() {
  //   BlocProvider.of<AuthCubit>(context).authChanged(AuthRepository.authChangeNotifier.value);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFF6B35),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFB84C),
        child: Center(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.1),
                      duration: Duration(milliseconds: 900),
                      curve: Curves.easeInOutCubic,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      onEnd: () {},
                      child: Image.asset(
                        'assets/png/splash.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10),

                    Text(
                      'CallWich',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazirmatn',
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.black38,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cupertinoOverrideTheme: const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ),
                      ),
                      child: const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
