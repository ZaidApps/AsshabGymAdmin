import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  }

  Future<void> _loadLocale() async {
    await LanguageService.getLocale();
  }

  void _listenToLocaleChanges() {
    LanguageService.localeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ashhab Gym',
      theme: AppTheme.lightTheme,
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
  }
}
