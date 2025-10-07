import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as df;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:share_plus/share_plus.dart';

class RecipeAsPdf {
  static Future<File> generate({
    required String headerName,
    required String recipeName,
    required String imagePath,
    required String ingredient,
    required String ingredientText,
    required String method,
    required String methodText,
    required int? languageIndex,
    required int storagePathIndex,
  }) async {
    try {
      final pdf = Document();

      var arabicFont =
          Font.ttf(await rootBundle.load("fonts/HacenTunisia.ttf"));

      final image = (await rootBundle.load('assets/icons/DessertIcon.png'))
          .buffer
          .asUint8List();

      final imageFromApp = File(imagePath);

      final pageTheme = PageTheme(
        pageFormat: PdfPageFormat.a4,
        theme: ThemeData.withFont(
          base: arabicFont,
        ),
        textDirection:
            languageIndex == 1 ? TextDirection.rtl : TextDirection.ltr,
      );

      pdf.addPage(
        MultiPage(
          pageTheme: pageTheme,
          footer: (context) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 1 * PdfPageFormat.cm),
              child: Text(
                '${context.pageNumber}',
                style: const TextStyle(
                  color: PdfColors.black,
                ),
              ),
            );
          },
          build: (context) => <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Image(MemoryImage(image)),
                ),
              ],
            ),
            Header(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        headerName,
                        style: const TextStyle(
                          color: PdfColors.black,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recipeName,
                  style: const TextStyle(
                    color: PdfColors.black,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Center(
              child: ClipRRect(
                horizontalRadius: 32,
                verticalRadius: 32,
                child: Image(
                  MemoryImage(imageFromApp.readAsBytesSync()),
                  width: pageTheme.pageFormat.availableWidth,
                  height: pageTheme.pageFormat.availableWidth,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ingredient,
                  style: const TextStyle(
                    color: PdfColors.black,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Paragraph(
              text: ingredientText,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 20,
                height: 2,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  method,
                  style: const TextStyle(
                    color: PdfColors.black,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Paragraph(
              text: methodText,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 20,
                height: 2,
              ),
            ),
          ],
        ),
      );

      return saveDocument(
          name: recipeName, pdf: pdf, storagePathIndex: storagePathIndex);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<File> saveDocument(
      {required String name,
      required Document pdf,
      required int storagePathIndex}) async {
    try {
      final bytes = await pdf.save();
      String dir = storagePathIndex == 1
          ? await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOCUMENTS)
          : (await getTemporaryDirectory()).path;

      await Directory('$dir').exists()
          ? null
          : await Directory('$dir').create(recursive: true);

      String currentDate = df.DateFormat("dd-MM-yyyy").format(DateTime.now());
      String currentTime = df.DateFormat("HH-mm-ss").format(DateTime.now());

      final file = File('$dir/${name}_${currentDate}_${currentTime}.pdf');
      await file.writeAsBytes(bytes);

      storagePathIndex == 2
          ? {
              await Share.shareXFiles(
                [XFile('$dir/${name}_${currentDate}_${currentTime}.pdf')],
              ),
              await File('$dir/${name}_${currentDate}_${currentTime}.pdf')
                  .delete(),
            }
          : null;
      return file;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
