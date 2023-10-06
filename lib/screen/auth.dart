import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            label: Text('Email Adrres'),
                          ),
                        ),
                        TextFormField(
                          autocorrect: false,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
