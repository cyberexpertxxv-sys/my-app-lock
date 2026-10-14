import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasPassword = prefs.getString('real_password') != null;
  runApp(MyApp(hasPassword: hasPassword));
}

class MyApp extends StatelessWidget {
  final bool hasPassword;
  const MyApp({super.key, required this.hasPassword});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Lock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: hasPassword ? const HomeScreen() : const SetupScreen(),
    );
  }
}

@pragma('vm:entry-point')
void lockScreenMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final realPassword = prefs.getString('real_password') ?? '1234';

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: LockScreen(
      realPassword: realPassword,
      onUnlock: () async {
        SystemNavigator.pop();
      },
      onCancel: () async {
        const platform = MethodChannel('app_lock/control');
        try {
          await platform.invokeMethod('goHome');
        } catch (_) {
          SystemNavigator.pop();
        }
      },
    ),
  ));
}
