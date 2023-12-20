import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/repository.dart';

import '../constants.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  final _displayNameFieldController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _displayNameFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppTitle),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Insets.medium),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Créez votre compte Superchat',
                        style: theme.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Insets.extraLarge),
                      const Text(
                        "Nom d'affichage",
                        textAlign: TextAlign.center,
                      ),
                      TextFormField(
                        controller: _displayNameFieldController,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          hintText: "Nom d'affichage",
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            value != null ? null : 'invalid displayName',
                      ),
                      const SizedBox(height: Insets.medium),
                      const Text(
                        'Email',
                        textAlign: TextAlign.center,
                      ),
                      TextFormField(
                        controller: _emailFieldController,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            value != null && EmailValidator.validate(value)
                                ? null
                                : 'Email invalide',
                      ),
                      const SizedBox(height: Insets.medium),
                      const Text(
                        'Mot de passe',
                        textAlign: TextAlign.center,
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return TextFormField(
                            controller: _passwordFieldController,
                            autofillHints: const [AutofillHints.password],
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                                icon: _showPassword
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                          );
                        },
                      ),
                      const SizedBox(height: Insets.medium),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _signUp(),
                          child: const Text('S\'inscrire'),
                        ),
                      ),
                      const SizedBox(height: Insets.medium),
                      const Text(
                        'Vous avez déjà un compte ?',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const SignInPage())),
                        child: const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailFieldController.text.trim(),
          password: _passwordFieldController.text.trim(),
        );

        if (credential.user != null) {
          final String displayName = _displayNameFieldController.text.trim();
          Repository.createUser(credential.user!, displayName);
        }

        if (credential.user != null) {
          navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()));
        }
      } on FirebaseAuthException catch (e, stackTrace) {
        final String errorMessage;

        if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Cet email est déjà associé à un compte existant.';
        } else {
          errorMessage = 'Une erreur est survenue.';
        }

        log(
          'Error while signing in: ${e.code}',
          error: e,
          stackTrace: stackTrace,
          name: 'SignInPage',
        );
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}
