import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';

import 'package:intl/intl.dart';
import 'package:my_cooking_recipes/tools/sqldb.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sdk_int/sdk_int.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_scroll/text_scroll.dart';

import '../l10n/app_localizations.dart';
import '../routes/routes.dart';
import '../tools/custom_color_theme.dart';
import '../tools/load_preferences.dart';
import '../tools/custom_progress_dialog.dart';
import '../tools/mycustom_file_manager.dart';
import '../tools/mysnckbar.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  bool isSecuirityVisible = false;
  bool isBackupVisible = false;
  bool isRestoreVisible = false;
  bool isThemesVisible = false;

  CustomColorTheme? myColors;

  final ScrollController _scrollController = ScrollController();

  var _passwordController = TextEditingController();
  var _oldPasswordController = TextEditingController();
  var _newPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  SharedPreferences? _preferences;
  savePreferences(String chosenPassword) async {
    _preferences = await SharedPreferences.getInstance();
    _preferences?.setString('password', chosenPassword);
  }

  Future<String?> getPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences?.getString('password');
  }

  deletePreferences(String chosenKey) async {
    _preferences = await SharedPreferences.getInstance();
    _preferences?.remove(chosenKey);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _verificationNotifier.close();

    super.dispose();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  Future<bool> _onWillPop() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await Navigator.of(context).popAndPushNamed(RouteManager.homePage);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    myColors = Theme.of(context).extension<CustomColorTheme>()!;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          key: scaffoldKey,
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
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 14.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.h),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.w),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      _passwordController.clear();
                                      _oldPasswordController.clear();
                                      _newPasswordController.clear();
                                      final password = await getPreferences();
                                      if (password == null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            scrollable: true,
                                            icon: Icon(
                                              Icons.lock_open,
                                              color: Colors.red,
                                              size: 10.w,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      25.0),
                                            ),
                                            content: Container(
                                              width: 50.w,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Form(
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    key: formKey,
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return AppLocalizations
                                                                  .of(context)!
                                                              .cannotbeemty;
                                                        }
                                                        return null;
                                                      },
                                                      minLines: 1,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      controller:
                                                          _passwordController,
                                                      maxLength: 6,
                                                      obscuringCharacter: '*',
                                                      obscureText: true,
                                                      autofocus: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 25.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        counterStyle: TextStyle(
                                                            fontSize: 10.sp),
                                                        errorStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10.sp,
                                                        ),
                                                        label: TextScroll(
                                                          intervalSpaces: 10,
                                                          mode: TextScrollMode
                                                              .endless,
                                                          delayBefore:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          pauseBetween:
                                                              const Duration(
                                                                  milliseconds:
                                                                      100),
                                                          selectable: true,
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .enterpassword,
                                                          velocity:
                                                              const Velocity(
                                                                  pixelsPerSecond:
                                                                      Offset(20,
                                                                          0)),
                                                          style: TextStyle(
                                                            color: Colors
                                                                    .greenAccent[
                                                                700],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15.sp,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.w),
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.w),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 1.h,
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .save,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.sp,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      _passwordController.text
                                                              .trim()
                                                              .isEmpty
                                                          ? formKey
                                                              .currentState!
                                                              .validate()
                                                          : {
                                                              savePreferences(
                                                                  _passwordController
                                                                      .text
                                                                      .trim()),
                                                              _passwordController
                                                                  .clear(),
                                                              showSnackBar(
                                                                  context,
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .passwordadded,
                                                                  myColors!
                                                                      .backgroundPopupMenuRecipes!,
                                                                  myColors!
                                                                      .textPopupMenuRecipes!),
                                                              Navigator.pop(
                                                                  context),
                                                            };
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Directionality(
                                            textDirection:
                                                Directionality.of(context),
                                            child: AlertDialog(
                                              scrollable: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .editordelete,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  TextFormField(
                                                    readOnly: true,
                                                    autofocus: true,
                                                    maxLines: null,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    initialValue: AppLocalizations
                                                            .of(context)!
                                                        .modifyordeletepasswordinfo,
                                                    style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.5),
                                                    decoration: InputDecoration(
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide(),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  // Buttons centered
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      // CHANGE button
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                Directionality(
                                                              textDirection:
                                                                  Directionality
                                                                      .of(context),
                                                              child:
                                                                  AlertDialog(
                                                                scrollable:
                                                                    true,
                                                                icon: Icon(
                                                                    Icons
                                                                        .lock_reset_sharp,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 40),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                ),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Old password
                                                                    TextFormField(
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty)
                                                                          return AppLocalizations.of(context)!
                                                                              .cannotbeemty;
                                                                        if (value !=
                                                                            password)
                                                                          return AppLocalizations.of(context)!
                                                                              .wrongpassword;
                                                                        return null;
                                                                      },
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly
                                                                      ],
                                                                      controller:
                                                                          _oldPasswordController,
                                                                      maxLength:
                                                                          6,
                                                                      obscuringCharacter:
                                                                          '*',
                                                                      obscureText:
                                                                          true,
                                                                      autofocus:
                                                                          true,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize: 25
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            AppLocalizations.of(context)!.oldpassword,
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.black,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    // New password
                                                                    TextFormField(
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty)
                                                                          return AppLocalizations.of(context)!
                                                                              .cannotbeemty;
                                                                        return null;
                                                                      },
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly
                                                                      ],
                                                                      controller:
                                                                          _newPasswordController,
                                                                      maxLength:
                                                                          6,
                                                                      obscureText:
                                                                          true,
                                                                      autofocus:
                                                                          true,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize: 25
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            AppLocalizations.of(context)!.newpassword,
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.black,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    // Confirm change
                                                                    Center(
                                                                      child:
                                                                          TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (_oldPasswordController.text.trim().isEmpty ||
                                                                              _newPasswordController.text.trim().isEmpty ||
                                                                              _oldPasswordController.text.trim() != password) {
                                                                            formKey.currentState!.validate();
                                                                          } else {
                                                                            savePreferences(_newPasswordController.text.trim());
                                                                            _oldPasswordController.clear();
                                                                            _newPasswordController.clear();
                                                                            showSnackBar(
                                                                              context,
                                                                              AppLocalizations.of(context)!.passwordchanged,
                                                                              myColors!.backgroundPopupMenuRecipes!,
                                                                              myColors!.textPopupMenuRecipes!,
                                                                            );
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .change,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20.sp,
                                                                            color:
                                                                                Colors.greenAccent[700],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .change,
                                                          style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                      .greenAccent[
                                                                  700]),
                                                        ),
                                                      ),
                                                      // DELETE button
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                Directionality(
                                                              textDirection:
                                                                  Directionality
                                                                      .of(context),
                                                              child:
                                                                  AlertDialog(
                                                                scrollable:
                                                                    true,
                                                                icon: Icon(
                                                                    Icons
                                                                        .lock_rounded,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 40),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                ),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    TextFormField(
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty)
                                                                          return AppLocalizations.of(context)!
                                                                              .cannotbeemty;
                                                                        if (value !=
                                                                            password)
                                                                          return AppLocalizations.of(context)!
                                                                              .wrongpassword;
                                                                        return null;
                                                                      },
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly
                                                                      ],
                                                                      controller:
                                                                          _oldPasswordController,
                                                                      maxLength:
                                                                          6,
                                                                      obscureText:
                                                                          true,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize: 25
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            AppLocalizations.of(context)!.oldpassword,
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: Colors.black,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(),
                                                                          borderRadius:
                                                                              BorderRadius.circular(30.w),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    Center(
                                                                      child:
                                                                          TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (_oldPasswordController.text.trim() !=
                                                                              password) {
                                                                            formKey.currentState!.validate();
                                                                          } else {
                                                                            deletePreferences('password');
                                                                            _oldPasswordController.clear();
                                                                            showSnackBar(
                                                                              context,
                                                                              AppLocalizations.of(context)!.passworddeleted,
                                                                              myColors!.backgroundPopupMenuRecipes!,
                                                                              myColors!.textPopupMenuRecipes!,
                                                                            );
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)!
                                                                              .delete,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20.sp,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .delete,
                                                          style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            size: 8.w,
                                            color: myColors!.iconsSettings,
                                          ),
                                          SizedBox(
                                            width: 0.5.w,
                                          ),
                                          VerticalDivider(
                                            color: myColors!
                                                .dividersSettings, //color of divider
                                            width: 2, //width space of divider
                                            thickness:
                                                1, //thickness of divier line
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .secuirity,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                color:
                                                    myColors!.textCardSettings,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 5.w,
                                  iconSize: 10.w,
                                  onPressed: () {
                                    setState(() {
                                      isSecuirityVisible
                                          ? isSecuirityVisible = false
                                          : isSecuirityVisible = true;
                                    });
                                  },
                                  icon: Icon(
                                    isSecuirityVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: myColors!.arrowsSettings,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.w),
                      isSecuirityVisible
                          ? Container(
                              padding: EdgeInsets.all(1.h),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      myColors!.backgroundContainerSettings,
                                  labelStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: myColors!.labelContainerSettings,
                                  ),
                                  isDense: true,
                                  labelText:
                                      AppLocalizations.of(context)!.password,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: myColors!.borderContainerSettings!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Text(
                                      textAlign: TextAlign.justify,
                                      AppLocalizations.of(context)!
                                          .passwordinfo,
                                      style: TextStyle(
                                        color: myColors!.textContainerSettings,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        height: 1.5,
                                      )),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.h),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          child: ListTile(
                            title: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.w),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    String selectedValue =
                                        Localizations.localeOf(context)
                                            .toString();

                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter state) {
                                        return Container(
                                          margin: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait
                                              ? EdgeInsets.only(
                                                  bottom: 10.w, //15,
                                                  right: 20.w, //60,
                                                  left: 20.w, //60,
                                                )
                                              : EdgeInsets.only(
                                                  bottom: 3.w, //10,
                                                  right: 45.w, //130,
                                                  left: 45.w, //130,
                                                ),
                                          child: InputDecorator(
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 2.h),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    RadioListTile<String>(
                                                      dense: true,
                                                      activeColor: myColors!
                                                          .radioListTileBottomSheet,
                                                      value: 'ar',
                                                      groupValue: selectedValue,
                                                      title: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .arabiclanguage,
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          color: myColors!
                                                              .textBottomSheet,
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        state(() {
                                                          selectedValue =
                                                              value!;
                                                          context
                                                              .read<
                                                                  LoadPreferences>()
                                                              .changeLanguage(
                                                                  value);
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    RadioListTile<String>(
                                                        dense: true,
                                                        activeColor: myColors!
                                                            .radioListTileBottomSheet,
                                                        value: 'en',
                                                        groupValue:
                                                            selectedValue,
                                                        title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .englishlanguage,
                                                          style: TextStyle(
                                                            fontSize: 18.sp,
                                                            color: myColors!
                                                                .textBottomSheet,
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          state(() {
                                                            selectedValue =
                                                                value!;
                                                            context
                                                                .read<
                                                                    LoadPreferences>()
                                                                .changeLanguage(
                                                                    value);
                                                          });
                                                        }),
                                                    SizedBox(height: 1.h),
                                                    RadioListTile<String>(
                                                      dense: true,
                                                      activeColor: myColors!
                                                          .radioListTileBottomSheet,
                                                      value: 'fr',
                                                      groupValue: selectedValue,
                                                      title: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .frenchlanguage,
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          color: myColors!
                                                              .textBottomSheet,
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        state(() {
                                                          selectedValue =
                                                              value!;
                                                          context
                                                              .read<
                                                                  LoadPreferences>()
                                                              .changeLanguage(
                                                                  value);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            decoration: InputDecoration(
                                              fillColor: myColors!
                                                  .backgroundBottomSheet,
                                              filled: true,
                                              labelStyle: TextStyle(
                                                fontSize: 20.sp,
                                                color:
                                                    myColors!.labelBottomSheet,
                                              ),
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .applanguage,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 2,
                                                    color: myColors!
                                                        .borderBottomSheet!),
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      size: 8.w,
                                      color: myColors!.iconsSettings,
                                    ),
                                    SizedBox(
                                      width: 0.5.w,
                                    ),
                                    VerticalDivider(
                                      color: myColors!
                                          .dividersSettings, //color of divider
                                      width: 2, //width space of divider
                                      thickness: 1, //thickness of divier line
                                    ),
                                    SizedBox(
                                      width: 3.w,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.applanguage,
                                      style: TextStyle(
                                        color: myColors!.textCardSettings,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.h),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.w),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (await requestStoragePermission(
                                          context)) {
                                        SqlDb sqlDb = SqlDb();
                                        List<Map> DatabaseData =
                                            await sqlDb.reaAlldData(
                                                'SELECT * FROM Cooking');
                                        if (DatabaseData.isEmpty) {
                                          showSnackBar(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .norecipetobackup,
                                              myColors!
                                                  .backgroundPopupMenuRecipes!,
                                              myColors!.textPopupMenuRecipes!);
                                        } else {
                                          final password =
                                              await getPreferences();
                                          password == null
                                              ? backupBottomSheet()
                                              : _showLockScreen(
                                                  circleUIConfig:
                                                      CircleUIConfig(
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
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 200));
                                                    backupBottomSheet();
                                                  },
                                                );
                                        }
                                      }
                                    },
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.outbox_rounded,
                                            size: 8.w,
                                            color: myColors!.iconsSettings,
                                          ),
                                          SizedBox(
                                            width: 0.5.w,
                                          ),
                                          VerticalDivider(
                                            color: myColors!
                                                .dividersSettings, //color of divider
                                            width: 2, //width space of divider
                                            thickness:
                                                1, //thickness of divier line
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .backup,
                                            style: TextStyle(
                                              color: myColors!.textCardSettings,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 5.w,
                                  iconSize: 10.w,
                                  onPressed: () {
                                    setState(() {
                                      isBackupVisible
                                          ? isBackupVisible = false
                                          : isBackupVisible = true;
                                    });
                                  },
                                  icon: Icon(
                                    isBackupVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: myColors!.arrowsSettings,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.w),
                      isBackupVisible
                          ? Container(
                              padding: EdgeInsets.all(1.h),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      myColors!.backgroundContainerSettings,
                                  labelStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: myColors!.labelContainerSettings,
                                  ),
                                  isDense: true,
                                  labelText:
                                      AppLocalizations.of(context)!.backup,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: myColors!.borderContainerSettings!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Column(
                                    children: [
                                      Text(
                                        textAlign: TextAlign.justify,
                                        AppLocalizations.of(context)!
                                            .backupinfo,
                                        style: TextStyle(
                                          color:
                                              myColors!.textContainerSettings,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      SizedBox(height: 3.w),
                                      TextScroll(
                                        intervalSpaces: 10,
                                        mode: TextScrollMode.endless,
                                        delayBefore:
                                            const Duration(milliseconds: 500),
                                        pauseBetween:
                                            const Duration(milliseconds: 100),
                                        selectable: true,
                                        '/storage/emulated/0/Documents/MyDeliciousRecipesBackups',
                                        velocity: const Velocity(
                                            pixelsPerSecond: Offset(20, 0)),
                                        style: TextStyle(
                                          color:
                                              myColors!.textContainerSettings,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.h),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.w),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (await requestStoragePermission(
                                          context)) {
                                        final password = await getPreferences();
                                        password == null
                                            ? getLocalBackup(context)
                                            : _showLockScreen(
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
                                                  getLocalBackup(context);
                                                },
                                              );
                                      }
                                    },
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.move_to_inbox_rounded,
                                            size: 8.w,
                                            color: myColors!.iconsSettings,
                                          ),
                                          SizedBox(
                                            width: 0.5.w,
                                          ),
                                          VerticalDivider(
                                            color: myColors!
                                                .dividersSettings, //color of divider
                                            width: 2, //width space of divider
                                            thickness:
                                                1, //thickness of divier line
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .restore,
                                            style: TextStyle(
                                              color: myColors!.textCardSettings,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 5.w,
                                  iconSize: 10.w,
                                  onPressed: () {
                                    setState(() {
                                      isRestoreVisible
                                          ? isRestoreVisible = false
                                          : isRestoreVisible = true;
                                    });
                                  },
                                  icon: Icon(
                                    isRestoreVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: myColors!.arrowsSettings,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.w),
                      isRestoreVisible
                          ? Container(
                              padding: EdgeInsets.all(1.h),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      myColors!.backgroundContainerSettings,
                                  labelStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: myColors!.labelContainerSettings,
                                  ),
                                  isDense: true,
                                  labelText:
                                      AppLocalizations.of(context)!.restore,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: myColors!.borderContainerSettings!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Text(
                                    textAlign: TextAlign.justify,
                                    AppLocalizations.of(context)!.restoreinfo,
                                    style: TextStyle(
                                      color: myColors!.textContainerSettings,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.h),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.w),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        isThemesVisible
                                            ? isThemesVisible = false
                                            : isThemesVisible = true;
                                      });
                                      await Future.delayed(
                                          Duration(milliseconds: 100));
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 20),
                                          curve: Curves.easeInOut);
                                    },
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.format_paint,
                                            size: 8.w,
                                            color: myColors!.iconsSettings,
                                          ),
                                          SizedBox(
                                            width: 0.5.w,
                                          ),
                                          VerticalDivider(
                                            color: myColors!
                                                .dividersSettings, //color of divider
                                            width: 2, //width space of divider
                                            thickness:
                                                1, //thickness of divier line
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .themes,
                                            style: TextStyle(
                                              color: myColors!.textCardSettings,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.w),
                      isThemesVisible
                          ? Padding(
                              padding: EdgeInsets.all(1.h),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 2,
                                padding: EdgeInsets.only(
                                  left: 8.w,
                                  right: 8.w,
                                  top: 1.h,
                                  bottom: 1.h,
                                ),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        myColors!.backgroundContainerSettings,
                                    labelStyle: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: myColors!.labelContainerSettings,
                                    ),
                                    isDense: true,
                                    labelText:
                                        AppLocalizations.of(context)!.themes,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            myColors!.borderContainerSettings!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: GridView.extent(
                                    childAspectRatio: 1 / 1.5,
                                    padding: EdgeInsets.all(3.w),
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    maxCrossAxisExtent: 200.0,
                                    children: <Widget>[
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                                  .watch<
                                                                      LoadPreferences>()
                                                                  .chosenTheme ==
                                                              0 ||
                                                          context
                                                                  .watch<
                                                                      LoadPreferences>()
                                                                  .chosenTheme ==
                                                              null
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/0.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(0);
                                        },
                                      ),
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                              .watch<
                                                                  LoadPreferences>()
                                                              .chosenTheme ==
                                                          1
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/1.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(1);
                                        },
                                      ),
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                              .watch<
                                                                  LoadPreferences>()
                                                              .chosenTheme ==
                                                          2
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/2.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(2);
                                        },
                                      ),
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                              .watch<
                                                                  LoadPreferences>()
                                                              .chosenTheme ==
                                                          3
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/3.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(3);
                                        },
                                      ),
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                              .watch<
                                                                  LoadPreferences>()
                                                              .chosenTheme ==
                                                          4
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/4.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(4);
                                        },
                                      ),
                                      InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: context
                                                              .watch<
                                                                  LoadPreferences>()
                                                              .chosenTheme ==
                                                          5
                                                      ? 5
                                                      : 0,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              child: Image.asset(
                                                'assets/images/5.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          context
                                              .read<LoadPreferences>()
                                              .changeTheme(5);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
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
                          color: myColors!.appBarRecipes,
                          iconSize: 7.w,
                          onPressed: () async {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            await Navigator.of(context)
                                .popAndPushNamed(RouteManager.homePage);
                          },
                        ),
                        Spacer(),
                        Padding(
                          padding: AppLocalizations.of(context)!
                                  .language
                                  .contains('العربية')
                              ? EdgeInsets.only(left: 2.w)
                              : EdgeInsets.only(right: 2.w),
                          child: Text(
                            AppLocalizations.of(context)!.settings,
                            style: TextStyle(
                              color: myColors!.appBarRecipes,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  //**************************************************************************/

  backupBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
            return Container(
              margin: MediaQuery.of(context).orientation == Orientation.portrait
                  ? EdgeInsets.only(bottom: 10.w, right: 18.w, left: 18.w)
                  : EdgeInsets.only(bottom: 3.w, right: 40.w, left: 40.w),
              child: InputDecorator(
                textAlignVertical: TextAlignVertical.center,
                child: Container(
                  margin: EdgeInsets.only(top: 2.h),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 2),
                              elevation: 6,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.w))),
                          child: TextScroll(
                            mode: TextScrollMode.bouncing,
                            delayBefore: const Duration(milliseconds: 500),
                            pauseBetween: const Duration(milliseconds: 100),
                            selectable: false,
                            AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? AppLocalizations.of(context)!.localstorage +
                                    '\u{1F4F1}'
                                : '\u{1F4F1}' +
                                    AppLocalizations.of(context)!.localstorage,
                            velocity:
                                const Velocity(pixelsPerSecond: Offset(20, 0)),
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: myColors!.textBottomSheet,
                              height: 1.5,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            localBackup(context);
                          },
                        ),
                        SizedBox(height: 2.h),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 2),
                              elevation: 6,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.w))),
                          child: TextScroll(
                            mode: TextScrollMode.bouncing,
                            delayBefore: const Duration(milliseconds: 500),
                            pauseBetween: const Duration(milliseconds: 100),
                            selectable: false,
                            AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? AppLocalizations.of(context)!.cloudstorage +
                                    ' \u{2601}'
                                : '\u{2601} ' +
                                    AppLocalizations.of(context)!.cloudstorage,
                            velocity:
                                const Velocity(pixelsPerSecond: Offset(20, 0)),
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: myColors!.textBottomSheet,
                              height: 1.5,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            externalBackup();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                decoration: InputDecoration(
                  fillColor: myColors!.backgroundBottomSheet,
                  filled: true,
                  labelStyle: TextStyle(
                    fontSize: 20.sp,
                    color: myColors!.labelBottomSheet,
                  ),
                  labelText: AppLocalizations.of(context)!.backup,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: myColors!.borderBottomSheet!, width: 2),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  localBackup(BuildContext context) async {
    try {
      if (!mounted) return;
      String progressDialogBackupInitialMessage =
          AppLocalizations.of(context)!.copyingpleasewait;
      String progressDialogBackupFinalMessage =
          AppLocalizations.of(context)!.backupcompletedsuccessfully;

      final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Download,
        isDismissible: false,
        showLogs: true,
      );

      updateToInitialProgressDialog(pr);

      pr.style(
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        message: progressDialogBackupInitialMessage,
      );
      await pr.show();

      String documentsDirectoryPath =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOCUMENTS);

      await Directory('$documentsDirectoryPath/MyDeliciousRecipesBackups')
              .exists()
          ? null
          : await Directory('$documentsDirectoryPath/MyDeliciousRecipesBackups')
              .create(recursive: true);

      final databaseDirectory = Directory(await getDatabasesPath());

      String currentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
      String currentTime = DateFormat("HH-mm-ss").format(DateTime.now());
      var zipFile = File(
          '$documentsDirectoryPath/MyDeliciousRecipesBackups/${currentDate}_${currentTime}.MyDeliciousRecipesBackup');

      await ZipFile.createFromDirectory(
        sourceDir: databaseDirectory,
        zipFile: zipFile,
        recurseSubDirs: true,
        onZipping: (fileName, isDirectory, progress) {
          pr.update(
            progress: progress,
            progressWidget: Center(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    backgroundColor: const Color.fromARGB(192, 148, 134, 29),
                    valueColor: const AlwaysStoppedAnimation(
                        Color.fromARGB(255, 9, 249, 0)),
                    strokeWidth: 2.w,
                  ),
                  Center(
                    child: Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          progress == 100.0
              ? {
                  pr.update(message: progressDialogBackupFinalMessage),
                  waitForSeconds().then((value) => {
                        pr.hide(),
                      }),
                }
              : null;

          return ZipFileOperation.includeItem;
        },
      );
    } catch (e) {}
  }

  externalBackup() async {
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
              color: myColors!.appBarSettings,
            ),
          ),
        );
      },
      context: context,
    );

    //***Copy Backup to cahce directory, then share it by using share_plus package***/

    String cacheDirectoryPath = (await getTemporaryDirectory()).path;

    final databaseDirectory = Directory(await getDatabasesPath());

    try {
      String currentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
      String currentTime = DateFormat("HH-mm-ss").format(DateTime.now());

      var zipFile = File(
          '$cacheDirectoryPath/${currentDate}_${currentTime}.MyDeliciousRecipesBackup');

      await ZipFile.createFromDirectory(
        sourceDir: databaseDirectory,
        zipFile: zipFile,
        recurseSubDirs: true,
      );

      await Share.shareXFiles(
        [
          XFile(
              '$cacheDirectoryPath/${currentDate}_${currentTime}.MyDeliciousRecipesBackup')
        ],
      ).then(
        (value) {
          Navigator.pop(context); //Dismiss the CircularProgressIndicator
        },
      );
      await File(
              '$cacheDirectoryPath/${currentDate}_${currentTime}.MyDeliciousRecipesBackup')
          .delete();
    } catch (e) {}
    //***********************************************************************************************/
  }
}

