import 'package:flutter/material.dart';
import 'package:my_cooking_recipes/tools/load_preferences.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../pages/add_recipes.dart';
import '../pages/edit_recipes.dart';
import '../pages/home_page.dart';
import '../pages/recipes.dart';
import '../pages/settings.dart';
import '../pages/search_page.dart';

class RouteManager {
  static const String homePage = '/';
  static const String addRecipes = '/addRecipes';
  static const String recipes = '/recipes';
  static const String editRecipes = '/editRecipes';
  static const String mySettings = '/mySettings';
  static const String searchPage = '/searchPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (context) {
            final lang = context.read<LoadPreferences>().chosenLanguage;

            return UpgradeAlert(
              upgrader: Upgrader(
                debugDisplayAlways: false, // 👈 force dialog for testing
                languageCode: lang,
                messages: UpgraderMessages(code: lang),
              ),
              child: const HomePage(),
            );
          },
        );

      case addRecipes:
        return MaterialPageRoute(builder: (context) => const AddRecipes());
      case recipes:
        return MaterialPageRoute(builder: (context) => const Recipes());
      case editRecipes:
        return MaterialPageRoute(builder: (context) => const EditRecipes());
      case mySettings:
        return MaterialPageRoute(builder: (context) => const MySettings());
      case searchPage:
        return MaterialPageRoute(builder: (context) => const SearchPage());

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Route not found, check routes again!')),
          ),
        );
    }
  }
}
