import 'dart:io';

import 'package:circular_menu/circular_menu.dart';
import 'package:confetti/confetti.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:im_stepper/stepper.dart';
import 'package:my_cooking_recipes/pages/add_recipes.dart';
import 'package:my_cooking_recipes/tools/decorated_container.dart';
import 'package:my_cooking_recipes/tools/sqldb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';

import '../custom_icons_icons.dart';
import '../l10n/app_localizations.dart';
import '../routes/routes.dart';
import '../tools/custom_color_theme.dart';
import '../tools/load_preferences.dart';
import '../tools/mysnckbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static bool setStateHomePage = false;
  static bool searchIndex = false;
  static bool launchConfetti = false;
  static String? savedText;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController? _myTabController;
  var _searchController = TextEditingController();

  //**To join the Tab bar to the bottom navigation bar**/
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _selectedIndex = 1;
  int _prevIndex = 1;
  //***************************************************/

  int _recipesNumber = 0;

  bool _showRecipesNumber = false;

  @override
  void initState() {
    AddRecipes.tabIndex == 2
        ? {
            _myTabController = TabController(length: 2, vsync: this),
            _currentIndex = 0,
          }
        : {
            _myTabController = TabController(
                length: 2, vsync: this, initialIndex: AddRecipes.tabIndex),
            AddRecipes.tabIndex == 0 ? _currentIndex = 0 : _currentIndex = 2,
          };
    HomePage.setStateHomePage
        ? setState(() {
            _myTabController = TabController(length: 2, vsync: this);
            HomePage.setStateHomePage = false;
            _currentIndex = 0;
          })
        : null;
    //********To join the Tab bar to the bottom navigation bar***********/
    _myTabController!.animation?.addListener(
      () {
        if (!_tapIsBeingExecuted &&
            !_swipeIsInProgress &&
            (_myTabController!.offset >= 0.5 ||
                _myTabController!.offset <= -0.5)) {
          // detects if a swipe is being executed. limits set to 0.5 and -0.5 to make sure the swipe gesture triggered
          // log("swipe  detected");
          int newIndex = _myTabController!.offset > 0
              ? _myTabController!.index + 1
              : _myTabController!.index - 1;
          _swipeIsInProgress = true;
          _prevIndex = _selectedIndex;
          setState(() {
            _selectedIndex = newIndex;
            newIndex == 0 ? _currentIndex = 0 : _currentIndex = 2;
            hideFloatingActionButton = true;
            _myTabController!.index == 0
                ? _myTabController!.index = 1
                : _myTabController!.index = 0; //********************** */
          });
        } else {
          if (!_tapIsBeingExecuted &&
              _swipeIsInProgress &&
              ((_myTabController!.offset < 0.5 &&
                      _myTabController!.offset > 0) ||
                  (_myTabController!.offset > -0.5 &&
                      _myTabController!.offset < 0))) {
            // detects if a swipe is being reversed. the
            //log("swipe reverse detected");
            _swipeIsInProgress = false;
            setState(() {
              _selectedIndex = _prevIndex;
              _prevIndex == 0 ? _currentIndex = 0 : _currentIndex = 2;
              hideFloatingActionButton = true;
            });
          }
        }
      },
    );
    _myTabController!.addListener(
      () async {
        //**************Get the number of recipes***************/
        String recipeType = '';
        _currentIndex == 0
            ? recipeType = 'food'
            : _currentIndex == 2
                ? recipeType = 'sweets'
                : null;
        List<Map> sqlData = await _sqlDb.readData(
            table: 'Cooking',
            orderby: 'id DESC',
            where: 'type LIKE ?',
            whereArgs: [recipeType]);

        //******************************************************/
        _swipeIsInProgress = false;
        setState(() {
          _recipesNumber = sqlData.length;
          _showRecipesNumber = true;

          _selectedIndex = _myTabController!.index;
          _myTabController!.index == 0 ? _currentIndex = 0 : _currentIndex = 2;
          hideFloatingActionButton = true;
        });
        if (_tapIsBeingExecuted == true) {
          _tapIsBeingExecuted = false;
        } else {
          if (_myTabController!.indexIsChanging) {
            // this is only true when the tab is changed via tap
            _tapIsBeingExecuted = true;
          }
        }
      },
    );
    //*******************************************************************/

    HomePage.launchConfetti
        ? {
            _animationController.play(),
            Future.delayed(const Duration(milliseconds: 500), () {
              _animationController.stop();
            }),
            HomePage.launchConfetti = false,
          }
        : null;
    getRecipesNumber();
    _showRecipesNumber = true;
    super.initState();
  }

  final _animationController = ConfettiController();

  @override
  void dispose() {
    _myTabController!.dispose();
    _animationController.dispose();
    super.dispose();
  }

  int? _currentIndex;

  SqlDb _sqlDb = SqlDb();

  bool hideFloatingActionButton = true;

  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  final circularMenuKey = GlobalKey<CircularMenuState>();

  SharedPreferences? _preferences;

  savePreferences(String stringToSearch) async {
    _preferences = await SharedPreferences.getInstance();
    _preferences?.setString('savedText', stringToSearch);
  }

  CustomColorTheme? myColors;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(71, 0, 0, 0),
            insetPadding: EdgeInsets
                .zero, //To avoid the error "A RenderFlex overflowed by 24 pixels on the right."
            iconPadding: EdgeInsets.only(top: 2.w),
            contentPadding: EdgeInsets.symmetric(vertical: 2.w),
            actionsPadding: EdgeInsets.symmetric(vertical: 2.w),
            scrollable: true,
            icon: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.exitmessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      AppLocalizations.of(context)!.no,
                      style: TextStyle(fontSize: 18.sp, color: Colors.green),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  TextButton(
                    onPressed: () => {
                      Navigator.of(context).pop(true),
                      _deleteCacheFiles(), //Delete the cache of the App
                    },
                    child: Text(
                      AppLocalizations.of(context)!.yes,
                      style: TextStyle(fontSize: 18.sp, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )) ??
        false;
  }

  //****************************************************************/
  //This function prevent to get the 0 value from
  //MediaQuery.of(context).size on startup
  Future<double?> whenNotZero(Stream<double> source) async {
    await for (double value in source) {
      if (value > 0) {
        return value;
      }
    }
    return null;
    // stream exited without a true value, maybe return an exception.
  }
  //****************************************************************/

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    myColors = Theme.of(context).extension<CustomColorTheme>()!;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          toolbarHeight: 18.h,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          flexibleSpace: Image(
            image: _myTabController!.index == 0
                ? AssetImage('assets/images/food.png')
                : AssetImage('assets/images/sweet.png'),
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width,
          ),
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: Container(
          height: 10.h,
        ), // To show the snackbar above the bottom navigation bar of the nested Scaffold.
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover),
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                // Nested Scaffold in order to allow the showSnackBar to apear.
                extendBodyBehindAppBar: true,
                extendBody: true,
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme:
                        IconThemeData(color: myColors!.iconsPopupMenuHome),
                  ),
                  child: FutureBuilder(
                      future: whenNotZero(
                        Stream<double>.periodic(
                            const Duration(milliseconds: 50),
                            (x) => MediaQuery.of(context).size.height),
                      ),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data! > 0) {
                            return CurvedNavigationBar(
                              animationDuration: Duration(milliseconds: 300),
                              key: navigationKey,
                              color: myColors!.backgroundPopupMenuHome!,
                              backgroundColor: Colors.transparent,
                              items: [
                                Container(
                                  height: _currentIndex == 0
                                      ? MediaQuery.of(context).size.height *
                                          0.06
                                      : MediaQuery.of(context).size.height *
                                          0.03,
                                  width:
                                      MediaQuery.of(context).size.height * 0.06,
                                  child: Icon(
                                    CustomIcons.spices_icon,
                                    size: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                  child: Icon(
                                    Icons.home,
                                    size: _currentIndex == 1
                                        ? MediaQuery.of(context).size.height *
                                            0.01
                                        : MediaQuery.of(context).size.height *
                                            0.04,
                                  ),
                                ),
                                Container(
                                  height: _currentIndex == 2
                                      ? MediaQuery.of(context).size.height *
                                          0.06
                                      : MediaQuery.of(context).size.height *
                                          0.03,
                                  width:
                                      MediaQuery.of(context).size.height * 0.06,
                                  child: Icon(
                                    CustomIcons.cake_cup_icon,
                                    size: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                ),
                              ],
                              onTap: (currentIndex) async {
                                //**************Get the number of recipes***************/
                                String recipeType = '';
                                currentIndex == 0
                                    ? recipeType = 'food'
                                    : currentIndex == 2
                                        ? recipeType = 'sweets'
                                        : null;
                                List<Map> sqlData = await _sqlDb.readData(
                                    table: 'Cooking',
                                    orderby: 'id DESC',
                                    where: 'type LIKE ?',
                                    whereArgs: [recipeType]);

                                //******************************************************/
                                setState(() {
                                  _currentIndex = currentIndex;
                                  _recipesNumber = sqlData.length;
                                });
                                _currentIndex == 2
                                    ? _myTabController!.animateTo(1)
                                    : _currentIndex == 0
                                        ? _myTabController!.animateTo(0)
                                        : null;

                                currentIndex == 1
                                    ? {
                                        setState(() {
                                          hideFloatingActionButton = false;
                                          _showRecipesNumber = false;
                                        }),
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          circularMenuKey.currentState!
                                              .forwardAnimation();
                                        }),
                                      }
                                    : {
                                        setState(() {
                                          hideFloatingActionButton = true;
                                          _showRecipesNumber = true;
                                        })
                                      };
                              },
                              height: 15.w > 75 ? 75 : 15.w,
                              index: _currentIndex!,
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      }),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: hideFloatingActionButton
                    ? Container()
                    : CircularMenu(
                        toggleButtonSize: 5.h,
                        radius: 30.w,
                        toggleButtonOnPressed: () async {
                          setState(() {
                            hideFloatingActionButton = true;
                            _currentIndex =
                                _myTabController!.index == 0 ? 0 : 2;
                            _showRecipesNumber = true;
                          });
                          getRecipesNumber();
                        },
                        key: circularMenuKey,
                        toggleButtonAnimatedIconData: AnimatedIcons.home_menu,
                        alignment: Alignment.bottomCenter,
                        toggleButtonColor: Colors.pink,
                        items: [
                          CircularMenuItem(
                              icon: CustomIcons.sliders,
                              color: Colors.green,
                              iconSize: 4.h,
                              onTap: () async {
                                List<Map> sqlData = await _sqlDb.readData(
                                    table: 'Cooking',
                                    orderby: 'id DESC',
                                    where: 'type = ?',
                                    whereArgs: [
                                      _myTabController!.index == 0
                                          ? 'food'
                                          : 'sweets'
                                    ]);

                                if (sqlData.length >= 2) {
                                  setState(() {
                                    _myTabController!.index == 0
                                        ? _currentIndex = 0
                                        : _currentIndex = 2;
                                    hideFloatingActionButton = true;
                                  });
                                  bottomSheet();
                                } else {
                                  showSnackBar(
                                      context,
                                      '${AppLocalizations.of(context)!.recipesnumber}',
                                      myColors!.backgroundPopupMenuHome!,
                                      myColors!.textPopupMenuHome!);
                                  setState(() {
                                    _currentIndex =
                                        _myTabController!.index == 0 ? 0 : 2;
                                    _showRecipesNumber = true;
                                    hideFloatingActionButton = true;
                                  });
                                  getRecipesNumber();
                                }
                              }),
                          CircularMenuItem(
                            icon: CustomIcons.search,
                            color: Colors.blue,
                            iconSize: 4.h,
                            onTap: () {
                              circularMenuKey.currentState!.reverseAnimation();

                              _searchController.clear();
                              setState(() {
                                _currentIndex =
                                    _myTabController!.index == 0 ? 0 : 2;
                                hideFloatingActionButton = true;
                                AddRecipes.tabIndex = _myTabController!.index;
                              });

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Directionality(
                                  textDirection: Directionality.of(context),
                                  child: AlertDialog(
                                    backgroundColor: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Search TextField
                                          Form(
                                            key: formKey,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2.h),
                                              child: TextFormField(
                                                controller: _searchController,
                                                autofocus: true,
                                                style:
                                                    TextStyle(fontSize: 20.sp),
                                                decoration: InputDecoration(
                                                  label: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .searchfor,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.sp),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  errorStyle:
                                                      TextStyle(fontSize: 8.sp),
                                                ),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return AppLocalizations.of(
                                                            context)!
                                                        .cannotbeemty;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          // Search Button centered
                                          TextButton.icon(
                                            onPressed: () async {
                                              if (_searchController
                                                  .text.isEmpty) {
                                                formKey.currentState!
                                                    .validate();
                                                return;
                                              }

                                              List<Map> sqlData =
                                                  await _sqlDb.readData(
                                                table: 'Cooking',
                                                orderby: 'id DESC',
                                                where: 'title LIKE ?',
                                                whereArgs: [
                                                  '%${_searchController.text.trim()}%'
                                                ],
                                              );

                                              if (sqlData.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      Directionality(
                                                    textDirection:
                                                        Directionality.of(
                                                            context),
                                                    child: AlertDialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      scrollable: true,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .warning_amber_rounded,
                                                              color: Colors.red,
                                                              size: 10.h),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .noresults,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteCacheFiles();
                                                            },
                                                            icon: Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                        .greenAccent[
                                                                    700],
                                                                size: 6.h),
                                                            label: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .search,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      18.sp,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                HomePage.searchIndex = true;
                                                savePreferences(
                                                    _searchController.text
                                                        .trim());
                                                await SharedPreferences
                                                    .getInstance();
                                                HomePage.savedText =
                                                    _preferences!
                                                        .getString('savedText');

                                                showSnackBar(
                                                  context,
                                                  '${AppLocalizations.of(context)!.numberofresults} ${sqlData.length}',
                                                  myColors!
                                                      .backgroundPopupMenuHome!,
                                                  myColors!.textPopupMenuHome!,
                                                );

                                                Navigator.pop(
                                                    context); // close dialog
                                                await Navigator.of(context)
                                                    .pushReplacementNamed(
                                                  RouteManager.searchPage,
                                                );
                                              }
                                            },
                                            icon: Icon(Icons.search_sharp,
                                                color: Colors.red, size: 4.h),
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .search,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ).whenComplete(() async {
                                getRecipesNumber();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                setState(() {
                                  _showRecipesNumber = true;
                                });
                              });
                            },
                          ),
                          CircularMenuItem(
                              icon: CustomIcons.food,
                              color: Colors.black,
                              iconSize: 4.h,
                              onTap: () {
                                AddRecipes.tabIndex = _myTabController!.index;

                                Navigator.of(context).pushReplacementNamed(
                                    RouteManager.addRecipes);
                              }),
                          CircularMenuItem(
                              icon: CustomIcons.cog,
                              color: Colors.brown,
                              iconSize: 4.h,
                              onTap: () {
                                circularMenuKey.currentState!
                                    .reverseAnimation();
                                Navigator.of(context).pushReplacementNamed(
                                    RouteManager.mySettings);
                              }),
                          CircularMenuItem(
                            icon: CustomIcons.info,
                            color: Colors.purple,
                            iconSize: 4.h,
                            onTap: () {
                              setState(() {
                                _myTabController!.index == 0
                                    ? _currentIndex = 0
                                    : _currentIndex = 2;
                                hideFloatingActionButton = true;
                              });

                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  titlePadding: EdgeInsets.only(top: 2.h),
                                  title: Center(
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/icons/DessertIcon.png',
                                        width: 24.w,
                                        height: 24.w,
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          readOnly: true,
                                          autofocus: true,
                                          maxLines: null,
                                          textAlign: TextAlign.justify,
                                          initialValue:
                                              AppLocalizations.of(context)!
                                                  .apppurpose,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                          ),
                                          decoration: InputDecoration(
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .deliciousrecipes,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 6, 6),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        TextFormField(
                                          readOnly: true,
                                          autofocus: true,
                                          maxLines: null,
                                          textAlign: TextAlign.justify,
                                          initialValue:
                                              '''${AppLocalizations.of(context)!.contactemail}\ndjmslimani@gmail.com''',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                          ),
                                          decoration: InputDecoration(
                                            label: Text(
                                              AppLocalizations.of(context)!
                                                  .contact,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 6, 6),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ).whenComplete(() async {
                                getRecipesNumber();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                setState(() {
                                  _showRecipesNumber = true;
                                });
                              });
                            },
                          )
                        ],
                      ),
                body: TabBarView(
                  controller: _myTabController,
                  children: [
                    DecoratedContainer(
                      myWhere: 'type = ?',
                      myWhereArgs: ['food'],
                    ),
                    DecoratedContainer(
                      myWhere: 'type = ?',
                      myWhereArgs: ['sweets'],
                    ),
                  ],
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _animationController,
              numberOfParticles: 200,
              minBlastForce: 10,
              maxBlastForce: 300,
              emissionFrequency: 0.05,
              blastDirectionality: BlastDirectionality.explosive,
              createParticlePath: (size) {
                final path = Path();

                path.addOval(Rect.fromCircle(
                  center: Offset.zero,
                  radius: 3,
                ));
                return path;
              },
            ),
            Positioned(
              left: AppLocalizations.of(context)!.language.contains('العربية')
                  ? _currentIndex == 2
                      ? 0
                      : null
                  : _currentIndex == 2
                      ? null
                      : 0,
              right: AppLocalizations.of(context)!.language.contains('العربية')
                  ? _currentIndex == 2
                      ? null
                      : 0
                  : _currentIndex == 2
                      ? 0
                      : null,
              bottom: MediaQuery.of(context).size.height / 2,
              child: _showRecipesNumber
                  ? Container(
                      width: '${_recipesNumber}'.length <= 4 ? null : 20.w,
                      padding: EdgeInsets.only(
                        top: 1.w,
                        bottom: 1.w,
                        left: AppLocalizations.of(context)!
                                .language
                                .contains('العربية')
                            ? _currentIndex == 2
                                ? 0.5.w
                                : 2.w
                            : _currentIndex == 2
                                ? 2.w
                                : 0.5.w,
                        right: AppLocalizations.of(context)!
                                .language
                                .contains('العربية')
                            ? _currentIndex == 2
                                ? 2.w
                                : 0.5.w
                            : _currentIndex == 2
                                ? 0.5.w
                                : 2.w,
                      ),
                      child: Center(
                        child: '${_recipesNumber}'.length <= 4
                            ? Text(
                                '${_recipesNumber}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: myColors!.iconsPopupMenuHome,
                                ),
                              )
                            : TextScroll(
                                textDirection: _currentIndex == 0
                                    ? TextDirection.ltr
                                    : _currentIndex == 2
                                        ? TextDirection.rtl
                                        : TextDirection.rtl,
                                intervalSpaces: 3.w.toInt(),
                                mode: TextScrollMode.endless,
                                delayBefore: const Duration(milliseconds: 500),
                                pauseBetween: const Duration(milliseconds: 100),
                                selectable: true,
                                '${_recipesNumber}',
                                velocity: const Velocity(
                                    pixelsPerSecond: Offset(20, 0)),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: myColors!.iconsPopupMenuHome,
                                ),
                              ),
                      ),
                      decoration: BoxDecoration(
                        color: myColors!.backgroundPopupMenuHome!,
                        borderRadius: BorderRadius.only(
                          topRight: AppLocalizations.of(context)!
                                  .language
                                  .contains('العربية')
                              ? _currentIndex == 2
                                  ? Radius.circular(30.w)
                                  : Radius.circular(0)
                              : _currentIndex == 2
                                  ? Radius.circular(0)
                                  : Radius.circular(30.w),
                          bottomRight: AppLocalizations.of(context)!
                                  .language
                                  .contains('العربية')
                              ? _currentIndex == 2
                                  ? Radius.circular(30.w)
                                  : Radius.circular(0)
                              : _currentIndex == 2
                                  ? Radius.circular(0)
                                  : Radius.circular(30.w),
                          topLeft: AppLocalizations.of(context)!
                                  .language
                                  .contains('العربية')
                              ? _currentIndex == 2
                                  ? Radius.circular(0)
                                  : Radius.circular(30.w)
                              : _currentIndex == 2
                                  ? Radius.circular(30.w)
                                  : Radius.circular(0),
                          bottomLeft: AppLocalizations.of(context)!
                                  .language
                                  .contains('العربية')
                              ? _currentIndex == 2
                                  ? Radius.circular(0)
                                  : Radius.circular(30.w)
                              : _currentIndex == 2
                                  ? Radius.circular(30.w)
                                  : Radius.circular(0),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  //********Delete the cache************/
  Future<void> _deleteCacheFiles() async {
    var appDir = (await getTemporaryDirectory()).path;
    await Directory(appDir).delete(recursive: true);
  }
  //************************************/

  bottomSheet() {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
            return Container(
              margin: MediaQuery.of(context).orientation == Orientation.portrait
                  ? EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 15,
                      right: 25,
                      left: 25,
                    )
                  : EdgeInsets.only(
                      bottom: 15,
                      right: 60,
                      left: 60,
                    ),
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          elevation: 6,
                          backgroundColor: Color.fromARGB(186, 206, 5, 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: Container(
                          width: 175,
                          child: NumberStepper(
                            previousButtonIcon: AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewVrerticalChanging ==
                                        0.000000001
                                    ? Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewVrerticalChanging ==
                                        0.000000001
                                    ? Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                            nextButtonIcon: AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewVrerticalChanging ==
                                        0.009999999
                                    ? Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewVrerticalChanging ==
                                        0.009999999
                                    ? Icon(
                                        Icons.arrow_circle_right,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                            numbers: const [
                              0,
                              1,
                              2,
                              3,
                              4,
                              5,
                              6,
                              7,
                              8,
                              9,
                              10,
                            ],
                            activeStep: context
                                        .watch<LoadPreferences>()
                                        .listWheelScrollViewVrerticalChanging ==
                                    0.000000001
                                ? 0
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewVrerticalChanging ==
                                        0.0001
                                    ? 1
                                    : context
                                                .watch<LoadPreferences>()
                                                .listWheelScrollViewVrerticalChanging ==
                                            0.0003
                                        ? 2
                                        : context
                                                    .watch<LoadPreferences>()
                                                    .listWheelScrollViewVrerticalChanging ==
                                                0.0004
                                            ? 3
                                            : context
                                                        .watch<
                                                            LoadPreferences>()
                                                        .listWheelScrollViewVrerticalChanging ==
                                                    0.003
                                                ? 4
                                                : context
                                                            .watch<
                                                                LoadPreferences>()
                                                            .listWheelScrollViewVrerticalChanging ==
                                                        0.004
                                                    ? 5
                                                    : context
                                                                .watch<
                                                                    LoadPreferences>()
                                                                .listWheelScrollViewVrerticalChanging ==
                                                            0.005
                                                        ? 6
                                                        : context
                                                                    .watch<
                                                                        LoadPreferences>()
                                                                    .listWheelScrollViewVrerticalChanging ==
                                                                0.006
                                                            ? 7
                                                            : context.watch<LoadPreferences>().listWheelScrollViewVrerticalChanging ==
                                                                    0.007
                                                                ? 8
                                                                : context.watch<LoadPreferences>().listWheelScrollViewVrerticalChanging ==
                                                                        0.008
                                                                    ? 9
                                                                    : context.watch<LoadPreferences>().listWheelScrollViewVrerticalChanging ==
                                                                            0.009999999
                                                                        ? 10
                                                                        : 0,
                            lineColor: Colors.white,
                            activeStepBorderColor: Colors.amber,
                            activeStepBorderPadding: 3.0,
                            activeStepBorderWidth: 5.0,
                            lineDotRadius: 2.0,
                            stepReachedAnimationEffect: Curves.elasticOut,
                            onStepReached: (index) async {
                              switch (index) {
                                case 0:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.000000001);
                                  break;
                                case 1:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.0001);
                                  break;
                                case 2:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.0003);
                                  break;
                                case 3:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.0004);
                                  break;
                                case 4:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.003);
                                  break;
                                case 5:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.004);
                                  break;
                                case 6:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.005);
                                  break;
                                case 7:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.006);
                                  break;
                                case 8:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.007);
                                  break;
                                case 9:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.008);
                                  break;
                                case 10:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .verticalChangingOfListWheelScrollView(
                                          0.009999999);
                                  break;
                              }
                            },
                            stepReachedAnimationDuration:
                                const Duration(microseconds: 1),
                          ),
                        ),
                        onPressed: () async {},
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            elevation: 6,
                            backgroundColor: Color.fromARGB(186, 206, 5, 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40))),
                        child: Container(
                          width: 175,
                          child: NumberStepper(
                            previousButtonIcon: AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewHorizontalChanging ==
                                        -2
                                    ? Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewHorizontalChanging ==
                                        -2
                                    ? Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                            nextButtonIcon: AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewHorizontalChanging ==
                                        2
                                    ? Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewHorizontalChanging ==
                                        2
                                    ? Icon(
                                        Icons.arrow_circle_right,
                                        color: Colors.transparent,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                            numbers: const [
                              -5,
                              -4,
                              -3,
                              -2,
                              -1,
                              0,
                              1,
                              2,
                              3,
                              4,
                              5,
                            ],
                            activeStep: context
                                        .watch<LoadPreferences>()
                                        .listWheelScrollViewHorizontalChanging ==
                                    -2
                                ? 0
                                : context
                                            .watch<LoadPreferences>()
                                            .listWheelScrollViewHorizontalChanging ==
                                        -1.7
                                    ? 1
                                    : context
                                                .watch<LoadPreferences>()
                                                .listWheelScrollViewHorizontalChanging ==
                                            -1.4
                                        ? 2
                                        : context
                                                    .watch<LoadPreferences>()
                                                    .listWheelScrollViewHorizontalChanging ==
                                                -1.1
                                            ? 3
                                            : context
                                                        .watch<
                                                            LoadPreferences>()
                                                        .listWheelScrollViewHorizontalChanging ==
                                                    -0.5
                                                ? 4
                                                : context
                                                            .watch<
                                                                LoadPreferences>()
                                                            .listWheelScrollViewHorizontalChanging ==
                                                        0
                                                    ? 5
                                                    : context
                                                                .watch<
                                                                    LoadPreferences>()
                                                                .listWheelScrollViewHorizontalChanging ==
                                                            0.5
                                                        ? 6
                                                        : context
                                                                    .watch<
                                                                        LoadPreferences>()
                                                                    .listWheelScrollViewHorizontalChanging ==
                                                                1.1
                                                            ? 7
                                                            : context
                                                                        .watch<
                                                                            LoadPreferences>()
                                                                        .listWheelScrollViewHorizontalChanging ==
                                                                    1.4
                                                                ? 8
                                                                : context.watch<LoadPreferences>().listWheelScrollViewHorizontalChanging == 1.7
                                                                    ? 9
                                                                    : context.watch<LoadPreferences>().listWheelScrollViewHorizontalChanging == 2
                                                                        ? 10
                                                                        : 5,
                            lineColor: Colors.white,
                            activeStepBorderColor: Colors.amber,
                            activeStepBorderPadding: 3.0,
                            activeStepBorderWidth: 5.0,
                            lineDotRadius: 2.0,
                            stepReachedAnimationEffect: Curves.elasticOut,
                            onStepReached: (index) async {
                              switch (index) {
                                case 0:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          -2);
                                  break;
                                case 1:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          -1.7);
                                  break;
                                case 2:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          -1.4);
                                  break;
                                case 3:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          -1.1);
                                  break;
                                case 4:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          -0.5);
                                  break;
                                case 5:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          0);
                                  break;
                                case 6:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          0.5);
                                  break;
                                case 7:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          1.1);
                                  break;
                                case 8:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          1.4);
                                  break;
                                case 9:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          1.7);
                                  break;
                                case 10:
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  context
                                      .read<LoadPreferences>()
                                      .horizontalChangingOfListWheelScrollView(
                                          2);
                                  break;
                              }
                            },
                            stepReachedAnimationDuration:
                                const Duration(microseconds: 1),
                          ),
                        ),
                        onPressed: () async {
                          // Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(
      () {
        getRecipesNumber();
        setState(() {
          _showRecipesNumber = true;
        });
      },
    );
  }

  getRecipesNumber() async {
    //**************Get the number of recipes***************/
    String recipeType = '';
    _currentIndex == 0
        ? recipeType = 'food'
        : _currentIndex == 2
            ? recipeType = 'sweets'
            : null;
    List<Map> sqlData = await _sqlDb.readData(
        table: 'Cooking',
        orderby: 'id DESC',
        where: 'type LIKE ?',
        whereArgs: [recipeType]);

    setState(() {
      _recipesNumber = sqlData.length;
    });

    //******************************************************/
  }
}
