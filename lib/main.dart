import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ThemeService.init();
  runApp(const GymAdminApp());
}

class GymAdminApp extends StatefulWidget {
  const GymAdminApp({super.key});

  @override
  State<GymAdminApp> createState() => _GymAdminAppState();
}

class _GymAdminAppState extends State<GymAdminApp> {
  @override
  void initState() {
    super.initState();
    _loadLocale();
    _listenToLocaleChanges();
    _listenToThemeChanges();
  }

  Future<void> _loadLocale() async {
    final locale = await LanguageService.getLocale();
    // Ensure locale is set before app builds
    if (mounted) {
      setState(() {});
    }
  }

  void _listenToLocaleChanges() {
    LanguageService.localeNotifier.addListener(() {
      setState(() {});
    });
  }

  void _listenToThemeChanges() {
    ThemeService.themeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Ashhab Gym',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: LanguageService.localeNotifier.value,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          home: const LoginScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
