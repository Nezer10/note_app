import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool visible = true;
  String? _email, _password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  signIn() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await auth.signInWithEmailAndPassword(
            email: _email.toString(), password: _password.toString());
        AwesomeDialog(
            context: context,
            title: 'Welcome back !',
            desc: 'Signed in successfully',
            dialogType: DialogType.SUCCES,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            btnOkOnPress: () {
              Navigator.of(context).pushReplacementNamed('home');
            }).show();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'user-not-found':
            {
              errorMessage(
                      title: 'User not found !',
                      sub: 'No user found for that email.')
                  .show();
              break;
            }
          case 'wrong-password':
            {
              errorMessage(
                      title: 'Wrong password !',
                      sub: 'Wrong password provided for that user.')
                  .show();
              break;
            }
        }
      }
    } else {
      errorMessage(title: 'Something went wrong !', sub: 'Invalid information')
          .show();
    }
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
                    onSaved: (newValue) {
                      _email = newValue!.trim();
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
                    obscureText: visible,
                    onSaved: (newValue) {
                      _password = newValue;
                    },
                    validator: (value) {
                      if (value!.length <= 4) {
                        return 'Password is too short';
                      }
                      return null;
                    },
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
                        signIn();
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('You don\'t have account ?'),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('sign up');
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
