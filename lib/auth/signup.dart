import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool visible = true;
  String? _username, _email, _password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  signUp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await auth.createUserWithEmailAndPassword(
            email: _email.toString(), password: _password.toString());
        addUser();
        AwesomeDialog(
            context: context,
            title: 'Done !',
            desc: 'Signed up successfully',
            dialogType: DialogType.SUCCES,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            btnOkOnPress: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed('home');
            }).show();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'weak-password':
            {
              errorMessage(
                      title: 'Weak Passowrd',
                      sub: 'The password provided is too weak.')
                  .show();
              break;
            }
          case 'email-already-in-use':
            {
              errorMessage(
                      title: 'Email is already in use',
                      sub: 'The account already exists for that email.')
                  .show();
              break;
            }
        }
      } catch (e) {
        errorMessage(title: 'Error', sub: e.toString()).show();
      }
    } else {
      errorMessage(title: 'Something went wrong', sub: 'Invalid information')
          .show();
    }
  }

  addUser() async {
    await users.add({
      'username': _username,
      'email': _email,
      'useruid': auth.currentUser?.uid,
    }).catchError((e) async =>
        await errorMessage(title: 'Failed to add user', sub: e.toString())
            .show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        Image.asset(
          'images/pheonix.png',
          height: 200,
          width: 300,
          fit: BoxFit.fill,
        ),
        Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.length <= 2) {
                        return 'Username can\'t be this short';
                      }
                      return null;
                    },
                    onSaved: ((newValue) {
                      _username = newValue;
                    }),
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Username',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onSaved: (newValue) {
                      _email = newValue;
                    },
                    validator: (value) {
                      if (value!.contains('@') == false ||
                          value.endsWith(".com") == false) {
                        return 'Email is not valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.email_outlined),
                        hintText: 'Email',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onSaved: (newValue) {
                      _password = newValue;
                    },
                    validator: (value) {
                      if (value!.length <= 4) {
                        return 'Password is too short';
                      }
                      return null;
                    },
                    obscureText: visible,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.lock_outline),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                visible = !visible;
                              });
                            },
                            icon: visible == true
                                ? const Icon(Icons.visibility_off_outlined)
                                : const Icon(Icons.visibility_outlined)),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(width: 5))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        signUp();
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('You have account ?'),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('sign in');
                          },
                          child: const Text('Click here')),
                    ],
                  )
                ],
              ),
            ))
      ]),
    );
  }

  AwesomeDialog errorMessage({String? title, String? sub}) {
    return AwesomeDialog(
        context: context,
        title: title,
        desc: sub,
        dialogType: DialogType.ERROR,
        btnCancelOnPress: () {});
  }
}
