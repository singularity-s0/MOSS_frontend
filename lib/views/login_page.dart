import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openchat_frontend/model/user.dart';
import 'package:openchat_frontend/repository/repository.dart';
import 'package:openchat_frontend/utils/account_provider.dart';
import 'package:openchat_frontend/utils/dialog.dart';
import 'package:openchat_frontend/views/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// ignore: constant_identifier_names
enum Region { CN, Global }

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

bool isValidVerification(String verify) {
  return RegExp(r'^[0-9]{6}$').hasMatch(verify);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginMode { login, register, reset }

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController verifycodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController inviteCodeController = TextEditingController();

  late Future<RepositoryConfig?> _regionAndUserData;

  LoginMode _loginMode = LoginMode.login;

  @override
  void initState() {
    final token = context.read<AccountProvider>().token;
    if (token == null) {
      _regionAndUserData = Repository.getInstance().getConfiguration();
    } else {
      _regionAndUserData = Provider.of<AccountProvider>(context, listen: false)
          .fetchUserInfo()
          .then((value) => null);
    }
    super.initState();
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    verifycodeController.dispose();
    inviteCodeController.dispose();
    super.dispose();
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
      case Region.Global:
        return emailField(context);
      case Region.CN:
        return phoneField(context);
    }
  }

  Future<JWToken?> Function(String, String) autoLoginFunc(Region region) {
    switch (region) {
      case Region.Global:
        return Repository.getInstance().loginWithEmailPassword;
      case Region.CN:
        return Repository.getInstance().loginWithPhonePassword;
    }
  }

  Future<JWToken?> Function(String, String, String, String,
      {required bool resetPassword}) autoSignupFunc(Region region) {
    switch (region) {
      case Region.Global:
        return Repository.getInstance().registerWithEmailPassword;
      case Region.CN:
        return Repository.getInstance().registerWithPhonePassword;
    }
  }

  Future<void> Function(String, String) autoRequestVerifyFunc(Region region) {
    switch (region) {
      case Region.Global:
        return Repository.getInstance().requestEmailVerifyCode;
      case Region.CN:
        return Repository.getInstance().requestPhoneVerifyCode;
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

  final lpformKey = GlobalKey<FormState>();
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
              key: lpformKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const SizedBox(height: 45),
                    TextButton(
                        onPressed: () => setState(() {
                              _loginMode = LoginMode.register;
                            }),
                        child: Text(AppLocalizations.of(context)!.sign_up)),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => setState(() {
                              _loginMode = LoginMode.reset;
                            }),
                        child:
                            Text(AppLocalizations.of(context)!.resetpassword)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        child: Text(AppLocalizations.of(context)!.sign_in),
                        onPressed: () async {
                          if (!lpformKey.currentState!.validate()) {
                            return;
                          }
                          try {
                            await showLoadingDialogUntilFutureCompletes<
                                    JWToken?>(
                                context,
                                autoLoginFunc(region)(accountController.text,
                                    passwordController.text));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(parseError(e), maxLines: 3)));
                          }
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final suformKey = GlobalKey<FormState>();
  Widget buildSignupPanel(
      BuildContext context, Region region, bool inviteRequired) {
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
              _loginMode == LoginMode.register
                  ? AppLocalizations.of(context)!.sign_up
                  : AppLocalizations.of(context)!.resetpassword,
              style: const TextStyle(fontSize: 35),
            ),
            const SizedBox(height: 30),
            Form(
              key: suformKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const SizedBox(height: 20),
                    TextFormField(
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.verificationcode,
                            suffixIcon: VerifyCodeRequestButton(
                              onTap: () {
                                return autoRequestVerifyFunc(region)(
                                    accountController.text, _loginMode.name);
                              },
                            )),
                        controller: verifycodeController,
                        validator: (value) => isValidVerification(value ?? '')
                            ? null
                            : AppLocalizations.of(context)!
                                .please_enter_verify_code),
                    const SizedBox(height: 20),
                    if (_loginMode == LoginMode.register && inviteRequired)
                      TextFormField(
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.invitecode,
                          ),
                          controller: inviteCodeController),
                    const SizedBox(height: 30),
                    TextButton(
                        onPressed: () => setState(() {
                              _loginMode = LoginMode.login;
                            }),
                        child: Text(AppLocalizations.of(context)!.sign_in)),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => setState(() {
                              _loginMode == LoginMode.register
                                  ? _loginMode = LoginMode.reset
                                  : _loginMode = LoginMode.register;
                            }),
                        child: Text(_loginMode == LoginMode.register
                            ? AppLocalizations.of(context)!.resetpassword
                            : AppLocalizations.of(context)!.sign_up)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        child: Text(_loginMode == LoginMode.register
                            ? AppLocalizations.of(context)!.sign_up
                            : AppLocalizations.of(context)!.resetpassword),
                        onPressed: () async {
                          if (!suformKey.currentState!.validate()) {
                            return;
                          }
                          try {
                            await showLoadingDialogUntilFutureCompletes<
                                    JWToken?>(
                                context,
                                autoSignupFunc(region)(
                                    accountController.text,
                                    passwordController.text,
                                    verifycodeController.text,
                                    inviteCodeController.text,
                                    resetPassword:
                                        _loginMode == LoginMode.reset));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(parseError(e), maxLines: 3)));
                          }
                        }),
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
    return FutureBuilder<RepositoryConfig?>(
      future: _regionAndUserData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return buildLandingPage(context, error: snapshot.error);
        } else if (snapshot.hasData) {
          return AnimatedCrossFade(
            firstChild: buildLoginPanel(context, snapshot.data!.region),
            secondChild: buildSignupPanel(
                context, snapshot.data!.region, snapshot.data!.inviteRequired),
            crossFadeState: _loginMode == LoginMode.login
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return buildLandingPage(context,
              error: "Invalid Server-side Configuration");
        } else {
          return buildLandingPage(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: kTabletSingleContainerWidth,
              height: 800,
              child: Card(
                surfaceTintColor: Colors.transparent,
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
      return Scaffold(body: buildContent(context));
    }
  }
}

class VerifyCodeRequestButton extends StatefulWidget {
  final Future<void> Function() onTap;
  const VerifyCodeRequestButton({super.key, required this.onTap});

  @override
  VerifyCodeRequestButtonState createState() => VerifyCodeRequestButtonState();
}

class VerifyCodeRequestButtonState extends State<VerifyCodeRequestButton> {
  bool _isRequesting = false;
  int countdown = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: _isRequesting
            ? null
            : () async {
                setState(() {
                  _isRequesting = true;
                });
                try {
                  await widget.onTap();
                  setState(() {
                    countdown = 60;
                  });
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                    setState(() {
                      countdown--;
                    });
                    if (countdown == 0) {
                      timer.cancel();
                      setState(() {
                        _isRequesting = false;
                      });
                    }
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(parseError(e), maxLines: 3)));
                  setState(() {
                    _isRequesting = false;
                  });
                }
              },
        child: Text(countdown > 0
            ? AppLocalizations.of(context)!.requested(countdown)
            : AppLocalizations.of(context)!.request));
  }
}
