import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoadPreferences with ChangeNotifier {
  String? _chosenLanguage;
  int? _chosenTheme;
  double? _listWheelScrollViewVrerticalChanging;
  double? _listWheelScrollViewHorizontalChanging;

  SharedPreferences? _preferences;

  LoadPreferences() {
    _loadSettingsFromPrefs().then((value) async {
      await Future.delayed(Duration(milliseconds: 1000));
      FlutterNativeSplash.remove();
    });
  }

  String? get chosenLanguage => _chosenLanguage;
  int? get chosenTheme => _chosenTheme;
  double? get listWheelScrollViewVrerticalChanging =>
      _listWheelScrollViewVrerticalChanging ?? 0.000000001;
  double? get listWheelScrollViewHorizontalChanging =>
      _listWheelScrollViewHorizontalChanging;

  _initializePrefs() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
  }

  Future _loadSettingsFromPrefs() async {
    await _initializePrefs();
    _chosenLanguage = _preferences!.getString('appLanguage');
    _chosenTheme = _preferences!.getInt('appTheme');
    _listWheelScrollViewVrerticalChanging =
        _preferences!.getDouble('vrerticalChanging');
    _listWheelScrollViewHorizontalChanging =
        _preferences!.getDouble('horizontalChanging');

    notifyListeners();
  }

  _saveSettingsToPrefs(int index) async {
    await _initializePrefs();
    index == 0
        ? _preferences?.setString('appLanguage', _chosenLanguage!)
        : index == 1
            ? _preferences?.setInt('appTheme', _chosenTheme!)
            : index == 2
                ? _preferences?.setDouble(
                    'vrerticalChanging', _listWheelScrollViewVrerticalChanging!)
                : _preferences?.setDouble('horizontalChanging',
                    _listWheelScrollViewHorizontalChanging!);
  }

  void changeLanguage(String language) async {
    _chosenLanguage = language;
    _saveSettingsToPrefs(0);
    notifyListeners();
  }

  void changeTheme(int theme) async {
    _chosenTheme = theme;
    _saveSettingsToPrefs(1);
    notifyListeners();
  }

  void verticalChangingOfListWheelScrollView(double value) async {
    _listWheelScrollViewVrerticalChanging = value;
    _saveSettingsToPrefs(2);
    notifyListeners();
  }

  void horizontalChangingOfListWheelScrollView(double value) async {
    _listWheelScrollViewHorizontalChanging = value;
    _saveSettingsToPrefs(3);
    notifyListeners();
  }
}
