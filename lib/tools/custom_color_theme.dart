import 'package:flutter/material.dart';

@immutable
class CustomColorTheme extends ThemeExtension<CustomColorTheme> {
  const CustomColorTheme({
    required this.gradientFirstColor,
    required this.gradientSecondColor,
    required this.appBarHome,
    required this.textTabBarHome,
    required this.tabBarHomeIndicator,
    required this.textCardDecoratedContainer,
    required this.backgroundCardDecoratedContainer,
    required this.appBarAddAndEditRecipe,
    required this.textAddAndEditRecipe,
    required this.borderAddAndEditRecipe,
    required this.recipeTypeBackgroundAddAndEditRecipe,
    required this.radioListTileAddAndEditRecipe,
    required this.textFiealdError,
    required this.appBarRecipes,
    required this.borderRecipes,
    required this.textRecipes,
    required this.appBarSettings,
    required this.iconsSettings,
    required this.textCardSettings,
    required this.arrowsSettings,
    required this.dividersSettings,
    required this.borderContainerSettings,
    required this.backgroundContainerSettings,
    required this.labelContainerSettings,
    required this.textContainerSettings,
    required this.labelBottomSheet,
    required this.backgroundBottomSheet,
    required this.borderBottomSheet,
    required this.textBottomSheet,
    required this.radioListTileBottomSheet,
    required this.errorBorderAddAndEditRecipe,
    required this.textPopupMenuHome,
    required this.iconsPopupMenuHome,
    required this.textPopupMenuRecipes,
    required this.iconsPopupMenuRecipes,
    required this.backgroundPopupMenuHome,
    required this.backgroundPopupMenuRecipes,
  });
  final Color? gradientFirstColor;
  final Color? gradientSecondColor;
  final Color? appBarHome;
  final Color? textTabBarHome;
  final Color? tabBarHomeIndicator;
  final Color? textPopupMenuHome;
  final Color? iconsPopupMenuHome;
  final Color? backgroundPopupMenuHome;
  final Color? textCardDecoratedContainer;
  final Color? backgroundCardDecoratedContainer;
  final Color? appBarAddAndEditRecipe;
  final Color? textAddAndEditRecipe;
  final Color? borderAddAndEditRecipe;
  final Color? errorBorderAddAndEditRecipe;
  final Color? recipeTypeBackgroundAddAndEditRecipe;
  final Color? radioListTileAddAndEditRecipe;
  final Color? textFiealdError;
  final Color? appBarRecipes;
  final Color? borderRecipes;
  final Color? textRecipes;
  final Color? textPopupMenuRecipes;
  final Color? iconsPopupMenuRecipes;
  final Color? backgroundPopupMenuRecipes;
  final Color? appBarSettings;
  final Color? iconsSettings;
  final Color? textCardSettings;
  final Color? arrowsSettings;
  final Color? dividersSettings;
  final Color? borderContainerSettings;
  final Color? backgroundContainerSettings;
  final Color? labelContainerSettings;
  final Color? textContainerSettings;
  final Color? labelBottomSheet;
  final Color? backgroundBottomSheet;
  final Color? borderBottomSheet;
  final Color? textBottomSheet;
  final Color? radioListTileBottomSheet;

