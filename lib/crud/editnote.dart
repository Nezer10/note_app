import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class EditNote extends StatefulWidget {
  const EditNote({Key? key, this.title, this.desc, this.img, this.docid})
      : super(key: key);
  final String? title;
  final String? desc;
  final String? img;
  final String? docid;
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  XFile? file;
  ImagePicker pick = ImagePicker();
  String? _title, _desc, _url;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseStorage store = FirebaseStorage.instance;
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  update() async {
    if (file == null) {
      _formKey.currentState!.save();
      await notes.doc(widget.docid).update({
        'title': _title,
        'description': _desc,
      });
      AwesomeDialog(
          context: context,
          title: 'Done !',
          desc: 'Your note has been edited successfully',
          dialogType: DialogType.SUCCES,
          btnOkOnPress: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacementNamed('home');
          }).show();
    } else {
      _formKey.currentState!.save();
      try {
        TaskSnapshot upload =
            await store.ref(file!.name).putFile(File(file!.path));
        _url = await upload.ref.getDownloadURL();
      } on FirebaseException catch (e) {
        AwesomeDialog(
            context: context,
            title: '$e',
            btnCancelOnPress: () {},
            dialogType: DialogType.ERROR);
      }

      await notes.doc(widget.docid).update({
        'title': _title,
        'description': _desc,
        'image': _url,
      });
      AwesomeDialog(
          context: context,
          title: 'Done !',
          desc: 'Your note has been edited successfully',
          dialogType: DialogType.SUCCES,
          btnOkOnPress: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacementNamed('home');
          }).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
      ),
      body: ListView(children: [
        Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    onSaved: (newValue) => _title = newValue,
                    initialValue: widget.title,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5)),
                        labelText: 'Title'),
                    maxLength: 30,
                  ),
                  TextFormField(
                    onSaved: (newValue) => _desc = newValue,
                    initialValue: widget.desc,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.note),
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 5))),
                    maxLength: 200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            modal();
                            setState(() {});
                          },
                          child: const Text('Edit Image')),
                      ElevatedButton(
                          onPressed: () {
                            update();
                          },
                          child: const Text('Save')),
                    ],
                  ),
                  file == null
                      ? Image.network(
                          widget.img.toString(),
                          height: 300,
                          width: 300,
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
