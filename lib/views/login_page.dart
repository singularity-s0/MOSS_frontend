import 'package:flutter/material.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Region { cn, intl }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController accountController;
  late TextEditingController passwordController;

  late Future<Region> _region;

  @override
  void initState() {
    accountController = TextEditingController();
    passwordController = TextEditingController();
    _region = Future.delayed(const Duration(seconds: 1), () => Region.cn);
    super.initState();
  }

  bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  bool isValidCNPhoneNumber(String phone) {
    return RegExp(
            '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(phone);
  }

  Widget emailField(BuildContext context) => TextFormField(
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
      ),
      validator: (value) {
        return isValidEmail(value!)
            ? null
            : AppLocalizations.of(context)!.please_enter_valid_email;
      },
      controller: accountController);

  Widget phoneField(BuildContext context) => TextFormField(
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.phone_number,
      ),
      validator: (value) {
        return isValidCNPhoneNumber(value!)
            ? null
            : AppLocalizations.of(context)!.please_enter_valid_phone;
      },
      controller: accountController);

  Widget autoAccountField(BuildContext context, Region region) {
    switch (region) {
      case Region.intl:
        return emailField(context);
      case Region.cn:
        return phoneField(context);
    }
  }

  Widget buildLandingPage(BuildContext context, {Object? error}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/images/logo.png', scale: 6.5),
            const SizedBox(height: 25),
            Text(
              error == null
                  ? AppLocalizations.of(context)!.fetching_server_configurations
                  : AppLocalizations.of(context)!.error,
              style: TextStyle(
                  fontSize: 35,
                  color: error == null
                      ? null
                      : Theme.of(context).colorScheme.error),
            ),
            Opacity(
              opacity: 0.7,
              child: Text(
                error == null
                    ? AppLocalizations.of(context)!.please_wait
                    : error.toString(),
                style: const TextStyle(fontSize: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginPanel(BuildContext context, Region region) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/images/logo.png', scale: 6.5),
            const SizedBox(height: 25),
            Text(
              AppLocalizations.of(context)!.welcome_comma,
              style: const TextStyle(fontSize: 35),
            ),
            Opacity(
              opacity: 0.7,
              child: Text(
                AppLocalizations.of(context)!.sign_in_to_continue,
                style: const TextStyle(fontSize: 35),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    autoAccountField(context, region),
                    const SizedBox(height: 20),
                    TextFormField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                        controller: passwordController),
                    const SizedBox(height: 60),
                    LoginButton(onTap: () async {
                      await showLoadingDialogUntilFutureCompletes(
                          context, Future.delayed(const Duration(seconds: 1)));
                      AccountProvider.getInstance().token =
                          JWToken('access', 'refresh');
                    })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return FutureBuilder(
      future: _region,
      builder: (context, snapshot) {
        return AnimatedSwitcher
        if (snapshot.hasError) {
          return buildLandingPage(context, error: snapshot.error);
        } else if (snapshot.hasData) {
          return buildLoginPanel(context, snapshot.data as Region);
        } else {
          return buildLandingPage(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: kTabletSingleContainerWidth,
              height: 600,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                clipBehavior: Clip.antiAlias,
                child: buildContent(context),
              ),
            ),
          ),
        ),
      );
    } else {
      return buildContent(context);
    }
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  const LoginButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: 0.7,
        child: Container(
          width: 230,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 224, 227, 231),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Get Started",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 19),
              ),
              SizedBox(width: 15),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black,
                size: 26,
              )
            ],
          ),
        ),
      ),
    );
  }
}