  @override
  CustomColorTheme copyWith({
    Color? gradientFirstColor,
    Color? gradientSecondColor,
    Color? appBarHome,
    Color? textTabBarHome,
    Color? tabBarHomeIndicator,
    Color? textPopupMenuHome,
    Color? iconsPopupMenuHome,
    Color? backgroundPopupMenuHome,
    Color? textCardDecoratedContainer,
    Color? backgroundCardDecoratedContainer,
    Color? appBarAddAndEditRecipe,
    Color? textAddAndEditRecipe,
    Color? borderAddAndEditRecipe,
    Color? errorBorderAddAndEditRecipe,
    Color? recipeTypeBackgroundAddAndEditRecipe,
    Color? radioListTileAddAndEditRecipe,
    Color? textPopupMenuAddAndEditRecipe,
    Color? iconsPopupMenuAddAndEditRecipe,
    Color? backgroundPopupMenuAddAndEditRecipe,
    Color? textFiealdError,
    Color? appBarRecipes,
    Color? borderRecipes,
    Color? textRecipes,
    Color? textPopupMenuRecipes,
    Color? iconsPopupMenuRecipes,
    Color? backgroundPopupMenuRecipes,
    Color? appBarSettings,
    Color? iconsSettings,
    Color? textCardSettings,
    Color? arrowsSettings,
    Color? dividersSettings,
    Color? borderContainerSettings,
    Color? backgroundContainerSettings,
    Color? labelContainerSettings,
    Color? textContainerSettings,
    Color? labelBottomSheet,
    Color? backgroundBottomSheet,
    Color? borderBottomSheet,
    Color? textBottomSheet,
    Color? radioListTileBottomSheet,
  }) {
    return CustomColorTheme(
      gradientFirstColor: gradientFirstColor ?? this.gradientFirstColor,
      gradientSecondColor: gradientSecondColor ?? this.gradientSecondColor,
      appBarHome: appBarHome ?? this.appBarHome,
      textTabBarHome: textTabBarHome ?? this.textTabBarHome,
      tabBarHomeIndicator: tabBarHomeIndicator ?? this.tabBarHomeIndicator,
      textPopupMenuHome: textPopupMenuHome ?? this.textPopupMenuHome,
      iconsPopupMenuHome: iconsPopupMenuHome ?? this.iconsPopupMenuHome,
      backgroundPopupMenuHome:
          backgroundPopupMenuHome ?? this.backgroundPopupMenuHome,
      textCardDecoratedContainer:
          textCardDecoratedContainer ?? this.textCardDecoratedContainer,
      backgroundCardDecoratedContainer: backgroundCardDecoratedContainer ??
          this.backgroundCardDecoratedContainer,
      appBarAddAndEditRecipe:
          appBarAddAndEditRecipe ?? this.appBarAddAndEditRecipe,
      textAddAndEditRecipe: textAddAndEditRecipe ?? this.textAddAndEditRecipe,
      borderAddAndEditRecipe:
          borderAddAndEditRecipe ?? this.borderAddAndEditRecipe,
      errorBorderAddAndEditRecipe:
          errorBorderAddAndEditRecipe ?? this.errorBorderAddAndEditRecipe,
      recipeTypeBackgroundAddAndEditRecipe:
          recipeTypeBackgroundAddAndEditRecipe ??
              this.recipeTypeBackgroundAddAndEditRecipe,
      radioListTileAddAndEditRecipe:
          radioListTileAddAndEditRecipe ?? this.radioListTileAddAndEditRecipe,
      textPopupMenuRecipes: textPopupMenuRecipes ?? this.textPopupMenuRecipes,
      iconsPopupMenuRecipes:
          iconsPopupMenuRecipes ?? this.iconsPopupMenuRecipes,
      backgroundPopupMenuRecipes:
          backgroundPopupMenuRecipes ?? this.backgroundPopupMenuRecipes,
      textFiealdError: textFiealdError ?? this.textFiealdError,
      appBarRecipes: appBarRecipes ?? this.appBarRecipes,
      borderRecipes: borderRecipes ?? this.borderRecipes,
      textRecipes: textRecipes ?? this.textRecipes,
      appBarSettings: appBarSettings ?? this.appBarSettings,
      iconsSettings: iconsSettings ?? this.iconsSettings,
      textCardSettings: textCardSettings ?? this.textCardSettings,
      arrowsSettings: arrowsSettings ?? this.arrowsSettings,
      dividersSettings: dividersSettings ?? this.dividersSettings,
      borderContainerSettings:
          borderContainerSettings ?? this.borderContainerSettings,
      backgroundContainerSettings:
          backgroundContainerSettings ?? this.backgroundContainerSettings,
      labelContainerSettings:
          labelContainerSettings ?? this.labelContainerSettings,
      textContainerSettings:
          textContainerSettings ?? this.textContainerSettings,
      labelBottomSheet: labelBottomSheet ?? this.labelBottomSheet,
      backgroundBottomSheet:
          backgroundBottomSheet ?? this.backgroundBottomSheet,
      borderBottomSheet: borderBottomSheet ?? this.borderBottomSheet,
      textBottomSheet: textBottomSheet ?? this.textBottomSheet,
      radioListTileBottomSheet:
          radioListTileBottomSheet ?? this.radioListTileBottomSheet,
    );
  }

