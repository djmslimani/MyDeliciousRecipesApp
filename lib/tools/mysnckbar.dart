import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void showSnackBar(BuildContext context, String message, Color backgroundColor,
    Color foregroundColor) async {
  //*******Change the width of the snackBar according to its content**********/
  final textSpan = TextSpan(
    text: message,
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
      color: foregroundColor,
    ),
  );
  final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
  tp.layout();
  double textWidth = tp.width;
  //*************************************************************************/

  // await Future.delayed(const Duration(milliseconds: 200));
  FocusManager.instance.primaryFocus
      ?.unfocus(); //Dismiss the on screen keyboard
  final snackBar = SnackBar(
    width: textWidth + 10.w, //message.length * 20,
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 1200),
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.w)),
    ),
    backgroundColor: backgroundColor,
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: foregroundColor,
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
