import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/generic.dart';

class PreferencesNotifier extends ChangeNotifier {
  PreferencesNotifier(this._preferences);

  final SharedPreferencesWithCache _preferences;

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  Future<void> set<T extends Object>(String key, T value) async {
    if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'value must be one of the following types: bool, int, double, String, List<String>',
      );
    }

    notifyListeners();
  }
}

class PreferencesProvider extends InheritedNotifier<PreferencesNotifier> {
  const PreferencesProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static PreferencesNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PreferencesProvider>();
    assert(provider != null, 'No PreferencesProvider found in context');
    assert(
        provider!.notifier != null, 'No PreferencesNotifier found in context');
    return provider!.notifier!;
  }

  static PreferencesNotifier? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PreferencesProvider>();
    return provider?.notifier;
  }

  static Future<void> set<T extends Object>(
    BuildContext context,
    String key,
    T value,
  ) async {
    return maybeOf(context)!.set<T>(key, value);
  }
}
