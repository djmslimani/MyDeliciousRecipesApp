import 'dart:io';
import 'dart:math';

import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_cooking_recipes/pages/recipes.dart';
import 'package:my_cooking_recipes/tools/sqldb.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../routes/routes.dart';
import '../tools/custom_color_theme.dart';
import '../tools/mysnckbar.dart';
import 'package:path/path.dart' as path;

import 'add_recipes.dart';

import 'home_page.dart';

class EditRecipes extends StatefulWidget {
  const EditRecipes({super.key});

  @override
  State<EditRecipes> createState() => _EditRecipesState();
}

class _EditRecipesState extends State<EditRecipes> {
  SqlDb sqlDb = SqlDb();
  String targetPath = '';
  String? imagePath;

  String? titleText;
  String? ingredientText;
  String? recipeText;
  String? selectedValue;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FocusScopeNode? radioCurrentFocus;

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

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    await Navigator.of(context).pushReplacementNamed(RouteManager.recipes);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final myColors = Theme.of(context).extension<CustomColorTheme>()!;
    return FutureBuilder(
      future: readData(),
      builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
        if (snapshot.hasData) {
          selectedValue == null || selectedValue == snapshot.data![0]['type']
              ? selectedValue = snapshot.data![0]['type']
              : null;
          return WillPopScope(
            onWillPop: _onWillPop,
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        myColors.gradientFirstColor!,
                        myColors.gradientSecondColor!
                      ],
                    ),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    extendBodyBehindAppBar: true,
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: Container(
                      height: 12.w,
                      width: 12.w,
                      child: FloatingActionButton(
                        elevation: 20,
                        onPressed: () async {
                          int? count = Sqflite.firstIntValue(
                              await sqlDb.reaAlldData(
                                  "SELECT COUNT(*) FROM Cooking WHERE imagepath = '${snapshot.data![0]['imagepath']}'"));
                          //****Unfocus TextFieald ***********************************//
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          !currentFocus.hasPrimaryFocus
                              ? currentFocus.unfocus()
                              : null;
                          //************************************************************/
                          if (titleText != null && titleText!.isEmpty ||
                              ingredientText != null &&
                                  ingredientText!.isEmpty ||
                              recipeText != null && recipeText!.isEmpty) {
                            formKey.currentState!.validate();
                          } else {
                            try {
                              if (titleText == null) {
                                titleText = snapshot.data![0]['title'];
                              }
                              if (ingredientText == null) {
                                ingredientText =
                                    snapshot.data![0]['ingredient'];
                              }
                              if (recipeText == null) {
                                recipeText = snapshot.data![0]['recipe'];
                              }
                              targetPath == ''
                                  ? targetPath = snapshot.data![0]['imagepath']
                                  : null;

                              var response = await sqlDb.insertData(
                                  '''UPDATE Cooking SET title = "${titleText!.trim().toUpperCase()}", ingredient = "${ingredientText!.trim()}", recipe = "${recipeText!.trim()}", imagepath = "$targetPath", type = "$selectedValue" WHERE id = "${Recipes.id}"''');
                              response is String &&
                                      response.contains('UNIQUE constraint')
                                  ? {
                                      showSnackBar(
                                          context,
                                          AppLocalizations.of(context)!
                                              .recipeexists,
                                          myColors.backgroundPopupMenuRecipes!,
                                          myColors.textPopupMenuRecipes!)
                                    }
                                  : {
                                      await compressAndSaveImages() == true
                                          ? {
                                              showSnackBar(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .successfullychanged,
                                                  myColors
                                                      .backgroundPopupMenuRecipes!,
                                                  myColors
                                                      .textPopupMenuRecipes!),
                                              HomePage.searchIndex
                                                  ? null
                                                  : selectedValue == 'food'
                                                      ? AddRecipes.tabIndex = 0
                                                      : AddRecipes.tabIndex = 1,
                                              ingredientText = '',
                                              titleText = '',
                                              recipeText = '',
                                              targetPath !=
                                                      snapshot.data![0]
                                                          ['imagepath']
                                                  ? {
                                                      count == 1
                                                          ? await File(snapshot
                                                                      .data![0]
                                                                  ['imagepath'])
                                                              .delete()
                                                          : null,
                                                    }
                                                  : null, //Delete the old image from the app.
                                              await Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      RouteManager.recipes),
                                            }
                                          : {
                                              await sqlDb.insertData(
                                                  "UPDATE Cooking SET imagepath = '${snapshot.data![0]['imagepath']}' WHERE id = '${Recipes.id}'"),
                                              showSnackBar(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .unsupportedimagetype,
                                                  myColors
                                                      .backgroundPopupMenuRecipes!,
                                                  myColors
                                                      .textPopupMenuRecipes!)
                                            },
                                    };
                            } catch (e) {}
                          }
                        },
                        child: Icon(
                          Icons.edit_calendar_outlined,
                          size: 8.w,
                        ),
                      ),
                    ),
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 14.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(1.h),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .cannotbeemty;
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      titleText = value;
                                    },
                                    initialValue: snapshot.data![0]['title'],
                                    maxLines: null,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: myColors.textAddAndEditRecipe,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: myColors.textFiealdError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                      label: Text(
                                        AppLocalizations.of(context)!.recipe,
                                        style: TextStyle(
                                            color:
                                                myColors.textAddAndEditRecipe,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .errorBorderAddAndEditRecipe!,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
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
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .cannotbeemty;
                                      }
                                      return null;
                                    },
                                    textAlign: TextAlign.justify,
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: (value) {
                                      ingredientText = value;
                                    },
                                    initialValue: snapshot.data![0]
                                        ['ingredient'],
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: myColors.textAddAndEditRecipe,
                                      fontWeight: FontWeight.bold,
                                      height: 2,
                                    ),
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: myColors.textFiealdError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                      label: Text(
                                        AppLocalizations.of(context)!
                                            .ingredients,
                                        style: TextStyle(
                                            color:
                                                myColors.textAddAndEditRecipe,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .errorBorderAddAndEditRecipe!,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
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
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .cannotbeemty;
                                      }
                                      return null;
                                    },
                                    textAlign: TextAlign.justify,
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: (value) {
                                      recipeText = value;
                                    },
                                    initialValue: snapshot.data![0]['recipe'],
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: myColors.textAddAndEditRecipe,
                                      fontWeight: FontWeight.bold,
                                      height: 2,
                                    ),
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: myColors.textFiealdError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                      label: Text(
                                        AppLocalizations.of(context)!.method,
                                        style: TextStyle(
                                          color: myColors.textAddAndEditRecipe,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .errorBorderAddAndEditRecipe!,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.w,
                                ),
                                Container(
                                  padding: EdgeInsets.all(1.h),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: myColors.textAddAndEditRecipe,
                                      ),
                                      isDense: true,
                                      labelText: AppLocalizations.of(context)!
                                          .chooserecipe,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: myColors
                                                .borderAddAndEditRecipe!,
                                            width: selectedValue != null
                                                ? 2
                                                : 1.0),
                                        borderRadius:
                                            BorderRadius.circular(30.w),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1.w),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedValue == 'food'
                                                    ? myColors
                                                        .recipeTypeBackgroundAddAndEditRecipe
                                                    : null,
                                                border: Border.all(
                                                    color: myColors
                                                        .borderAddAndEditRecipe!),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.w)),
                                              ),
                                              child: RadioListTile<String>(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                                visualDensity: VisualDensity(
                                                    horizontal: -4,
                                                    vertical: -4),
                                                dense: true,
                                                activeColor: myColors
                                                    .radioListTileAddAndEditRecipe,
                                                value: 'food',
                                                groupValue: selectedValue,
                                                title: Text(
                                                  AppLocalizations.of(context)!
                                                      .meals,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: myColors
                                                        .textAddAndEditRecipe,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                toggleable: true,
                                                onChanged: (value) =>
                                                    setState(() {
                                                  value != null
                                                      ? {
                                                          Recipes.initialItem =
                                                              0,
                                                          selectedValue = value,

                                                          //****Unfocus TextFieald ***********************************//
                                                          radioCurrentFocus =
                                                              FocusScope.of(
                                                                  context),
                                                          !radioCurrentFocus!
                                                                  .hasPrimaryFocus
                                                              ? radioCurrentFocus!
                                                                  .unfocus()
                                                              : null,
                                                          //************************************************************/
                                                        }
                                                      : {
                                                          //****Unfocus TextFieald ***********************************//
                                                          radioCurrentFocus =
                                                              FocusScope.of(
                                                                  context),
                                                          !radioCurrentFocus!
                                                                  .hasPrimaryFocus
                                                              ? radioCurrentFocus!
                                                                  .unfocus()
                                                              : null,
                                                          //************************************************************/
                                                        };
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1.w),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedValue == 'sweets'
                                                    ? myColors
                                                        .recipeTypeBackgroundAddAndEditRecipe
                                                    : null,
                                                border: Border.all(
                                                    color: myColors
                                                        .borderAddAndEditRecipe!),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.w)),
                                              ),
                                              child: RadioListTile<String>(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                                visualDensity: VisualDensity(
                                                    horizontal: -4,
                                                    vertical: -4),
                                                dense: true,
                                                activeColor: myColors
                                                    .radioListTileAddAndEditRecipe,
                                                value: 'sweets',
                                                groupValue: selectedValue,
                                                title: Text(
                                                  AppLocalizations.of(context)!
                                                      .desserts,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: myColors
                                                        .textAddAndEditRecipe,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                toggleable: true,
                                                onChanged: (value) =>
                                                    setState(() {
                                                  value != null
                                                      ? {
                                                          Recipes.initialItem =
                                                              0,
                                                          selectedValue = value,

                                                          //****Unfocus TextFieald ***********************************//
                                                          radioCurrentFocus =
                                                              FocusScope.of(
                                                                  context),
                                                          !radioCurrentFocus!
                                                                  .hasPrimaryFocus
                                                              ? radioCurrentFocus!
                                                                  .unfocus()
                                                              : null,
                                                          //************************************************************/
                                                        }
                                                      : {
                                                          //****Unfocus TextFieald ***********************************//
                                                          radioCurrentFocus =
                                                              FocusScope.of(
                                                                  context),
                                                          !radioCurrentFocus!
                                                                  .hasPrimaryFocus
                                                              ? radioCurrentFocus!
                                                                  .unfocus()
                                                              : null,
                                                          //************************************************************/
                                                        };
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(1.h),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.w)),
                                    ),
                                    onPressed: () {
                                      changeThePicture();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .changethepicture,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1.h),
                                    child: InkWell(
                                      onTap: () => changeThePicture(),
                                      child: Container(
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Image(
                                                image: Image.file(File(
                                                        imagePath == null
                                                            ? snapshot.data![0]
                                                                ['imagepath']
                                                            : imagePath))
                                                    .image),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40.w,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(1.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              AppLocalizations.of(context)!
                                      .language
                                      .contains('العربية')
                                  ? Icons.arrow_circle_right_outlined
                                  : Icons.arrow_circle_left_outlined,
                            ),
                            color: myColors.appBarRecipes,
                            iconSize: 7.w,
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushReplacementNamed(RouteManager.recipes);
                            },
                          ),
                        ),
                      ],
                    ),
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
          child: CircularProgressIndicator(),
        ));
      },
    );
  }

  pickImages(ImageSource source) async {
    try {
      //******************Picke an image*********************/
      XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        imagePath = image.path;
      });
      //****************Get the image extenction************/
      final imageExtension = path.extension(imagePath!);
      //***************************************************/

      //********************Create the name of the image************************/
      Random random = new Random();
      String timeAndRandomNumber =
          DateTime.now().toString() + random.nextDouble().toString();
      String name = timeAndRandomNumber.replaceAll(RegExp('[^0-9]'), '');
      const uuid = Uuid();
      String imageName = name + uuid.v4();
      //************************************************************************/

      //*Save images in database path in order to simplify the archive process*/
      String databasePath = await getDatabasesPath();
      targetPath = '$databasePath/$imageName$imageExtension';
      //***********************************************************************/
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> compressAndSaveImages() async {
    try {
      //************Save the picked image without compressing it*******************/
      // await image
      //     .saveTo('${imagePath}${dateString}01$imageExtention');
      //**************************************************************************/
      if (imagePath == null) {
        //imagePath == null. This case happens when we update a recipe without updating the image.
        return true;
      }
      final imageExtention = path.extension(imagePath!);
      if (imageExtention == '.jpg' ||
          imageExtention == '.jpeg' ||
          imageExtention == '.jpe') {
        await FlutterImageCompress.compressAndGetFile(
          imagePath!, //The path of the picked image
          targetPath, //The path where the image will be saved
          quality: 50, //The compression quality
        );
        return true;
      } else {
        //*****************Compress  other images type**********************/
        File imageFile = File(imagePath!);
        File? compressimage = await FileSupport().compressImage(imageFile);
        await compressimage!.copySync(targetPath);
        //******************************************************************/
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  changeThePicture() {
    //****Unfocus TextFieald ***********************************//
    FocusScopeNode currentFocus = FocusScope.of(context);
    !currentFocus.hasPrimaryFocus ? currentFocus.unfocus() : null;
    //************************************************************/
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
          Icons.message_outlined,
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
              AppLocalizations.of(context)!.imagesource,
              textAlign: TextAlign.center,
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
                    borderRadius: new BorderRadius.circular(30.w),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await pickImages(ImageSource.camera);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.red,
                      size: 8.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      AppLocalizations.of(context)!.camera,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.w),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await pickImages(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_iphone_outlined,
                      color: Color.fromARGB(255, 192, 111, 81),
                      size: 7.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      AppLocalizations.of(context)!.gallery,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
