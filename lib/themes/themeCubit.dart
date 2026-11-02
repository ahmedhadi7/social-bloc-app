import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/themes/dark_mood.dart';
import 'package:social_bloc/themes/light_mode.dart';

class ThemeCubit extends Cubit<ThemeData> {
  bool _isDarkMode = false;

   ThemeCubit() : super(lightMode);

   bool get isDarkMode => _isDarkMode;


   void toggleTheme() {
     _isDarkMode = !_isDarkMode;

     if (_isDarkMode) {
       emit(darkMode);
     } else {
       emit(lightMode);
     }

   }
 }