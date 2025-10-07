import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_cooking_recipes/routes/routes.dart';
import 'package:my_cooking_recipes/tools/custom_color_theme.dart';
import 'package:my_cooking_recipes/tools/load_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sizer/sizer.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());

  // Full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoadPreferences(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return Consumer<LoadPreferences>(
            builder: (context, prefs, _) {
              return MaterialApp(
                title: 'My Delicious Recipes',
                theme: _buildTheme(prefs.chosenTheme),
                locale: _getLocale(prefs.chosenLanguage),
                debugShowCheckedModeBanner: false,
                initialRoute: RouteManager.homePage,
                onGenerateRoute: RouteManager.generateRoute,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: L10n.all,
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(int? chosenTheme) {
    switch (chosenTheme) {
      case 0:
      case null:
        return ThemeData(
          extensions: [CustomColorTheme.themeZero],
          unselectedWidgetColor: Colors.black,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(222, 94, 47, 107)),
              foregroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 65, 255, 1)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(222, 94, 47, 107),
            foregroundColor: Color.fromARGB(255, 65, 255, 1),
          ),
        );
      case 1:
        return ThemeData(
          extensions: [CustomColorTheme.themeOne],
          unselectedWidgetColor: Colors.black,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(224, 48, 180, 162)),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(224, 48, 180, 162),
            foregroundColor: Colors.white,
          ),
        );
      case 2:
        return ThemeData(
          extensions: [CustomColorTheme.themeTwo],
          unselectedWidgetColor: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(225, 88, 108, 135)),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(225, 88, 108, 135),
            foregroundColor: Colors.white,
          ),
        );
      case 3:
        return ThemeData(
          extensions: [CustomColorTheme.themeThree],
          unselectedWidgetColor: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(223, 18, 119, 58)),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(223, 18, 119, 58),
            foregroundColor: Colors.white,
          ),
        );
      case 4:
        return ThemeData(
          extensions: [CustomColorTheme.themeFour],
          unselectedWidgetColor: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(223, 18, 119, 58)),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(223, 119, 18, 111),
            foregroundColor: Colors.white,
          ),
        );
      default:
        return ThemeData(
          extensions: [CustomColorTheme.themeFive],
          unselectedWidgetColor: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(const Color.fromARGB(223, 2, 33, 96)),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(223, 2, 12, 41),
            foregroundColor: Colors.white,
          ),
        );
    }
  }

  Locale? _getLocale(String? chosenLang) {
    switch (chosenLang) {
      case 'en':
        return const Locale('en', 'US');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'ar':
        return const Locale('ar', 'DZ');
      default:
        return null;
    }
  }
}
