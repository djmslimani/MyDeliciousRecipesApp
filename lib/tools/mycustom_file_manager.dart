import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:my_cooking_recipes/tools/custom_progress_dialog.dart';
import 'package:my_cooking_recipes/tools/sqldb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_scroll/text_scroll.dart';
import '../l10n/app_localizations.dart';
import '../pages/home_page.dart';
import 'custom_color_theme.dart';
import 'custom_file_manager.dart';
import 'package:flutter/material.dart';

import 'package:archive/archive_io.dart' as archive;

import 'mysnckbar.dart';

class CustomFileManager extends StatefulWidget {
  const CustomFileManager({super.key, required this.initialDirectoryPath});

  final String initialDirectoryPath;

  @override
  State<CustomFileManager> createState() => _CustomFileManagerState();
}

class _CustomFileManagerState extends State<CustomFileManager>
    with WidgetsBindingObserver {
  final FileManagerController controller = FileManagerController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) return;
    final isResumed = state == AppLifecycleState.resumed;

    if (isResumed) {
      await createDirectoryIfNotExists(); //Create the initial directory in order to prevent the App from crashing if the initial directory was deleted.
      setState(() {});
    }
  }

  var myColors;

  @override
  Widget build(BuildContext context) {
    controller.openDirectory(Directory(widget.initialDirectoryPath));
    myColors = Theme.of(context).extension<CustomColorTheme>()!;

    return ControlBackButton(
      controller: controller,
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

            // appBar: AppBar(
            //   toolbarHeight: 80,
            //   actions: [
            // IconButton(
            //   onPressed: () => createFolder(context),
            //   icon: const Icon(Icons.create_new_folder_outlined),
            // ),
            // IconButton(
            //   onPressed: () => sort(context),
            //   icon: const Icon(Icons.sort_rounded),
            // ),

            // TextButton(
            //   child: Row(
            //     children: [
            //       // const Icon(
            //       //   Icons.arrow_drop_down,
            //       //   color: Colors.black,
            //       // ),
            //       ValueListenableBuilder<String>(
            //         valueListenable: controller.titleNotifier,
            //         builder: (context, title, _) => Text(
            //           controller.getCurrentPath.contains('emulated')
            //               ? AppLocalizations.of(context)!.internalstorage
            //               : AppLocalizations.of(context)!.externalstorage,
            //           style: TextStyle(fontSize: 12.sp, color: Colors.black),
            //         ),
            //       ),
            //     ],
            //   ),
            //   onPressed: () => selectStorage(context),
            // ),
            // ],
            // title: ValueListenableBuilder<String>(
            //   valueListenable: controller.titleNotifier,
            //   builder: (context, title, _) => TextScroll(
            //     intervalSpaces: 3.w.toInt(),
            //     mode: TextScrollMode.endless,
            //     delayBefore: const Duration(milliseconds: 500),
            //     pauseBetween: const Duration(milliseconds: 100),
            //     selectable: true,
            //     controller.getCurrentPath,
            //     velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
            //     style: TextStyle(
            //       fontSize: 12.sp,
            //     ),
            //   ),
            // ),
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: () async {
            //     final List<Directory> storageList =
            //         (await FileManager.getStorageList());

            //     storageList.toString().contains(controller.getCurrentPath)
            //         ? Navigator.pop(context)
            //         : await controller.goToParentDirectory();
            //   },
            // ),
            // ),
            body: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.only(
                      top: 8.h, bottom: 1.h, left: 1.h, right: 1.h),
                  child: FileManager(
                    controller: controller,
                    builder: (context, snapshot) {
                      final List<FileSystemEntity> entities = snapshot;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.w),
                            ),
                            color: Colors.transparent,
                            elevation: 1,
                            child: (FileManager.isFile(entity) &&
                                        FileManager.basename(entity, false)
                                            .contains(
                                                '.MyDeliciousRecipesBackup')) ||
                                    FileManager.isDirectory(entity)
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 1.w, horizontal: 3.w),
                                    child: InkWell(
                                      child: Row(
                                        children: [
                                          FileManager.isFile(entity) &&
                                                  FileManager.basename(
                                                          entity, false)
                                                      .contains(
                                                          '.MyDeliciousRecipesBackup')
                                              ? ClipOval(
                                                  child: Image.asset(
                                                  'assets/icons/FileIcon.png',
                                                  height: 15.w,
                                                  width: 15.w,
                                                ))
                                              : Icon(
                                                  Icons.folder,
                                                  color: myColors
                                                      .iconsPopupMenuHome,
                                                  size: 18.w,
                                                ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextScroll(
                                                  intervalSpaces: 3.w.toInt(),
                                                  mode: TextScrollMode.endless,
                                                  delayBefore: const Duration(
                                                      milliseconds: 500),
                                                  pauseBetween: const Duration(
                                                      milliseconds: 100),
                                                  selectable: false,
                                                  FileManager.basename(entity),
                                                  velocity: const Velocity(
                                                      pixelsPerSecond:
                                                          Offset(20, 0)),
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: myColors
                                                        .textCardSettings,
                                                  ),
                                                ),
                                                SizedBox(height: 1.h),
                                                entity.existsSync()
                                                    ? subtitle(entity)
                                                    : const Text(''),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        if (FileManager.isDirectory(entity)) {
                                          // open the folder

                                          FileManager.basename(entity, false)
                                                  .contains('Android')
                                              ? null
                                              : controller
                                                  .openDirectory(entity);

                                          // delete a folder
                                          // await entity.delete(recursive: true);

                                          // rename a folder
                                          // await entity.rename("newPath");

                                          // Check weather folder exists
                                          // entity.exists();

                                          // get date of file
                                          // DateTime date = (await entity.stat()).modified;
                                        } else {
                                          // delete a file
                                          // await entity.delete();

                                          // rename a file
                                          // await entity.rename("newPath");

                                          // Check weather file exists
                                          // entity.exists();

                                          // get date of file
                                          // DateTime date = (await entity.stat()).modified;

                                          // get the size of the file
                                          // int size = (await entity.stat()).size;
                                          try {
                                            //********Verification of the file in order to prevent the App from crashing******//
                                            final inputStream =
                                                archive.InputFileStream(
                                                    entity.path);
                                            final backup = archive.ZipDecoder()
                                                .decodeStream(inputStream);
                                            //************************************************************* */
                                            if (backup.any((element) =>
                                                element.name == 'cooking.db')) {
                                              SqlDb sqlDb = SqlDb();
                                              List<Map> databaseData =
                                                  await sqlDb.reaAlldData(
                                                      'SELECT * FROM Cooking');
                                              if (databaseData.isEmpty) {
                                                await extractBackup(
                                                    context: context,
                                                    filePath: entity.path,
                                                    keepOldRecipes: false);
                                                await successfullRestore();
                                              } else {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            71, 0, 0, 0),
                                                    scrollable: true,
                                                    insetPadding: EdgeInsets
                                                        .zero, //To avoid the error "A RenderFlex overflowed by 24 pixels on the right."
                                                    iconPadding:
                                                        EdgeInsets.only(
                                                            top: 2.w),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2.w),
                                                    actionsPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2.w),
                                                    icon: Icon(
                                                      Icons
                                                          .settings_backup_restore_outlined,
                                                      color: Colors
                                                          .greenAccent[700],
                                                      size: 15.w,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(25.0),
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      2.w),
                                                          child: Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .preserverecipesmessage,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
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
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              // shape:
                                                              //     RoundedRectangleBorder(
                                                              //   borderRadius:
                                                              //       new BorderRadius
                                                              //               .circular(
                                                              //           30.w),
                                                              // ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                              await extractBackup(
                                                                context:
                                                                    context,
                                                                filePath:
                                                                    entity.path,
                                                                keepOldRecipes:
                                                                    true,
                                                              );
                                                              await successfullRestore();
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .yes,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.sp,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 20.w),
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              // shape:
                                                              //     RoundedRectangleBorder(
                                                              //   borderRadius:
                                                              //       new BorderRadius
                                                              //               .circular(
                                                              //           30.w),
                                                              // ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                              await extractBackup(
                                                                  context:
                                                                      context,
                                                                  filePath:
                                                                      entity
                                                                          .path,
                                                                  keepOldRecipes:
                                                                      false);
                                                              await successfullRestore();
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .no,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.sp,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            } else {
                                              showSnackBar(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .notavalidfile,
                                                  Color.fromARGB(117, 3, 1, 39),
                                                  Colors.white);
                                            }
                                          } catch (e) {
                                            showSnackBar(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .unsupportedfiletype,
                                                Color.fromARGB(117, 3, 1, 39),
                                                Colors.white);
                                          }
                                        }
                                      },
                                    ),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: myColors.backgroundPopupMenuHome,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            AppLocalizations.of(context)!
                                    .language
                                    .contains('العربية')
                                ? Icons.arrow_circle_right_outlined
                                : Icons.arrow_circle_left_outlined,
                            color: myColors.textPopupMenuHome,
                          ),
                          iconSize: 7.w,
                          onPressed: () async {
                            final List<Directory> storageList =
                                (await FileManager.getStorageList());

                            storageList
                                    .toString()
                                    .contains(controller.getCurrentPath)
                                ? Navigator.pop(context)
                                : await controller.goToParentDirectory();
                          },
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ValueListenableBuilder<String>(
                            valueListenable: controller.titleNotifier,
                            builder: (context, title, _) => TextScroll(
                              intervalSpaces: 3.w.toInt(),
                              mode: TextScrollMode.endless,
                              delayBefore: const Duration(milliseconds: 500),
                              pauseBetween: const Duration(milliseconds: 100),
                              selectable: true,
                              controller.getCurrentPath,
                              velocity: const Velocity(
                                  pixelsPerSecond: Offset(20, 0)),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: myColors.textPopupMenuHome,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        TextButton(
                          child: Row(
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: controller.titleNotifier,
                                builder: (context, title, _) => Text(
                                  controller.getCurrentPath.contains('emulated')
                                      ? AppLocalizations.of(context)!
                                          .internalstorage
                                      : AppLocalizations.of(context)!
                                          .externalstorage,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: myColors.textPopupMenuHome,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  color: myColors.textPopupMenuHome, size: 6.w),
                            ],
                          ),
                          onPressed: () => selectStorage(context),
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

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
              style: TextStyle(
                  fontSize: 8.5.sp, color: myColors!.textCardSettings),
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
            style:
                TextStyle(fontSize: 8.5.sp, color: myColors!.textCardSettings),
          );
        } else {
          return const Text("");
        }
      },
    );
  }

  selectStorage(BuildContext scaffoldContext) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              FileManager.basename(e) == '0'
                                  ? AppLocalizations.of(context)!
                                      .internalstorage
                                  : AppLocalizations.of(context)!
                                      .externalstorage,
                            ),
                            leading: Icon(FileManager.basename(e) == '0'
                                ? Icons.phone_iphone_outlined
                                : Icons.sd_storage),
                            onTap: () {
                              controller.openDirectory(e);

                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList()),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future successfullRestore() async {
    waitForSeconds().then((value) => {
          HomePage.setStateHomePage = true,
          Navigator.pop(context),
        });
  }

  Future<String> createDirectoryIfNotExists() async {
    String documentsPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);
    var _directory =
        await Directory('$documentsPath/MyDeliciousRecipesBackups');

    if (await _directory.exists()) {
      //if the folder already exists return path
      return _directory.path;
    } else {
      //if the folder doesn't exist, create the folder and then return its path
      final Directory _newDirectory = await _directory.create(recursive: true);
      return _newDirectory.path;
    }
  }

  // sort(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Container(
  //         padding: const EdgeInsets.all(10),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //                 title: const Text("Name"),
  //                 onTap: () {
  //                   controller.sortBy(SortBy.name);
  //                   Navigator.pop(context);
  //                 }),
  //             ListTile(
  //                 title: const Text("Size"),
  //                 onTap: () {
  //                   controller.sortBy(SortBy.size);
  //                   Navigator.pop(context);
  //                 }),
  //             ListTile(
  //                 title: const Text("Date"),
  //                 onTap: () {
  //                   controller.sortBy(SortBy.date);
  //                   Navigator.pop(context);
  //                 }),
  //             ListTile(
  //                 title: const Text("type"),
  //                 onTap: () {
  //                   controller.sortBy(SortBy.type);
  //                   Navigator.pop(context);
  //                 }),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // createFolder(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       TextEditingController folderName = TextEditingController();
  //       return Dialog(
  //         child: Container(
  //           padding: const EdgeInsets.all(10),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                 title: TextField(
  //                   controller: folderName,
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   try {
  //                     // Create Folder
  //                     await FileManager.createFolder(
  //                         controller.getCurrentPath, folderName.text);
  //                     // Open Created Folder
  //                     controller.setCurrentPath =
  //                         "${controller.getCurrentPath}/${folderName.text}";
  //                   } catch (e) {}

  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Create Folder'),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}

Future extractBackup(
    {required BuildContext context,
    required String filePath,
    required bool keepOldRecipes}) async {
  String progressDialogRestoreInitialMessage =
      AppLocalizations.of(context)!.restoringpleasewait;
  String progressDialogRestoreFinalMessage =
      AppLocalizations.of(context)!.restorecompletedsuccessfully;
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
    message: progressDialogRestoreInitialMessage,
  );
  await pr.show();

  var databaseDirectory = Directory(await getDatabasesPath());
  //******************Remove old files except the Database**************/
  if (!keepOldRecipes) {
    databaseDirectory.list(recursive: true).listen((file) {
      if (file is File && !file.path.endsWith('.db')) file.deleteSync();
    });
  }
  //********************************************************************/

  final zipFile = File(filePath);
  final destinationDir = Directory(databaseDirectory.path);
  await ZipFile.extractToDirectory(
    zipFile: zipFile,
    destinationDir: destinationDir,
    onExtracting: (zipEntry, progress) {
      if (zipEntry.name == 'cooking.db' && keepOldRecipes) {
        insertDataIntoTheDatabase(filePath);
        return ZipFileOperation.skipItem;
      } else {
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
                pr.update(message: progressDialogRestoreFinalMessage),
                waitForSeconds().then((value) => {
                      pr.hide(),
                    }),
              }
            : null;

        return ZipFileOperation.includeItem;
      }
    },
  );
}

