import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../provider_task/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: ListView(
        children: [
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
            title: const Text('Usar idioma del sistema'),
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
