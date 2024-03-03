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

bool isFudanEmail(String email) {
  return isValidEmail(email) && email.endsWith("fudan.edu.cn");
}

bool isValidCNPhoneNumber(String phone) {
  return RegExp(r'^[0-9]{11}$').hasMatch(phone);
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
  bool _noticeAccepted = false;

  @override
  void initState() {
    final token = context.read<AccountProvider>().token;
    if (token == null) {
      _regionAndUserData = Repository.getInstance().getConfiguration();
    } else {
      _regionAndUserData =
          AccountProvider.getInstance().fetchUserInfo().then((value) => null);
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

  Widget accountField(BuildContext context, Region region,
      {bool login = true}) {
    TextInputType keyboard;
    String labelText;
    if (login) {
      keyboard = TextInputType.emailAddress;
      labelText = AppLocalizations.of(context)!.account;
    } else if (region == Region.CN) {
      keyboard = TextInputType.url;
      labelText = AppLocalizations.of(context)!.phone_number_or_fudan;
    } else {
      keyboard = TextInputType.emailAddress;
      labelText = AppLocalizations.of(context)!.email;
    }
    return TextFormField(
        keyboardType: keyboard,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        decoration: InputDecoration(
          labelText: labelText,
        ),
        validator: (value) {
          if (login) {
            return (isValidEmail(value!) || isValidCNPhoneNumber(value))
                ? null
                : AppLocalizations.of(context)!.please_enter_valid_account;
          }
          if (region == Region.CN) {
            return isValidCNPhoneNumber(value!) || isFudanEmail(value)
                ? null
                : AppLocalizations.of(context)!
                    .please_enter_valid_phone_or_fudan;
          } else {
            return isValidEmail(value!)
                ? null
                : AppLocalizations.of(context)!.please_enter_valid_email;
          }
        },
        controller: accountController);
  }

  Future<JWToken?> Function(String, String) autoLoginFunc(Region region) {
    if (isValidEmail(accountController.text)) {
      return Repository.getInstance().loginWithEmailPassword;
    } else {
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

  Future<void> Function(String, String, String) autoRequestVerifyFunc(
      Region region) {
    switch (region) {
      case Region.Global:
        return Repository.getInstance().requestEmailVerifyCode;
      case Region.CN:
        return Repository.getInstance().requestPhoneVerifyCode;
    }
  }

  Widget buildNoticePanel(BuildContext context, String notice) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/images/logo.webp', scale: 6.5),
            const SizedBox(height: 40),
            Opacity(
              opacity: 0.7,
              child: Text(
                notice,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    onPressed: () => setState(() {
                          _noticeAccepted = true;
                        }),
                    child: Text(AppLocalizations.of(context)!.ok))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildLandingPage(BuildContext context, {Object? error}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/images/logo.webp', scale: 6.5),
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
                    : parseError(error),
                maxLines: 3,
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
            Image.asset('assets/images/logo.webp', scale: 6.5),
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
                    accountField(context, region),
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
                            await AccountProvider.getInstance()
                                .ensureUserInfo();
                          } catch (e) {
                            await showAlert(context, parseError(e),
                                AppLocalizations.of(context)!.error);
                          }
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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
            Image.asset('assets/images/logo.webp', scale: 6.5),
            const SizedBox(height: 25),
            Text(
              _loginMode == LoginMode.register
                  ? AppLocalizations.of(context)!.sign_up
                  : AppLocalizations.of(context)!.resetpassword,
              style: const TextStyle(fontSize: 35),
            ),
            if (_loginMode == LoginMode.register && inviteRequired)
              Opacity(
                opacity: 0.7,
                child: Text(
                  AppLocalizations.of(context)!.fudan_no_invite,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            const SizedBox(height: 30),
            Form(
              key: suformKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    accountField(context, region, login: false),
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
                    if (_loginMode == LoginMode.register && inviteRequired)
                      TextFormField(
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.invitecode),
                          controller: inviteCodeController,
                          validator: (value) => value!.isEmpty &&
                                  !isFudanEmail(accountController.text)
                              ? AppLocalizations.of(context)!
                                  .please_enter_valid_invite_code
                              : null),
                    const SizedBox(height: 20),
                    TextFormField(
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.verificationcode,
                            suffixIcon: VerifyCodeRequestButton(
                              onTap: () async {
                                if (inviteRequired &&
                                    inviteCodeController.text.isEmpty &&
                                    _loginMode == LoginMode.register) {
                                  await showAlert(
                                      context,
                                      AppLocalizations.of(context)!
                                          .please_enter_valid_invite_code,
                                      AppLocalizations.of(context)!.error);
                                  return false;
                                }
                                await autoRequestVerifyFunc(region)(
                                    accountController.text,
                                    _loginMode.name,
                                    inviteCodeController.text);
                                return true;
                              },
                            )),
                        controller: verifycodeController,
                        validator: (value) => isValidVerification(value ?? '')
                            ? null
                            : AppLocalizations.of(context)!
                                .please_enter_verify_code),
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
                            await AccountProvider.getInstance()
                                .ensureUserInfo();
                          } catch (e) {
                            await showAlert(context, parseError(e),
                                AppLocalizations.of(context)!.error);
                          }
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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
          if (snapshot.data!.notice == null || snapshot.data!.notice!.isEmpty) {
            _noticeAccepted = true;
          }
          return AnimatedCrossFade(
            firstChild: buildNoticePanel(context, snapshot.data!.notice ?? ""),
            secondChild: AnimatedCrossFade(
              firstChild: buildLoginPanel(context, snapshot.data!.region),
              secondChild: buildSignupPanel(context, snapshot.data!.region,
                  snapshot.data!.inviteRequired),
              crossFadeState: _loginMode == LoginMode.login
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
            crossFadeState: _noticeAccepted
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
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
        body: SafeArea(
          child: Padding(
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
        ),
      );
    } else {
      return Scaffold(body: SafeArea(child: buildContent(context)));
    }
  }
}

class VerifyCodeRequestButton extends StatefulWidget {
  final Future<bool> Function() onTap;
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
                  if (!await widget.onTap()) {
                    setState(() {
                      _isRequesting = false;
                    });
                    return;
                  }
                  setState(() {
                    countdown = 60;
                  });
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                    if (mounted) {
                      setState(() {
                        countdown--;
                      });
                      if (countdown == 0) {
                        timer.cancel();
                        setState(() {
                          _isRequesting = false;
                        });
                      }
                    } else {
                      timer.cancel();
                    }
                  });
                } catch (e) {
                  await showAlert(context, parseError(e),
                      AppLocalizations.of(context)!.error);
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
