import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:openchat_frontend/views/login_page.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:provider/provider.dart';

void main() {
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
            value: AccountProvider.getInstance())
      ],
      child: MaterialApp(
        theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(56, 100, 184, 1),
                brightness: Brightness.light),
            useMaterial3: true),
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}