  // Controls how the properties change on theme changes
  @override
  CustomColorTheme lerp(ThemeExtension<CustomColorTheme>? other, double t) {
    if (other is! CustomColorTheme) {
      return this;
    }
    return CustomColorTheme(
      gradientFirstColor:
          Color.lerp(gradientFirstColor, other.gradientFirstColor, t),
      gradientSecondColor:
          Color.lerp(gradientSecondColor, other.gradientSecondColor, t),
      appBarHome: Color.lerp(appBarHome, other.appBarHome, t),
      textTabBarHome: Color.lerp(textTabBarHome, other.textTabBarHome, t),
      tabBarHomeIndicator:
          Color.lerp(tabBarHomeIndicator, other.tabBarHomeIndicator, t),
      textPopupMenuHome:
          Color.lerp(textPopupMenuHome, other.textPopupMenuHome, t),
      iconsPopupMenuHome:
          Color.lerp(iconsPopupMenuHome, other.iconsPopupMenuHome, t),
      backgroundPopupMenuHome:
          Color.lerp(backgroundPopupMenuHome, other.backgroundPopupMenuHome, t),
      textCardDecoratedContainer: Color.lerp(
          textCardDecoratedContainer, other.textCardDecoratedContainer, t),
      backgroundCardDecoratedContainer: Color.lerp(
          backgroundCardDecoratedContainer,
          other.backgroundCardDecoratedContainer,
          t),
      appBarAddAndEditRecipe:
          Color.lerp(appBarAddAndEditRecipe, other.appBarAddAndEditRecipe, t),
      textAddAndEditRecipe:
          Color.lerp(textAddAndEditRecipe, other.textAddAndEditRecipe, t),
      borderAddAndEditRecipe:
          Color.lerp(borderAddAndEditRecipe, other.borderAddAndEditRecipe, t),
      errorBorderAddAndEditRecipe: Color.lerp(
          errorBorderAddAndEditRecipe, other.errorBorderAddAndEditRecipe, t),
      recipeTypeBackgroundAddAndEditRecipe: Color.lerp(
          recipeTypeBackgroundAddAndEditRecipe,
          other.recipeTypeBackgroundAddAndEditRecipe,
          t),
      radioListTileAddAndEditRecipe: Color.lerp(radioListTileAddAndEditRecipe,
          other.radioListTileAddAndEditRecipe, t),
      textPopupMenuRecipes:
          Color.lerp(textPopupMenuRecipes, other.textPopupMenuRecipes, t),
      iconsPopupMenuRecipes:
          Color.lerp(iconsPopupMenuRecipes, other.iconsPopupMenuRecipes, t),
      backgroundPopupMenuRecipes: Color.lerp(
          backgroundPopupMenuRecipes, other.backgroundPopupMenuRecipes, t),
      textFiealdError: Color.lerp(textFiealdError, other.textFiealdError, t),
      appBarRecipes: Color.lerp(appBarRecipes, other.appBarRecipes, t),
      borderRecipes: Color.lerp(borderRecipes, other.borderRecipes, t),
      textRecipes: Color.lerp(textRecipes, other.textRecipes, t),
      appBarSettings: Color.lerp(appBarSettings, other.appBarSettings, t),
      iconsSettings: Color.lerp(iconsSettings, other.iconsSettings, t),
      textCardSettings: Color.lerp(textCardSettings, other.textCardSettings, t),
      arrowsSettings: Color.lerp(arrowsSettings, other.arrowsSettings, t),
      dividersSettings: Color.lerp(dividersSettings, other.dividersSettings, t),
      borderContainerSettings:
          Color.lerp(borderContainerSettings, other.borderContainerSettings, t),
      backgroundContainerSettings: Color.lerp(
          backgroundContainerSettings, other.backgroundContainerSettings, t),
      labelContainerSettings:
          Color.lerp(labelContainerSettings, other.labelContainerSettings, t),
      textContainerSettings:
          Color.lerp(textContainerSettings, other.textContainerSettings, t),
      labelBottomSheet: Color.lerp(labelBottomSheet, other.labelBottomSheet, t),
      backgroundBottomSheet:
          Color.lerp(backgroundBottomSheet, other.backgroundBottomSheet, t),
      borderBottomSheet:
          Color.lerp(borderBottomSheet, other.borderBottomSheet, t),
      textBottomSheet: Color.lerp(textBottomSheet, other.textBottomSheet, t),
      radioListTileBottomSheet: Color.lerp(
          radioListTileBottomSheet, other.radioListTileBottomSheet, t),
    );
  }

