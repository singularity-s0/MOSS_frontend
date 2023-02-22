import 'package:flutter/material.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:openchat_frontend/views/login_page.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

const themeColor = Color.fromRGBO(56, 100, 184, 1);
const themeColorLight = Color.fromRGBO(121, 186, 243, 1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsProvider.getInstance().init();
  Repository.init(AccountProvider.getInstance());
  runApp(
    MultiProvider(
      providers: [
        // FIXME: Should create provider instead of using singleton, this allows for multiple accounts without refactor
        ChangeNotifierProvider<AccountProvider>.value(
            value: AccountProvider.getInstance()),
        ChangeNotifierProvider<SettingsProvider>.value(
            value: SettingsProvider.getInstance()),
        ChangeNotifierProvider<TopicStateProvider>.value(
            value: TopicStateProvider.getInstance())
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<String>? fallback;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
          colorSchemeSeed: themeColor,
          bottomSheetTheme: BottomSheetThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          fontFamily: 'Roboto',
          fontFamilyFallback: fallback,
          useMaterial3: true),
      home: (context.watch<AccountProvider>().token == null ||
              context.watch<AccountProvider>().user == null)
          ? const LoginScreen()
          : const ChatPage(),
    );
  }
}
