import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:intl/intl.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_scroll/text_scroll.dart';

import '../l10n/app_localizations.dart';
import '../routes/routes.dart';
import '../tools/custom_color_theme.dart';
import '../tools/mysnckbar.dart';
import '../tools/recipe_as_pdf.dart';
import '../tools/sqldb.dart';
import 'add_recipes.dart';
import 'home_page.dart';

enum MenuItem {
  edit,
  delete,
  shareAsPdf,
  shareAsAppFormat,
}

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  static int? id;
  static int? initialItem;

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  SqlDb sqlDb = SqlDb();
  String? imagePath;
  String? recipeType;
  String? recipeName;
  String? methodText;
  String? ingredientText;
  int? recipeId;

  bool isValid = false;

  Future<List<Map>> readData() async {
    try {
      List<Map>? sqlData = await sqlDb.readData(
          table: 'Cooking',
          orderby: 'id DESC',
          where: 'id = ?',
          whereArgs: ['${Recipes.id}']);
      return sqlData;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  SharedPreferences? _preferences;
  Future<String?> getPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences?.getString('password');
  }

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    recipeType == 'food' ? AddRecipes.tabIndex = 0 : AddRecipes.tabIndex = 1;
    Navigator.of(context).popUntil((route) => route.isFirst);
    await Navigator.of(context).popAndPushNamed(RouteManager.homePage);
    return false;
  }

  CustomColorTheme? myColors;

  @override
  Widget build(BuildContext context) {
    myColors = Theme.of(context).extension<CustomColorTheme>()!;
    return FutureBuilder(
        future: readData(),
        builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
          if (snapshot.hasData) {
            imagePath = snapshot.data![0]['imagepath'];
            recipeType = snapshot.data![0]['type'];
            recipeName = snapshot.data![0]['title'];
            methodText = snapshot.data![0]['recipe'];
            ingredientText = snapshot.data![0]['ingredient'];
            recipeId = snapshot.data![0]['id'];

            return WillPopScope(
              onWillPop: _onWillPop,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBodyBehindAppBar: true,
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          myColors!.gradientFirstColor!,
                          myColors!.gradientSecondColor!,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 12.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: myColors!.borderRecipes!,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    '${snapshot.data![0]['title']}',
                                    style: TextStyle(
                                      color: myColors!.textRecipes,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.w,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.h),
                                child: Container(
                                  child: InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Image(
                                        image: Image.file(File(
                                                snapshot.data![0]['imagepath']))
                                            .image,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.w,
                              ),
                              Padding(
                                padding: EdgeInsets.all(1.h),
                                child: TextFormField(
                                  textAlign: TextAlign.justify,
                                  textAlignVertical: TextAlignVertical.center,
                                  readOnly: true,
                                  initialValue: snapshot.data![0]['ingredient'],
                                  autofocus: true,
                                  maxLines: null,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: myColors!.textRecipes,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  decoration: InputDecoration(
                                    label: Text(
                                      AppLocalizations.of(context)!.ingredients,
                                      style: TextStyle(
                                        color: myColors!.textRecipes,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.w,
                              ),
                              Padding(
                                padding: EdgeInsets.all(1.h),
                                child: TextFormField(
                                  textAlign: TextAlign.justify,
                                  textAlignVertical: TextAlignVertical.center,
                                  readOnly: true,
                                  initialValue: snapshot.data![0]['recipe'],
                                  maxLines: null,
                                  style: TextStyle(
                                    color: myColors!.textRecipes,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  decoration: InputDecoration(
                                    label: Text(
                                      AppLocalizations.of(context)!.method,
                                      style: TextStyle(
                                        color: myColors!.textRecipes,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: myColors!.borderRecipes!,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(1.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.w)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    AppLocalizations.of(context)!
                                            .language
                                            .contains('العربية')
                                        ? Icons.arrow_circle_right_outlined
                                        : Icons.arrow_circle_left_outlined,
                                  ),
                                  color: myColors!.appBarRecipes,
                                  iconSize: 7.w,
                                  onPressed: () async {
                                    HomePage.searchIndex
                                        ? {
                                            Navigator.of(context).popUntil(
                                                (route) => route.isFirst),
                                            await Navigator.of(context)
                                                .popAndPushNamed(
                                                    RouteManager.searchPage),
                                          }
                                        : {
                                            recipeType == 'food'
                                                ? AddRecipes.tabIndex = 0
                                                : AddRecipes.tabIndex = 1,
                                            Navigator.of(context).popUntil(
                                                (route) => route.isFirst),
                                            await Navigator.of(context)
                                                .popAndPushNamed(
                                                    RouteManager.homePage),
                                          };
                                  },
                                ),
                                Spacer(),
                                PopupMenuButton(
                                  offset: Offset(2.w, 2.h),
                                  constraints: BoxConstraints(maxWidth: 80.w),
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: myColors!.appBarRecipes,
                                  ),
                                  iconSize: 6.w,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  position: PopupMenuPosition.under,
                                  padding: EdgeInsets.all(1.w),
                                  splashRadius: null,
                                  color: myColors!.backgroundPopupMenuRecipes,
                                  onSelected: ((value) async {
                                    final password = await getPreferences();
                                    if (value == MenuItem.edit) {
                                      password == null
                                          ? {
                                              await Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      RouteManager.editRecipes)
                                            }
                                          : {
                                              _showLockScreen(
                                                circleUIConfig: CircleUIConfig(
                                                  circleSize: 5.w,
                                                  fillColor: Colors.amber,
                                                  borderWidth: 0.2.w,
                                                ),
                                                cancelButton: Icon(
                                                  Icons.exit_to_app_outlined,
                                                  size: 10.w,
                                                  color: Colors.white,
                                                ),
                                                keyboardUIConfig:
                                                    KeyboardUIConfig(
                                                  digitTextStyle: TextStyle(
                                                      fontSize: 10.w,
                                                      color: Colors.white),
                                                  digitBorderWidth: 0.3.w,
                                                ),
                                                context,
                                                title: AppLocalizations.of(
                                                        context)!
                                                    .enterpassword,
                                                storedPasscode: password,
                                                opaque: false,
                                                onUnlocked: () async {
                                                  await Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          RouteManager
                                                              .editRecipes);
                                                },
                                              ),
                                            };
                                    } else if (value == MenuItem.delete) {
                                      password == null
                                          ? deleteRecipe()
                                          : _showLockScreen(
                                              circleUIConfig: CircleUIConfig(
                                                circleSize: 5.h,
                                                fillColor: Colors.amber,
                                                borderWidth: 0.2.w,
                                              ),
                                              cancelButton: Icon(
                                                Icons.exit_to_app_outlined,
                                                size: 10.w,
                                                color: Colors.white,
                                              ),
                                              keyboardUIConfig:
                                                  KeyboardUIConfig(
                                                digitTextStyle: TextStyle(
                                                    fontSize: 10.w,
                                                    color: Colors.white),
                                                digitBorderWidth: 0.3.w,
                                              ),
                                              context,
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .enterpassword,
                                              storedPasscode: password,
                                              opaque: false,
                                              onUnlocked: () async {
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 200));
                                                deleteRecipe();
                                              },
                                            );
                                    } else if (value == MenuItem.shareAsPdf) {
                                      shareRecipes(recipeFormat: 1);
                                    } else if (value ==
                                        MenuItem.shareAsAppFormat) {
                                      shareRecipes(recipeFormat: 2);
                                    }
                                  }),
                                  itemBuilder: ((context) => [
                                        PopupMenuItem(
                                          value: MenuItem.edit,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: myColors!
                                                      .iconsPopupMenuRecipes,
                                                  size: 7.w,
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .change,
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: myColors!
                                                          .textPopupMenuRecipes),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: MenuItem.delete,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_forever_rounded,
                                                  color: myColors!
                                                      .iconsPopupMenuRecipes,
                                                  size: 7.w,
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .delete,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: myColors!
                                                        .textPopupMenuRecipes,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: MenuItem.shareAsPdf,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.share,
                                                  color: myColors!
                                                      .iconsPopupMenuRecipes,
                                                  size: 7.w,
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .shareaspdf,
                                                    style: TextStyle(
                                                      color: myColors!
                                                          .textPopupMenuRecipes,
                                                      fontSize: 15.sp,
                                                      height: 2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: MenuItem.shareAsAppFormat,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.w),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.share,
                                                  color: myColors!
                                                      .iconsPopupMenuRecipes,
                                                  size: 7.w,
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Expanded(
                                                  child: TextScroll(
                                                    intervalSpaces: 2.w.toInt(),
                                                    mode:
                                                        TextScrollMode.endless,
                                                    delayBefore: const Duration(
                                                        milliseconds: 500),
                                                    pauseBetween:
                                                        const Duration(
                                                            milliseconds: 100),
                                                    AppLocalizations.of(
                                                            context)!
                                                        .shareasappformat,
                                                    velocity: const Velocity(
                                                        pixelsPerSecond:
                                                            Offset(20, 0)),
                                                    style: TextStyle(
                                                      color: myColors!
                                                          .textPopupMenuRecipes,
                                                      fontSize: 15.sp,
                                                      height: 2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Container(
              height: 8.h,
              width: 8.h,
              child: CircularProgressIndicator(
                color: myColors!.appBarRecipes,
                strokeWidth: 2,
              ),
            ),
          );
        });
  }

  deleteRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(22, 0, 0, 0),
        scrollable: true,
        insetPadding: EdgeInsets
            .zero, //To avoid the error "A RenderFlex overflowed by 24 pixels on the right."
        iconPadding: EdgeInsets.only(top: 2.w),
        contentPadding: EdgeInsets.symmetric(vertical: 2.w),
        actionsPadding: EdgeInsets.symmetric(vertical: 2.w),
        icon: Icon(
          Icons.delete,
          color: Colors.greenAccent[700],
          size: 15.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        content: Column(
          children: [
            Divider(
              height: 2,
              color: Colors.white,
            ),
            SizedBox(
              height: 2.w,
            ),
            Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.deletemessage,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 2.w,
            ),
            Divider(
              height: 2,
              color: Colors.white,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.no,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(
                height: 5.w,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    int? count = Sqflite.firstIntValue(await sqlDb.reaAlldData(
                        "SELECT COUNT(*) FROM Cooking WHERE imagepath = '$imagePath'"));

                    count == 1
                        ? File(imagePath!).delete()
                        : null; //Delete the image from the app
                    var response = await sqlDb.deleteData(
                        "DELETE FROM Cooking WHERE id = '${Recipes.id}'");
                    response == 1
                        ? showSnackBar(
                            context,
                            AppLocalizations.of(context)!.successfullyDeleted,
                            myColors!.backgroundPopupMenuRecipes!,
                            myColors!.textPopupMenuRecipes!)
                        : null;
                  } catch (e) {
                  } finally {
                    recipeType == 'food'
                        ? AddRecipes.tabIndex = 0
                        : AddRecipes.tabIndex = 1;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await Navigator.of(context)
                        .popAndPushNamed(RouteManager.homePage);
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.yes,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //**************************Passcode screen****************************/
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  _showLockScreen(
    BuildContext context, {
    required bool opaque,
    CircleUIConfig? circleUIConfig,
    KeyboardUIConfig? keyboardUIConfig,
    required Widget cancelButton,
    List<String>? digits,
    required VoidCallback? onUnlocked,
    required String storedPasscode,
    required String title,
  }) {
    _onPasscodeEntered(String enteredPasscode) {
      bool isValid = storedPasscode == enteredPasscode;
      _verificationNotifier.add(isValid);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: opaque,
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
            ),
          ),
          circleUIConfig: circleUIConfig,
          keyboardUIConfig: keyboardUIConfig,
          passwordEnteredCallback: _onPasscodeEntered,
          cancelButton: cancelButton,
          deleteButton: Icon(
            Icons.backspace,
            color: Colors.white,
            size: 10.w,
          ),
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: Colors.black.withOpacity(0.8),
          cancelCallback: _onPasscodeCancelled,
          digits: digits,
          passwordDigits: 6,
          isValidCallback: onUnlocked,
        ),
      ),
    );
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }
  //**************************************************************************/

  shareRecipes({required int recipeFormat}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 5.w,
        ),
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              onTap: () {
                Navigator.pop(context);
                recipeFormat == 1
                    ? shareAsPdf(storagePathIndex: 1)
                    : shareAsAppFormat(storagePathIndex: 1);
              },
              child: ListTile(
                title: Text(
                  '\u{1F4F1}' +
                      '  ' +
                      AppLocalizations.of(context)!.localstorage,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: TextScroll(
                  style: TextStyle(fontSize: 13.sp),
                  intervalSpaces: 10,
                  mode: TextScrollMode.endless,
                  delayBefore: const Duration(milliseconds: 500),
                  pauseBetween: const Duration(milliseconds: 100),
                  selectable: false,
                  recipeFormat == 1
                      ? '/storage/emulated/0/Documents'
                      : '/storage/emulated/0/Documents/MyDeliciousRecipesBackups',
                  velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              onTap: () {
                Navigator.pop(context);
                recipeFormat == 1
                    ? shareAsPdf(storagePathIndex: 2)
                    : shareAsAppFormat(storagePathIndex: 2);
              },
              child: ListTile(
                title: Text(
                  '\u{2601}' +
                      '  ' +
                      AppLocalizations.of(context)!.cloudstorage,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  shareAsPdf({required int storagePathIndex}) {
    String? headerName;
    int? languageIndex;
    AppLocalizations.of(context)!.language.contains('العربية')
        ? {
            headerName = 'وصفاتي الشهية',
            languageIndex = 1,
          }
        : AppLocalizations.of(context)!.language.contains('Français')
            ? {
                headerName = 'Mes Délicieuses Recettes',
                languageIndex = 0,
              }
            : {
                headerName = 'My Delicious Recipes',
                languageIndex = 0,
              };
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Container(
            height: 8.h,
            width: 8.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: myColors!.appBarRecipes,
            ),
          ),
        );
      },
      context: context,
    );
    RecipeAsPdf.generate(
      headerName: headerName,
      recipeName: recipeName!,
      imagePath: imagePath!,
      ingredient: AppLocalizations.of(context)!.ingredients,
      ingredientText: ingredientText!,
      method: AppLocalizations.of(context)!.method,
      methodText: methodText!,
      languageIndex: languageIndex,
      storagePathIndex: storagePathIndex,
    ).then((value) => {
          Navigator.pop(context), //Dismiss the CircularProgressIndicator
          storagePathIndex == 1
              ? showSnackBar(
                  context,
                  AppLocalizations.of(context)!.operationcompleted,
                  myColors!.backgroundPopupMenuRecipes!,
                  myColors!.textPopupMenuRecipes!)
              : null,
        });
  }

  shareAsAppFormat({required int storagePathIndex}) async {
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Container(
            height: 8.h,
            width: 8.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: myColors!.appBarRecipes,
            ),
          ),
        );
      },
      context: context,
    );

    try {
      String documentsDirectoryPath =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOCUMENTS);

      await Directory('$documentsDirectoryPath/MyDeliciousRecipesBackups')
              .exists()
          ? null
          : await Directory('$documentsDirectoryPath/MyDeliciousRecipesBackups')
              .create(recursive: true);

      //***Copy Backup to cahce directory, then share it by using share_plus package***/
      final archiveCacheDirectory =
          await Directory('${(await getTemporaryDirectory()).path}/Archive')
              .create(recursive: true);

      final File oldImage = File(imagePath!);

      String imageName = path.basename(imagePath!);

      await oldImage.copy(
          '${archiveCacheDirectory.path}/$imageName'); // Copy the image to the Archive directory.

      String databasePath = await getDatabasesPath();
      final File database = File('$databasePath/cooking.db');
      await database.copy(
          '${archiveCacheDirectory.path}/cooking.db'); // Copy the database to the Archive directory.

      //***Open the newdatabase and delete its content exept the current recipe***************/
      Database mydb =
          await openDatabase('${archiveCacheDirectory.path}/cooking.db');
      await mydb.rawQuery("DELETE FROM Cooking WHERE id != '${recipeId}'");
      mydb.close();
      //*************************************************************************/

      String currentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
      String currentTime = DateFormat("HH-mm-ss").format(DateTime.now());

      var zipFile = storagePathIndex == 1
          ? File(
              '$documentsDirectoryPath/MyDeliciousRecipesBackups/${recipeName}_${currentDate}_${currentTime}.MyDeliciousRecipesBackup')
          : File(
              '${(await getTemporaryDirectory()).path}/${recipeName}_${currentDate}_${currentTime}.MyDeliciousRecipesBackup');

      await ZipFile.createFromDirectory(
        sourceDir: archiveCacheDirectory,
        zipFile: zipFile,
        recurseSubDirs: true,
      ).then((value) => Navigator.pop(context));

      storagePathIndex == 2
          ? await Share.shareXFiles(
              [
                XFile(
                    '${(await getTemporaryDirectory()).path}/${recipeName}_${currentDate}_${currentTime}.MyDeliciousRecipesBackup')
              ],
            )
          : showSnackBar(
              context,
              AppLocalizations.of(context)!.operationcompleted,
              myColors!.backgroundPopupMenuRecipes!,
              myColors!.textPopupMenuRecipes!);

      storagePathIndex == 1
          ? await Directory(archiveCacheDirectory.path).delete(recursive: true)
          : {
              await Directory(archiveCacheDirectory.path)
                  .delete(recursive: true),
              await File(
                      '${(await getTemporaryDirectory()).path}/${recipeName}_${currentDate}_${currentTime}.MyDeliciousRecipesBackup')
                  .delete(),
            };
    } catch (e) {}
    //**************************************************************/
  }
}
