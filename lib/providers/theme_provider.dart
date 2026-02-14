import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
// Note: This provider MUST be overridden in main.dart with the actual instance
// Example usage in main.dart:
//   final prefs = await SharedPreferences.getInstance();
//   runApp(
//     ProviderScope(
//       overrides: [
//         sharedPrefsProvider.overrideWithValue(prefs),
//       ],
//       child: const MyApp(),
//     ),
//   );
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main.dart');
});

// Theme state class
class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Theme provider
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;
  
  ThemeNotifier(this._prefs) 
      : super(ThemeState(isDarkMode: _prefs.getBool('isDarkMode') ?? false));

  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    await _prefs.setBool('isDarkMode', newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> setTheme(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
    state = state.copyWith(isDarkMode: isDark);
  }
}

// Provider instance
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeNotifier(prefs);
});
