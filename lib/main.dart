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
import 'package:http/http.dart' as http;

const themeColor = Color.fromRGBO(56, 100, 184, 1);
const themeColorLight = Color.fromRGBO(121, 186, 243, 1);

var fontLoader = FontLoader('NotoSerif');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsProvider.getInstance().init();
  Repository.init(AccountProvider.getInstance());
  fontLoader.addFont(fetchFont());
  runApp(const MainApp());
}

Future<ByteData> fetchFont() async {
  // Noto Serif SC
  final response = await http.get(Uri.parse(
      'https://moss.fastnlp.top/assets/assets/fonts/H4chBXePl9DZ0Xe7gG9cyOj7oqCcbzhqDtg.otf'));

  if (response.statusCode == 200) {
    return ByteData.view(response.bodyBytes.buffer);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load font');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
        createRectTween: (begin, end) {
          return RectTween(begin: begin, end: end);
        },
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastLinearToSlowEaseIn,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
              colorSchemeSeed: themeColor,
              bottomSheetTheme: BottomSheetThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              fontFamily: 'Roboto',
              useMaterial3: true),
          home: FutureBuilder(
            future: fontLoader.load(),
            builder: ((context, snapshot) {
              // Dynamically show chat page or login page based on logged in or not
              final token = context.watch<AccountProvider>().token;
              final user = context.watch<AccountProvider>().user;
              Widget child;
              if (token == null || user == null) {
                child = const LoginScreen();
              } else {
                child = ChatPage();
              }
              return Theme(
                  data: ThemeData(
                      colorSchemeSeed: themeColor,
                      bottomSheetTheme: BottomSheetThemeData(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      fontFamily: 'Roboto',
                      fontFamilyFallback:
                          (snapshot.connectionState == ConnectionState.done)
                              ? const ['NotoSerif']
                              : null,
                      useMaterial3: true),
                  child: child);
            }),
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  // The state of this page records the "Topic" that the user is currently in
  // Children can use context.findAncestorStateOfType<ChatPageState>() to read and change this
  final ValueNotifier<ChatThread?> currentTopic =
      ValueNotifier<ChatThread?>(null);
  ChatPage({super.key});

  // Mobile UI
  Widget buildMobile(BuildContext context) => ValueListenableBuilder(
      valueListenable: currentTopic,
      builder: (context, value, child) => value == null
          ? NullChatLoader(
              heroTag: "MossLogo${isDesktop(context) ? "Desktop" : value?.id}}",
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
                child: ValueListenableBuilder(
                    valueListenable: currentTopic,
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
                      child: ValueListenableBuilder(
                          valueListenable: currentTopic,
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
