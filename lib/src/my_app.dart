import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc_observer.dart';
import 'config/app_theme.dart';
import 'config/app_route.dart';
import 'container_injector.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Perform all heavy initialization here instead of main()
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      ScreenUtil.ensureScreenSize(),
    ]);

    final prefs = results[0] as SharedPreferences;
    initApp(prefs);
    
    // Defer the observer so it's not needed for the very first frame
    Bloc.observer = MyBlocObserver();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Basic splash/loading state that renders immediately
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0D1B2A), // Match splash color
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
          ),
        ),
      );
    }

    return BlocProvider<ThemeCubit>.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(360, 800),
            minTextAdapt: true,
            splitScreenMode: true,
            child: AnimatedTheme(
              data: themeMode == ThemeMode.dark ? darkTheme() : lightTheme(),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                title: AppStrings.appName,
                theme: lightTheme(),
                darkTheme: darkTheme(),
                themeMode: themeMode,
              ),
            ),
          );
        },
      ),
    );
  }
}
