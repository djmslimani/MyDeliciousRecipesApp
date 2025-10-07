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
import 'package:path/path.dart' as path;

import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../routes/routes.dart';
import '../tools/custom_color_theme.dart';
import '../tools/mysnckbar.dart';

class AddRecipes extends StatefulWidget {
  const AddRecipes({super.key});

  static int tabIndex = 2;
  static int? initialItem;

  @override
  State<AddRecipes> createState() => _AddRecipesState();
}

class _AddRecipesState extends State<AddRecipes> {
  SqlDb sqlDb = SqlDb();
  String? targetPath;
  String? imagePath;

  var titleController = TextEditingController();
  var ingredientController = TextEditingController();
  var recipeController = TextEditingController();

  bool containerImage = true;

  String? selectedValue;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FocusScopeNode? radioCurrentFocus;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    ingredientController.dispose();
    recipeController.dispose();
    super.dispose();
  }

  bool isButtonActive = true;

  @override
  Widget build(BuildContext context) {
    final myColors = Theme.of(context).extension<CustomColorTheme>()!;
    return GestureDetector(
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
          child: PopScope(
            canPop: false, // stop default back navigation
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return; // if system already popped, do nothing

              Recipes.initialItem = null;
              await Navigator.of(context)
                  .popAndPushNamed(RouteManager.homePage);
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Container(
                height: 14.w,
                width: 14.w,
                child: FloatingActionButton(
                  elevation: 20,
                  onPressed: () async {
                    if (isButtonActive) {
                      //****Unfocus TextFieald ***********************************//
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      !currentFocus.hasPrimaryFocus
                          ? currentFocus.unfocus()
                          : null;
                      //************************************************************/
                      if (titleController.text.isEmpty ||
                          ingredientController.text.isEmpty ||
                          recipeController.text.isEmpty) {
                        formKey.currentState!.validate();
                      } else if (imagePath == null) {
                        showSnackBar(
                            context,
                            AppLocalizations.of(context)!.nopicture,
                            myColors.backgroundPopupMenuHome!,
                            myColors.textPopupMenuHome!);
                      } else if (selectedValue == null) {
                        showSnackBar(
                            context,
                            AppLocalizations.of(context)!.norecipetype,
                            myColors.backgroundPopupMenuHome!,
                            myColors.textPopupMenuHome!);
                      } else {
                        try {
                          var response = await sqlDb.insertData(
                              '''INSERT INTO Cooking (title, ingredient, recipe, imagepath, type) VALUES ("${titleController.text.trim().toUpperCase()}", "${ingredientController.text.trim()}", "${recipeController.text.trim()}", "$targetPath", "$selectedValue")''');
                          response is String &&
                                  response.contains('UNIQUE constraint')
                              ? {
                                  showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .recipeexists,
                                      myColors.backgroundPopupMenuHome!,
                                      myColors.textPopupMenuHome!)
                                }
                              : {
                                  await compressAndSaveImages() == true
                                      ? {
                                          isButtonActive = false,
                                          showSnackBar(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .successfullysaved,
                                              myColors.backgroundPopupMenuHome!,
                                              myColors.textPopupMenuHome!),
                                          selectedValue == 'food'
                                              ? AddRecipes.tabIndex = 0
                                              : AddRecipes.tabIndex = 1,
                                          ingredientController.clear(),
                                          titleController.clear(),
                                          recipeController.clear(),
                                          setState(() {
                                            containerImage = false;
                                          }),
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst),
                                          Navigator.of(context).popAndPushNamed(
                                              RouteManager.homePage),
                                        }
                                      : {
                                          await sqlDb.deleteData(
                                              "DELETE FROM Cooking WHERE imagepath = '$targetPath'"),
                                          showSnackBar(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .unsupportedimagetype,
                                              myColors.backgroundPopupMenuHome!,
                                              myColors.textPopupMenuHome!)
                                        },
                                };
                        } catch (e) {
                        } finally {}
                      }
                    }
                  },
                  child: Icon(
                    Icons.file_download_outlined,
                    size: 8.w,
                  ),
                ),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 12.h,
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
                              textAlign: TextAlign.center,
                              controller: titleController,
                              maxLines: null,
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
                                    color: myColors.textAddAndEditRecipe,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          myColors.errorBorderAddAndEditRecipe!,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
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
                              controller: ingredientController,
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
                                  AppLocalizations.of(context)!.ingredients,
                                  style: TextStyle(
                                      color: myColors.textAddAndEditRecipe,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          myColors.errorBorderAddAndEditRecipe!,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
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
                              controller: recipeController,
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
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          myColors.errorBorderAddAndEditRecipe!,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
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
                                labelText:
                                    AppLocalizations.of(context)!.chooserecipe,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: myColors.borderAddAndEditRecipe!,
                                      width: selectedValue != null ? 2 : 1.0),
                                  borderRadius: BorderRadius.circular(30.w),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.w),
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
                                            Radius.circular(30.w),
                                          ),
                                        ),
                                        child: RadioListTile<String>(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          visualDensity: VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          dense: true,
                                          activeColor: myColors
                                              .radioListTileAddAndEditRecipe,
                                          value: 'food',
                                          groupValue: selectedValue,
                                          title: Text(
                                            AppLocalizations.of(context)!.meals,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  myColors.textAddAndEditRecipe,
                                            ),
                                          ),
                                          toggleable: true,
                                          onChanged: (value) async {
                                            int? count = Sqflite.firstIntValue(
                                                await sqlDb.reaAlldData(
                                                    "SELECT COUNT(*) FROM Cooking WHERE type = 'food'"));
                                            Recipes.initialItem = count! + 1;

                                            setState(
                                              () {
                                                value != null
                                                    ? {
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
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.w),
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
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          visualDensity: VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          dense: true,
                                          activeColor: myColors
                                              .radioListTileAddAndEditRecipe,
                                          value: 'sweets',
                                          groupValue: selectedValue,
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .desserts,
                                            softWrap: false,
                                            //textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  myColors.textAddAndEditRecipe,
                                            ),
                                          ),
                                          toggleable: true,
                                          onChanged: (value) async {
                                            int? count = Sqflite.firstIntValue(
                                                await sqlDb.reaAlldData(
                                                    "SELECT COUNT(*) FROM Cooking WHERE type = 'sweets'"));
                                            Recipes.initialItem = count! + 1;
                                            setState(
                                              () {
                                                value != null
                                                    ? {
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
                                              },
                                            );
                                          },
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
                                //backgroundColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                //****Unfocus TextFieald ***********************************//
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                !currentFocus.hasPrimaryFocus
                                    ? currentFocus.unfocus()
                                    : null;
                                //************************************************************/

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        Color.fromARGB(22, 0, 0, 0),
                                    scrollable: true,
                                    insetPadding: EdgeInsets
                                        .zero, //To avoid the error "A RenderFlex overflowed by 24 pixels on the right."
                                    iconPadding: EdgeInsets.only(top: 2.w),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 2.w),
                                    actionsPadding:
                                        EdgeInsets.symmetric(vertical: 2.w),
                                    icon: Icon(
                                      Icons.message_outlined,
                                      color: Colors.greenAccent[700],
                                      size: 15.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
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
                                          AppLocalizations.of(context)!
                                              .imagesource,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0),
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await pickImages(
                                                  ImageSource.camera);
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
                                                  AppLocalizations.of(context)!
                                                      .camera,
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
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0),
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await pickImages(
                                                  ImageSource.gallery);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.phone_iphone_outlined,
                                                  color: Color.fromARGB(
                                                      255, 192, 111, 81),
                                                  size: 7.w,
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .gallery,
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
                              },
                              child: Text(
                                AppLocalizations.of(context)!.addapicture,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: imagePath == null || containerImage == false
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width - 10,
                                    height: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                  )
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1.h),
                                    child: Container(
                                      child: InteractiveViewer(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: Image(
                                            image: Image.file(File(imagePath!))
                                                .image,
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
                  Padding(
                    padding: EdgeInsets.all(1.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.all(Radius.circular(30.w)),
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
                            color: myColors.appBarRecipes,
                            iconSize: 7.w,
                            onPressed: () async {
                              Recipes.initialItem = null;
                              await Navigator.of(context)
                                  .popAndPushNamed(RouteManager.homePage);
                            },
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                            ),
                            color: myColors.appBarRecipes,
                            iconSize: 7.w,
                            onPressed: () {
                              //****Unfocus TextFieald ***********************************//
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              !currentFocus.hasPrimaryFocus
                                  ? currentFocus.unfocus()
                                  : null;
                              //************************************************************/
                              showDialog(
                                context: context,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 20.h),
                                  child: AlertDialog(
                                    backgroundColor:
                                        Color.fromARGB(255, 71, 64, 64),
                                    insetPadding: EdgeInsets.zero,
                                    contentPadding: EdgeInsets.zero,
                                    scrollable: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.volume_up_rounded,
                                            color: Color.fromARGB(
                                                255, 120, 254, 2),
                                            size: 15.w,
                                          ),
                                          SizedBox(
                                            height: 2.w,
                                          ),
                                          Divider(
                                            height: 2,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: 2.w,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .voicetyping,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25.sp,
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
                                          SizedBox(
                                            height: 5.w,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo1,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo2,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                            child: Icon(
                                                          Icons.mic,
                                                          color: Colors.red,
                                                          size: 8.w,
                                                        )),
                                                        TextSpan(
                                                          text: '.',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo3,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo4,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                            child: Icon(
                                                          Icons.settings,
                                                          color: Colors.red,
                                                          size: 8.w,
                                                        )),
                                                        TextSpan(
                                                          text: '.',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo5,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .voicetypinginfo6,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
      ),
    );
  }

  pickImages(ImageSource source) async {
    try {
      //******************Picke an image*********************/
      XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      }
      setState(() {
        containerImage = true;
        imagePath = image.path;
      });

      //****************Get the image extenction***********/
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
      final imageExtention = path.extension(imagePath!);
      if (imageExtention == '.jpg' ||
          imageExtention == '.jpeg' ||
          imageExtention == '.jpe') {
        await FlutterImageCompress.compressAndGetFile(
          imagePath!, //The path of the picked image
          targetPath!, //The path where the image will be saved
          quality: 50, //The compression quality
        );

        return true;
      } else {
        File imageFile = File(imagePath!);
        File? compressimage = await FileSupport().compressImage(imageFile);
        await compressimage?.copySync(targetPath!);
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