Future waitForSeconds() async {
  await Future.delayed(Duration(milliseconds: 1200));
}

getLocalBackup(BuildContext context) async {
  final initialDirectoryPath = await getBackupDirectoryPath();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CustomFileManager(
        initialDirectoryPath: initialDirectoryPath,
      ),
    ),
  );
}

Future<bool> requestStoragePermission(BuildContext context) async {
  //This permission is necessary for FileManager in order to shwo Files
  //Without this permission, only Folders are visible.
  //Manage_External_Storage permission is used to show all files (Pdf, txt, custom extension, etc), this permission is required for some Android devices
  int sdkVersion = await SDKInt.currentSDKVersion;
  PermissionStatus status;

  sdkVersion >= 30
      ? status = await Permission.manageExternalStorage.request()
      : status = await Permission.storage.request();

  if (status == PermissionStatus.denied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.amberAccent,
                onPressed: () {},
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 35,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 10),
              Divider(
                height: 2,
                color: Colors.white,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.requiredpermission,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Divider(
                height: 2,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(AppLocalizations.of(context)!.grantpermission),
                onPressed: () async {
                  Navigator.pop(context);
                  sdkVersion >= 30
                      ? status =
                          await Permission.manageExternalStorage.request()
                      : status = await Permission.storage.request();
                },
              ),
            ],
          ),
        ),
      ),
    );
  } else if (status == PermissionStatus.permanentlyDenied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.amberAccent,
                onPressed: () {},
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 35,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Divider(
                height: 2,
                color: Colors.white,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.grantpermissionfromappsettings,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Divider(
                height: 2,
                color: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.grantpermissionmethod,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(AppLocalizations.of(context)!.appsettings),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  return status.isGranted;
}

Future<String> getBackupDirectoryPath() async {
  String documentsPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS);
  var _directory = await Directory('$documentsPath/MyDeliciousRecipesBackups');

  if (await _directory.exists()) {
    //if the folder already exists return path
    return _directory.path;
  } else {
    //if the folder doesn't exist, create the folder and then return its path
    final Directory _newDirectory = await _directory.create(recursive: true);
    return _newDirectory.path;
  }
}

updateToInitialProgressDialog(ProgressDialog progressDialog) {
  //******To restart the initial sate of the ProgressDialog pr****/
  progressDialog.update(
    progress: 0.0,
    progressWidget: Center(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.0,
            backgroundColor: Color.fromARGB(192, 148, 134, 29),
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 9, 249, 0)),
            strokeWidth: 2.w,
          ),
          Center(
              child: Text(
            '0%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          )),
        ],
      ),
    ),
  );
  //********************************************************* */
}
