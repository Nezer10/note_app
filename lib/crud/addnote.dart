import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key}) : super(key: key);

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController txt = TextEditingController();
  XFile? file;
  ImagePicker pick = ImagePicker();
  String? _title, _desc, _url;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseStorage store = FirebaseStorage.instance;
  String? uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
      ),
      body: ListView(children: [
        Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    onSaved: (newValue) {
                      _title = newValue;
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5)),
                        labelText: 'Title'),
                    maxLength: 30,
                  ),
                  TextFormField(
                    controller: txt,
                    onSaved: (newValue) {
                      _desc = newValue;
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.note),
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5))),
                    keyboardType: TextInputType.multiline,
                    maxLines: double.maxFinite.ceil(),
                    minLines: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            modal();
                            setState(() {});
                          },
                          child: const Text('Add Image')),
                      ElevatedButton(
                          onPressed: () async {
                            if (file == null) {
                              AwesomeDialog(
                                      context: context,
                                      title: 'Warning !',
                                      desc: 'Please pick an image first',
                                      dialogType: DialogType.ERROR,
                                      btnCancelOnPress: () {})
                                  .show();
                            } else {
                              _formKey.currentState!.save();
                              try {
                                TaskSnapshot upload = await store
                                    .ref(file!.name)
                                    .putFile(File(file!.path));
                                _url = await upload.ref.getDownloadURL();
                              } on FirebaseException catch (e) {
                                AwesomeDialog(
                                    context: context,
                                    title: '$e',
                                    btnCancelOnPress: () {},
                                    dialogType: DialogType.ERROR);
                              }
                              await notes.add({
                                'title': _title,
                                'description': _desc,
                                'useruid': uid,
                                'image': _url,
                              });
                              AwesomeDialog(
                                  context: context,
                                  title: 'Done !',
                                  desc: 'Your note has been saved successfully',
                                  dialogType: DialogType.SUCCES,
                                  btnOkOnPress: () {
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                    Navigator.of(context)
                                        .pushReplacementNamed('home');
                                  }).show();
                            }
                          },
                          child: const Text('Save')),
                    ],
                  ),
                  file == null
                      ? const Center(
                          heightFactor: 5,
                          child: Text(
                            'No image yet',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        )
                      : Image.file(
                          File(file!.path),
                          height: 300,
                          width: 300,
                        ),
                ],
              ),
            ))
      ]),
    );
  }

  modal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Select an Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    file = await pick.pickImage(source: ImageSource.camera);
                    setState(() {});
                  },
                  child: Row(
                    children: const [Icon(Icons.camera), Text('  Camera')],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    file = await pick.pickImage(source: ImageSource.gallery);
                    setState(() {});
                  },
                  child: Row(
                    children: const [Icon(Icons.image), Text('  Gallery')],
                  ),
                )
              ],
            ),
          );
        });
  }
}
