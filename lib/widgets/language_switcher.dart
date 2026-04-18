import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _listenToLanguageChanges();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  void _listenToLanguageChanges() {
    LanguageService.localeNotifier.addListener(() {
      setState(() {
        _currentLanguage = LanguageService.localeNotifier.value.languageCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Symbols.language, size: 20),
      tooltip: AppLocalizations.of(context).changeLanguage,
      onSelected: (String languageCode) {
        _changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return LanguageService.supportedLanguages.map((String language) {
          final languageCode = _getLanguageCode(language);
          final isSelected = _currentLanguage == languageCode;
          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              children: [
                Text(
                  language,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Arabic':
        return 'ar';
      default:
        return 'en';
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    await LanguageService.saveLanguage(languageCode);
    // Show a message to user that language has been changed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${LanguageService.getLanguageDisplayName(languageCode)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
