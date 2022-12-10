import 'dart:developer';

import 'package:final_project/calender_page.dart';
import 'package:final_project/globals.dart';
import 'package:final_project/signup_page.dart';
import 'package:final_project/start_page.dart';
import 'package:final_project/userScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'GroupPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() {
    if (FirebaseAuth.instance.currentUser != null) {
      //groupPagePush();
      startPagePush();
    }
  }

  Future<void> startPagePush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UserSplashScreen()),
    );
    //await Navigator.of(context).push(
    //MaterialPageRoute(builder: (context) => const StartPage()),
    //);
  }

  // Future<void> groupPagePush() async {
  //   await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => GroupPage(title: "List of groups"),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Image(
                        image: AssetImage('images/lakenixonlogo.png'))

                    // const Text(
                    //   'Lake Nixon',
                    //   style: TextStyle(
                    //       color: Colors.blue,
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 30),
                    // )

                    ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-mail',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  child: const Text(
                    'Forgot Password',
                  ),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(nixongreen)),
                      child: const Text('Login'),
                      onPressed: () async {
                        try {
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text);
                          //await Navigator.of(context).push(MaterialPageRoute(
                          //builder: (context) =>
                          //  GroupPage(title: "List of groups"),
                          //));
                          // startPagePush();
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }
                        }
                        print(emailController.text);
                        print(passwordController.text);
                        login();
                      },
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Do not have account?'),
                    TextButton(
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ));
                      },
                    )
                  ],
                ),
              ],
            )));
  }
}
