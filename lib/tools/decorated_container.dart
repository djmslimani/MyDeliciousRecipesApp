import 'dart:io';

import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/material.dart';
import 'package:my_cooking_recipes/pages/recipes.dart';
import 'package:my_cooking_recipes/tools/custom_color_theme.dart';
import 'package:my_cooking_recipes/tools/sqldb.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../routes/routes.dart';
import 'load_preferences.dart';

class DecoratedContainer extends StatefulWidget {
  DecoratedContainer(
      {super.key, required this.myWhereArgs, required this.myWhere});

  final List<String> myWhereArgs;
  final String myWhere;

  static double? listWheelScrollViewVrerticalChanging;
  static double? listWheelScrollViewHorizontalChanging;

  @override
  State<DecoratedContainer> createState() => _DecoratedContainerState();
}

class _DecoratedContainerState extends State<DecoratedContainer> {
  SqlDb sqlDb = SqlDb();

  late FixedExtentScrollController _listViewcontroller;

  @override
  void initState() {
    super.initState();
    _listViewcontroller = FixedExtentScrollController(
      initialItem: Recipes.initialItem != null ? Recipes.initialItem! : 0,
    );
    Recipes.initialItem = 0;
  }

  @override
  void dispose() {
    _listViewcontroller.dispose();
    super.dispose();
  }

  Future<List<Map>> readData() async {
    try {
      List<Map> sqlData = await sqlDb.readData(
          table: 'Cooking',
          orderby: 'id DESC',
          where: widget.myWhere,
          whereArgs: widget.myWhereArgs);

      return sqlData;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final myColors = Theme.of(context).extension<CustomColorTheme>()!;
    final double _itemHeight = MediaQuery.of(context).size.height / 2;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            myColors.gradientFirstColor!,
            myColors.gradientSecondColor!,
          ],
        ),
      ),
      child: FutureBuilder(
        future: readData(),
        builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
          if (snapshot.hasData) {
            return ClickableListWheelScrollView(
              scrollController: _listViewcontroller,
              itemHeight: _itemHeight,
              itemCount: snapshot.data!.length,
              onItemTapCallback: (index) async {
                Recipes.initialItem = index;
                Recipes.id =
                    snapshot.data![snapshot.data!.length - 1 - index]['id'];
                await Navigator.of(context)
                    .pushReplacementNamed(RouteManager.recipes);
              },
              child: ListWheelScrollView.useDelegate(
                // onSelectedItemChanged: (value) {
                //   print(value + 1);
                // },
                physics: FixedExtentScrollPhysics(),
                perspective: context
                        .watch<LoadPreferences>()
                        .listWheelScrollViewVrerticalChanging ??
                    0.000000001,
                offAxisFraction: context
                        .watch<LoadPreferences>()
                        .listWheelScrollViewHorizontalChanging ??
                    0,
                itemExtent: _itemHeight,
                controller: _listViewcontroller,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 30),
                      elevation: 1,
                      color: myColors.backgroundCardDecoratedContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 1.5.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              textAlign: TextAlign.center,
                              '${snapshot.data![snapshot.data!.length - 1 - index]['title']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: myColors.textCardDecoratedContainer,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipOval(
                                child: Image(
                                  image: FileImage(
                                    File(
                                        '${snapshot.data![snapshot.data!.length - 1 - index]['imagepath']}'),
                                  ),
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: MediaQuery.of(context).size.width -
                                      (MediaQuery.of(context).size.width / 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: snapshot.data!.length,
                ),
              ),
            );
          }
          return Center(
            child: Container(
              height: 8.h,
              width: 8.h,
              child: CircularProgressIndicator(
                color: myColors.tabBarHomeIndicator,
              ),
            ),
          );
        },
      ),
    );
  }
}
