import 'package:final_project/globals.dart';
import 'package:final_project/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:final_project/globals.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  //final _authService = await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
  //disposing all text controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  //
  //Future<void> confirmResetPassword() async {
  //await Navigator.of(context).push(
  //MaterialPageRoute(builder: (context) => const UserSplashScreen()),
  //);
  //await Navigator.of(context).push(
  //MaterialPageRoute(builder: (context) => const StartPage()),
  //);
  //}

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 50.0, bottom: 25.0),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  const Image(
                    image: AssetImage('images/lakenixonlogo.png'),
                    alignment: Alignment.centerRight,
                    height: 200,
                  ),
                  const SizedBox(height: 70),
                  const Text(
                    'Forgot Password?',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Fruit',
                      fontSize: 45,
                      //nixonbrown
                      color: Color.fromRGBO(137, 116, 73, 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email below to be sent a link to reset password.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Fruit',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-mail',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(nixongreen)),
                    onPressed: () async {
                      if (_emailController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Please enter an email",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else if (!_emailController.text.contains("@")) {
                        Fluttertoast.showToast(
                            msg: "Please enter an email with proper format",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        try {
                          FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _emailController.text);

                          print("Test");
                          /*
                          Fluttertoast.showToast(
                              msg: "Email sent to reset password",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                              */
                          //Navigator.pop(context);
                          //await Navigator.of(context).push(MaterialPageRoute(
                          //builder: (context) =>
                          //  GroupPage(title: "List of groups"),
                          //));
                          //startPagePush();
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            Fluttertoast.showToast(
                                msg: "User not found under that email address",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            print('No user found for that email.');
                          } else if (e.code == 'invalid-email') {
                            Fluttertoast.showToast(
                                msg: "Improper email format",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else if (e.code == 'internal-error') {
                            Fluttertoast.showToast(
                                msg: "Please input in email format",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                        Fluttertoast.showToast(
                            msg: "Email sent to reset password",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontFamily: 'Fruit', fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '(Note: Also check junk mailbox for link).',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