  // Theme zero (the default theme)
  static final themeZero = CustomColorTheme(
    gradientFirstColor: Colors.purpleAccent
        .withOpacity(0.78), //Color.fromARGB(207, 223, 64, 251),
    gradientSecondColor: Colors.pinkAccent
        .withOpacity(0.78), //Color.fromARGB(214, 255, 64, 128),
    appBarHome: Colors.white,
    textTabBarHome: Colors.black,
    tabBarHomeIndicator: Colors.white,
    textPopupMenuHome: Color.fromARGB(255, 65, 255, 1),
    iconsPopupMenuHome: Color.fromARGB(255, 254, 194, 42),
    backgroundPopupMenuHome: Color.fromARGB(222, 94, 47, 107),
    textCardDecoratedContainer: Colors.black,
    backgroundCardDecoratedContainer: Colors.transparent,
    appBarAddAndEditRecipe: Colors.black,
    textAddAndEditRecipe: Colors.black,
    borderAddAndEditRecipe: Colors.black,
    errorBorderAddAndEditRecipe: Color.fromARGB(255, 4, 4, 199),
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Color.fromARGB(255, 7, 3, 125),
    textFiealdError: Color.fromARGB(255, 62, 72, 86),
    appBarRecipes: Colors.white,
    borderRecipes: Colors.black,
    textRecipes: Colors.black,
    textPopupMenuRecipes: Color.fromARGB(255, 65, 255, 1),
    iconsPopupMenuRecipes: Color.fromARGB(255, 254, 194, 42),
    backgroundPopupMenuRecipes: Color.fromARGB(222, 94, 47, 107),
    appBarSettings: Colors.black,
    iconsSettings: Color.fromARGB(255, 27, 255, 6),
    textCardSettings: Colors.black,
    arrowsSettings: Colors.white,
    dividersSettings: Colors.white,
    borderContainerSettings: Colors.white,
    backgroundContainerSettings: Color.fromARGB(255, 55, 93, 128),
    labelContainerSettings: Colors.white,
    textContainerSettings: Colors.white,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );
  // Theme one
  static final themeOne = CustomColorTheme(
    gradientFirstColor: Colors.blue.withOpacity(0.78),
    gradientSecondColor: Color.fromARGB(255, 227, 242, 253).withOpacity(0.78),
    appBarHome: Colors.white,
    textTabBarHome: Colors.black,
    tabBarHomeIndicator: Colors.white,
    textPopupMenuHome: Color.fromARGB(255, 255, 255, 255),
    iconsPopupMenuHome: Color.fromARGB(210, 4, 25, 130),
    backgroundPopupMenuHome: Color.fromARGB(224, 48, 180, 162),
    textCardDecoratedContainer: Colors.black,
    backgroundCardDecoratedContainer: Colors.transparent,
    appBarAddAndEditRecipe: Colors.black,
    textAddAndEditRecipe: Colors.black,
    borderAddAndEditRecipe: Colors.black,
    errorBorderAddAndEditRecipe: Colors.red,
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Colors.redAccent,
    textFiealdError: Colors.red,
    appBarRecipes: Colors.white,
    borderRecipes: Colors.black,
    textRecipes: Colors.black,
    textPopupMenuRecipes: Color.fromARGB(255, 255, 255, 255),
    iconsPopupMenuRecipes: Color.fromARGB(210, 4, 25, 130),
    backgroundPopupMenuRecipes: Color.fromARGB(224, 48, 180, 162),
    appBarSettings: Colors.black,
    iconsSettings: Color.fromARGB(255, 27, 255, 6),
    textCardSettings: Colors.black,
    arrowsSettings: Colors.white,
    dividersSettings: Colors.white,
    borderContainerSettings: Colors.black,
    backgroundContainerSettings: Color.fromARGB(255, 54, 141, 222),
    labelContainerSettings: Colors.black,
    textContainerSettings: Colors.black,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );
  // Theme two
  static const themeTwo = CustomColorTheme(
    gradientFirstColor: Color.fromARGB(200, 31, 45, 58), //Color(0xFF1f2d3a),
    gradientSecondColor: Color.fromARGB(228, 31, 45, 58), //Color(0xFF1f2d3a)
    appBarHome: Colors.white,
    textTabBarHome: Colors.white,
    tabBarHomeIndicator: Colors.red,
    textPopupMenuHome: Colors.white,
    iconsPopupMenuHome: Color.fromARGB(173, 89, 255, 0),
    backgroundPopupMenuHome: Color.fromARGB(195, 2, 5, 43),
    textCardDecoratedContainer: Colors.black,
    backgroundCardDecoratedContainer: Color.fromARGB(118, 247, 202, 0),
    appBarAddAndEditRecipe: Colors.red,
    textAddAndEditRecipe: Colors.white,
    borderAddAndEditRecipe: Color.fromARGB(255, 132, 255, 0),
    errorBorderAddAndEditRecipe: Colors.red,
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Colors.redAccent,
    textFiealdError: Colors.red,
    appBarRecipes: Colors.white,
    borderRecipes: Color.fromARGB(255, 132, 255, 0),
    textRecipes: Colors.white,
    textPopupMenuRecipes: Colors.white,
    iconsPopupMenuRecipes: Color.fromARGB(255, 89, 255, 0),
    backgroundPopupMenuRecipes: Color.fromARGB(225, 88, 108, 135),
    appBarSettings: Colors.white,
    iconsSettings: Colors.red,
    textCardSettings: Colors.white,
    arrowsSettings: Colors.white,
    dividersSettings: Colors.white,
    borderContainerSettings: Colors.white,
    backgroundContainerSettings: Color(0xFF1d2731),
    labelContainerSettings: Colors.white,
    textContainerSettings: Colors.white,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );

