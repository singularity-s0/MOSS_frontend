import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/components/local_hero/local_hero.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:openchat_frontend/views/login_page.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsProvider.getInstance().init();
  Repository.init(AccountProvider.getInstance());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final Map<String, Widget Function(BuildContext)> routes = {
    '/empty': (context, {arguments}) =>
        ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
    '/': (context, {arguments}) {
      // Dynamically show chat page or login page based on logged in or not
      final token = context.watch<AccountProvider>().token;
      if (token == null) {
        return const LoginScreen();
      } else {
        return ChatPage();
      }
    },
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // FIXME: Should create provider instead of using singleton, this allows for multiple accounts without refactor
        ChangeNotifierProvider<AccountProvider>.value(
            value: AccountProvider.getInstance()),
        ChangeNotifierProvider<SettingsProvider>.value(
            value: SettingsProvider.getInstance())
      ],
      child: LocalHeroScope(
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastLinearToSlowEaseIn,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
              colorSchemeSeed: const Color.fromRGBO(56, 100, 184, 1),
              bottomSheetTheme: BottomSheetThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              useMaterial3: true),
          initialRoute: '/',
          routes: routes,
        ),
      ),
    );
  }
}
