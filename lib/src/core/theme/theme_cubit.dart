import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark, // Default to dark theme
    };
  }

  bool get isDark => state == ThemeMode.dark;

  void toggleTheme() {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
    emit(next);
  }
}