Future waitForSeconds() async {
  await Future.delayed(Duration(milliseconds: 1200));
}

insertDataIntoTheDatabase(String filePath) async {
  SqlDb sqlDb = SqlDb();

  try {
    //**Copy the exported database to cach directory in order to read data from it**/

    final zipFile = File(filePath);
    var cacheDirpath = (await getTemporaryDirectory()).path;
    final destinationDir = Directory(cacheDirpath);
    await ZipFile.extractToDirectory(
      zipFile: zipFile,
      destinationDir: destinationDir,
      onExtracting: (zipEntry, progress) {
        if (zipEntry.name == 'cooking.db') {
          return ZipFileOperation.includeItem;
        } else {
          return ZipFileOperation.skipItem;
        }
      },
    );
    //*****************Open the newdatabase and read its content***************/
    Database mydb = await openDatabase('$cacheDirpath/cooking.db');
    List<Map> newDatabaseData = await mydb.rawQuery('SELECT * FROM Cooking');
    mydb.close();
    //*************************************************************************/
    List<Map> oldDatabaseData =
        await sqlDb.reaAlldData('SELECT * FROM Cooking');
    //******************************************************************************/

    //*********Check the if there are duplicated data in new and old databases*******/

    var response;
    int index = 2;
    for (var newMap in newDatabaseData) {
      for (var oldMap in oldDatabaseData) {
        if (newMap['title'] == oldMap['title']) {
          response = await sqlDb.insertData(
              "INSERT INTO Cooking (title, ingredient, recipe, imagepath, type) VALUES ('${newMap['title'].trim().toUpperCase()}_$index', '${newMap['ingredient'].trim()}', '${newMap['recipe'].trim()}', '${newMap['imagepath'].trim()}', '${newMap['type'].trim()}')");

          while (response is String && response.contains('UNIQUE constraint')) {
            index += 1;
            response = await sqlDb.insertData(
                "INSERT INTO Cooking (title, ingredient, recipe, imagepath, type) VALUES ('${newMap['title'].trim().toUpperCase()}_$index', '${newMap['ingredient'].trim()}', '${newMap['recipe'].trim()}', '${newMap['imagepath'].trim()}', '${newMap['type'].trim()}')");
          }
        } else {
          await sqlDb.insertData(
              "INSERT INTO Cooking (title, ingredient, recipe, imagepath, type) VALUES ('${newMap['title'].trim().toUpperCase()}', '${newMap['ingredient'].trim()}', '${newMap['recipe'].trim()}', '${newMap['imagepath'].trim()}', '${newMap['type'].trim()}')");
        }
      }
    }
  } catch (e) {
    print('Error: ${e.toString()}');
  }
}

updateToInitialProgressDialog(ProgressDialog progressDialog) {
  //******To restart the initial sate of the ProgressDialog pr****/
  progressDialog.update(
    progress: 0.0,
    progressWidget: Center(
      child: Stack(
        fit: StackFit.expand,
        children: const [
          CircularProgressIndicator(
            value: 0.0,
            backgroundColor: Color.fromARGB(192, 148, 134, 29),
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 9, 249, 0)),
            strokeWidth: 8,
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
