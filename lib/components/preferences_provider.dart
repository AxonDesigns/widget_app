import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_app/generic.dart';

/// A provides access to the [SharedPreferences] instance<br>
/// and notifies listeners when the value of a key changed.
class PreferencesNotifier extends ChangeNotifier {
  /// Creates a new instance of [PreferencesNotifier].
  PreferencesNotifier({
    required SharedPreferencesWithCache preferences,
  }) : _preferences = preferences;

  final SharedPreferencesWithCache _preferences;

  /// Returns [bool] for a given [key], or null if the key is not found.
  bool? getBool(String key) => _preferences.getBool(key);

  /// Returns [int] for a given [key], or null if the key is not found.
  int? getInt(String key) => _preferences.getInt(key);

  /// Returns [double] for a given [key], or null if the key is not found.
  double? getDouble(String key) => _preferences.getDouble(key);

  /// Returns [String] for a given [key], or null if the key is not found.
  String? getString(String key) => _preferences.getString(key);

  /// Returns [List] of [String] for a given [key], or null if the key is not found.
  List<String>? getStringList(String key) => _preferences.getStringList(key);

  /// Sets value for a given [key] and notifies its listeners.
  /// If the value is a [bool], [int], [double], [String], or [List] of [String],
  ///
  /// If the value is not one of the supported types, an [ArgumentError] is thrown.
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

/// Provides an instance of [PreferencesNotifier] and listens to its changes.
class PreferencesProvider extends InheritedNotifier<PreferencesNotifier> {
  PreferencesProvider({
    super.key,
    required SharedPreferencesWithCache preferences,
    required super.child,
  }) : super(notifier: PreferencesNotifier(preferences: preferences));

  /// Returns the [PreferencesNotifier] instance of the ancestor [PreferencesProvider].
  /// If there is no ancestor, an error is thrown.
  static PreferencesNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PreferencesProvider>();
    assert(provider != null, 'No PreferencesProvider found in context');
    assert(
        provider!.notifier != null, 'No PreferencesNotifier found in context');
    return provider!.notifier!;
  }

  /// Returns an instance of [PreferencesNotifier] if exists, otherwise null.
  static PreferencesNotifier? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PreferencesProvider>();
    return provider?.notifier;
  }

  /// Sets a value for the given [key] in the [SharedPreferences] instance.
  ///
  /// If the value is a [bool], [int], [double], [String], or [List<String>],
  /// the value is set in the [SharedPreferences] instance.
  ///
  /// If the value is not one of the supported types, an [ArgumentError] is thrown.
  static Future<void> set<T extends Object>(
    BuildContext context,
    String key,
    T value,
  ) async {
    return maybeOf(context)!.set<T>(key, value);
  }
}
