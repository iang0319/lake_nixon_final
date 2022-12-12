import 'package:final_project/GroupPage.dart';
import 'package:final_project/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> groupPagePush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupPage(title: "List of groups"),
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> logoutScreenPush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Home Page",
              style: TextStyle(fontFamily: 'Fruit', color: Colors.white),
            )),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Welcome to Lake Nixon!',
                      style: TextStyle(
                          //nixonblue
                          color: Color.fromRGBO(165, 223, 249, 1),
                          fontFamily: 'Fruit',
                          fontWeight: FontWeight.w500,
                          fontSize: 35),
                    )),
                Container(
                    child: const Image(
                  image: AssetImage('images/lakenixonlogo.png'),
                  height: 400,
                )),
                Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(nixongreen)),
                        child: const Text(
                          'Select Group',
                          style: TextStyle(fontSize: 60, fontFamily: 'Fruit'),
                        ),
                        onPressed: () {
                          groupPagePush();
                        },
                      ),
                    )),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(nixonbrown),
                    ),
                    child: const Text("Logout"),
                    onPressed: () {
                      logout();
                      logoutScreenPush();
                    },
                  ),
                ),
              ],
            )));
  }
}
