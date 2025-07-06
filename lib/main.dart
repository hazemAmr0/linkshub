import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'providers/theme_provider.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const LinksHubApp());
}

class LinksHubApp extends StatelessWidget {
  const LinksHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'LinksHub',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(
              child: ValueListenableBuilder<Box<UserModel>>(
                valueListenable: DatabaseService.getUserListenable(),
                builder: (context, box, _) {
                  final user = DatabaseService.getUser();
                  if (user == null) {
                    return const ProfileSetupScreen();
                  }
                  return const HomeScreen();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
