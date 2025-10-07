import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../custom_icons_icons.dart';
import '../routes/routes.dart';
import '../tools/decorated_container.dart';
import 'home_page.dart';
import '../tools/custom_color_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _animationController = ConfettiController();
  bool isPlaying = false;

  @override
  void initState() {
    _animationController.addListener(
      () {
        isPlaying =
            _animationController.state == ConfettiControllerState.playing;
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myColors = Theme.of(context).extension<CustomColorTheme>()!;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              extendBody: true,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Container(
                height: 14.w,
                width: 14.w,
                child: FloatingActionButton(
                  backgroundColor: myColors.backgroundPopupMenuHome,
                  foregroundColor: myColors.iconsPopupMenuHome,
                  elevation: 20,
                  onPressed: () async {
                    HomePage.launchConfetti = true;
                    HomePage.searchIndex = false;

                    await Navigator.of(context)
                        .popAndPushNamed(RouteManager.homePage);
                  },
                  child: Icon(
                    CustomIcons.loop,
                    size: 8.w,
                  ),
                ),
              ),
              body: DecoratedContainer(
                myWhere: 'title LIKE ?',
                myWhereArgs: ['%${HomePage.savedText}%'],
              ),
              bottomNavigationBar: BottomAppBar(
                elevation: 0.0,
                color: Colors.transparent,
                height: 40,
                shape: CircularNotchedRectangle(),
                // items: [
              ),
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
      ],
    );
  }
}