  // Theme three
  static final themeThree = CustomColorTheme(
    gradientFirstColor: Color.fromARGB(255, 4, 2, 120).withOpacity(0.9),
    gradientSecondColor:
        Color.fromARGB(255, 61, 155, 106).withOpacity(0.9), //Color(0xFF1d2731),
    appBarHome: Colors.white,
    textTabBarHome: Colors.white,
    tabBarHomeIndicator: Color.fromARGB(255, 255, 0, 255),
    textPopupMenuHome: Colors.white,
    iconsPopupMenuHome: Color.fromARGB(235, 198, 236, 7),
    backgroundPopupMenuHome: Color.fromARGB(223, 18, 119, 58),
    textCardDecoratedContainer: Colors.black,
    backgroundCardDecoratedContainer: Color.fromARGB(118, 148, 247, 0),
    appBarAddAndEditRecipe: Colors.red,
    textAddAndEditRecipe: Colors.white,
    borderAddAndEditRecipe: Color.fromARGB(255, 132, 255, 0),
    errorBorderAddAndEditRecipe: Colors.red,
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Colors.redAccent,
    textFiealdError: Colors.red,
    appBarRecipes: Colors.white,
    borderRecipes: Color.fromARGB(255, 132, 255, 0),
    textRecipes: Colors.white,
    textPopupMenuRecipes: Colors.white,
    iconsPopupMenuRecipes: Color.fromARGB(255, 255, 0, 255),
    backgroundPopupMenuRecipes: Color.fromARGB(223, 18, 119, 58),
    appBarSettings: Colors.white,
    iconsSettings: Colors.red,
    textCardSettings: Colors.white,
    arrowsSettings: Colors.white,
    dividersSettings: Colors.white,
    borderContainerSettings: Colors.white,
    backgroundContainerSettings: Color(0xFF1d2731),
    labelContainerSettings: Colors.white,
    textContainerSettings: Colors.white,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );

