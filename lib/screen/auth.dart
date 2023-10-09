import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';
  bool _isSubmit = false;
  File? _pickedImage;

  void _submit() async {
    final validate = _form.currentState!.validate();

    if (!validate || (!_isLogin && _pickedImage == null)) return;

    setState(() => _isSubmit = true);

    _form.currentState!.save();

    try {
      if (_isLogin) {
        final createdUser = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final createdUser = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final imageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${createdUser.user!.uid}.jpg');

        await imageRef.putFile(_pickedImage!);
        final imageUrl = await imageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(createdUser.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Authentiaction failed'),
          ),
        );
      }
    }

    setState(() {
      _isSubmit = false;
    });
  }

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
                    key: _form,
                    child: Column(
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: (selectedImage) {
                              setState(() {
                                _pickedImage = selectedImage;
                              });
                            },
                          ),
                        TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            label: Text('Email Address'),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Email not valid. Please enter valid email';
                            }

                            return null;
                          },
                          onSaved: (newValue) {
                            if (newValue == null) return;

                            _enteredEmail = newValue;
                          },
                        ),
                        if (!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Username'),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 3) {
                                return 'Username must be greather than 3 word';
                              }

                              return null;
                            },
                            onSaved: (newValue) {
                              if (newValue == null) return;

                              _enteredUsername = newValue;
                            },
                          ),
                        TextFormField(
                          autocorrect: false,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be greather than 6 characters';
                            }

                            return null;
                          },
                          onSaved: (newValue) {
                            if (newValue == null) return;

                            _enteredPassword = newValue;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          onPressed: _submit,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (_isSubmit)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                child: const CircularProgressIndicator(),
                              ),
                            Text(_isLogin ? 'Sign in' : 'Sign up')
                          ]),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create new account'
                              : 'Already have account, Sign in'),
                        )
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
