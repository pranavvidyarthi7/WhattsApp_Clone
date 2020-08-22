import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/roundedButton.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_screen.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                colour: Colors.blueAccent,
                title: 'REGISTER',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      _firestore
                          .collection('data')
                          .document('user')
                          .collection(email);
                      _firestore.collection('user').document(email).setData({
                        'sender': email,
                        'uid': newUser.user.uid,
                      });
                      final users =
                          await _firestore.collection('user').getDocuments();
                      for (var user in users.documents) {
                        if (user.data()['sender'] != email)
                          _firestore
                              .collection('user')
                              .document(email)
                              .collection(email)
                              .document(user.data()['uid'])
                              .set({
                            'sender': user.data()['sender'],
                            'message': null,
                          });
                        _firestore
                            .collection('user')
                            .document(user.data()['sender'])
                            .collection(user.data()['sender'])
                            .document(newUser.user.uid)
                            .setData({
                          'sender': email,
                          'message': null,
                        });
                      }

                      Navigator.pushNamed(context, MessagePage.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    if (e is PlatformException) {
                      print(e);
                      if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
