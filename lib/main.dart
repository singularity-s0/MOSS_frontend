import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_hero/local_hero.dart';
import 'package:openchat_frontend/model/chat.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/settings_provider.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:openchat_frontend/views/components/intro.dart';
import 'package:openchat_frontend/views/history_page.dart';
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
      child: LocalHeroScope(
          createRectTween: (begin, end) {
            return RectTween(begin: begin, end: end);
          },
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastLinearToSlowEaseIn,
          child: const MainApp()),
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

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  // Mobile UI
  Widget buildMobile(BuildContext context) =>
      Selector<TopicStateProvider, ChatThread?>(
          selector: (_, model) => model.currentTopic,
          builder: (context, value, child) => value == null
              ? NullChatLoader(
                  heroTag:
                      "MossLogo${isDesktop(context) ? "Desktop" : value?.id}}",
                )
              : ChatView(key: ValueKey(value), topic: value, showMenu: true));

  // Desktop UI
  Widget buildDesktop(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left View
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: kTabletMasterContainerWidth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                clipBehavior: Clip.antiAlias,
                child: Selector<TopicStateProvider, ChatThread?>(
                    selector: (_, model) => model.currentTopic,
                    builder: (context, value, child) =>
                        HistoryPage(selectedTopic: value)),
              ),
            ),
          ),
          // Right View
          ScaffoldMessenger(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width -
                  kTabletMasterContainerWidth,
              child: SizedBox.expand(
                child: Card(
                  margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                  color: Theme.of(context).colorScheme.background,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: SizedBox(
                      width: min(
                          MediaQuery.of(context).size.height,
                          MediaQuery.of(context).size.width -
                              kTabletMasterContainerWidth),
                      child: Selector<TopicStateProvider, ChatThread?>(
                          selector: (_, model) => model.currentTopic,
                          builder: (context, value, child) => value == null
                              ? NullChatLoader(
                                  heroTag:
                                      "MossLogo${isDesktop(context) ? "Desktop" : value?.id}}",
                                )
                              : ChatView(key: ValueKey(value), topic: value)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      isDesktop(context) ? buildDesktop(context) : buildMobile(context);
}
