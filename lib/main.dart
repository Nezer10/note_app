import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app/auth/signin.dart';
import 'package:note_app/auth/signup.dart';
import 'package:note_app/crud/addnote.dart';
import 'package:note_app/home.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? userState() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {});
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: userState() == null ? const SignIn() : const Home(),
      debugShowCheckedModeBanner: false,
      routes: {
        'sign in': (context) => const SignIn(),
        'sign up': (context) => const SignUp(),
        'home': (context) => const Home(),
        'add': (context) => const AddNote(),
      },
    );
  }
}
