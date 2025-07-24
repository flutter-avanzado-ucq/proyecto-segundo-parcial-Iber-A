import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../provider_task/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          // Sección de idioma
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: const Text('Español'),
            trailing: localeProvider.locale?.languageCode == 'es'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              localeProvider.setLocale(const Locale('es'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('English'),
            trailing: localeProvider.locale?.languageCode == 'en'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              localeProvider.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(localizations.systemDefault),
            trailing: localeProvider.locale == null
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              localeProvider.clearLocale();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