  // Theme four
  static final themeFour = CustomColorTheme(
    gradientFirstColor: Colors.purple.withOpacity(0.88),
    gradientSecondColor: Colors.blue.withOpacity(0.88), //Color(0xFF1d2731),
    appBarHome: Colors.white,
    textTabBarHome: Colors.white,
    tabBarHomeIndicator: Color.fromARGB(255, 255, 0, 255),
    textPopupMenuHome: Colors.black,
    iconsPopupMenuHome: Color.fromARGB(255, 187, 23, 11),
    backgroundPopupMenuHome: Color.fromARGB(226, 211, 186, 62),
    textCardDecoratedContainer: Colors.black,
    backgroundCardDecoratedContainer: Color.fromARGB(118, 148, 247, 0),
    appBarAddAndEditRecipe: Colors.black,
    textAddAndEditRecipe: Colors.white,
    borderAddAndEditRecipe: Color.fromARGB(255, 132, 255, 0),
    errorBorderAddAndEditRecipe: Colors.red,
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Colors.redAccent,
    textFiealdError: Colors.red,
    appBarRecipes: Colors.white,
    borderRecipes: Color.fromARGB(255, 132, 255, 0),
    textRecipes: Colors.white,
    textPopupMenuRecipes: Colors.black,
    iconsPopupMenuRecipes: Color.fromARGB(255, 187, 23, 11),
    backgroundPopupMenuRecipes: Color.fromARGB(226, 211, 186, 62),
    appBarSettings: Colors.white,
    iconsSettings: Colors.red,
    textCardSettings: Colors.white,
    arrowsSettings: Colors.white,
    dividersSettings: Colors.white,
    borderContainerSettings: Colors.white,
    backgroundContainerSettings: Color(0xFF1d2731),
    labelContainerSettings: Colors.white,
    textContainerSettings: Colors.white,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );

  // Theme five
  static final themeFive = CustomColorTheme(
    gradientFirstColor: Color.fromARGB(255, 240, 237, 237).withOpacity(0.78),
    gradientSecondColor: Color.fromARGB(255, 240, 237, 237)
        .withOpacity(0.78), //Color(0xFF1d2731),
    appBarHome: Colors.black,
    textTabBarHome: Colors.black,
    tabBarHomeIndicator: Color.fromARGB(255, 255, 0, 21),
    textPopupMenuHome: Colors.white,
    iconsPopupMenuHome: Color.fromARGB(255, 187, 23, 11),
    backgroundPopupMenuHome: Color.fromARGB(232, 244, 176, 57),
    textCardDecoratedContainer: Colors.white,
    backgroundCardDecoratedContainer: Color.fromARGB(235, 67, 88, 182),
    appBarAddAndEditRecipe: Colors.black,
    textAddAndEditRecipe: Colors.black,
    borderAddAndEditRecipe: Color.fromARGB(255, 135, 10, 245),
    errorBorderAddAndEditRecipe: Colors.red,
    recipeTypeBackgroundAddAndEditRecipe: Color.fromARGB(57, 10, 156, 142),
    radioListTileAddAndEditRecipe: Colors.redAccent,
    textFiealdError: Colors.red,
    appBarRecipes: Colors.black,
    borderRecipes: Color.fromARGB(255, 135, 10, 245),
    textRecipes: Colors.black,
    textPopupMenuRecipes: Colors.white,
    iconsPopupMenuRecipes: Colors.black,
    backgroundPopupMenuRecipes: Color.fromARGB(222, 129, 117, 51),
    appBarSettings: Colors.black,
    iconsSettings: Color.fromARGB(255, 187, 23, 11),
    textCardSettings: Colors.black,
    arrowsSettings: Color.fromARGB(255, 187, 23, 11),
    dividersSettings: Color.fromARGB(255, 187, 23, 11),
    borderContainerSettings: Colors.white,
    backgroundContainerSettings: Color.fromARGB(255, 134, 186, 193),
    labelContainerSettings: Color.fromARGB(255, 1, 21, 44),
    textContainerSettings: Colors.black,
    backgroundBottomSheet: Color(0xFF1f2d3a),
    borderBottomSheet: Colors.white,
    labelBottomSheet: Colors.lightBlueAccent,
    radioListTileBottomSheet: Colors.redAccent,
    textBottomSheet: Colors.white,
  );
}
