import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/crud/editnote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  String? uid = FirebaseAuth.instance.currentUser!.uid;
  refresh() async {
    return await notes.where('useruid', isEqualTo: uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed('sign in');
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: notes.where('useruid', isEqualTo: uid).get(),
            builder: (context, AsyncSnapshot? snapshot) {
              if (snapshot!.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(
                    child: Text(
                  'There isn\'t a note to show yet',
                  style: TextStyle(fontSize: 25),
                ));
              }
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, i) {
                    return tileNote(
                        title: "${snapshot.data.docs[i]['title']}",
                        desc: "${snapshot.data.docs[i]['description']}",
                        url: "${snapshot.data.docs[i]['image']}",
                        id: "${snapshot.data.docs[i].id}");
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget tileNote({String? title, String? desc, String? url, String? id}) {
    return Dismissible(
        onDismissed: ((direction) async {
          await notes.doc(id).delete();
          await FirebaseStorage.instance.refFromURL(url.toString()).delete();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Your note has been deleted successfully"),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
            backgroundColor: Colors.blueAccent,
          ));
        }),
        key: UniqueKey(),
        background: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(
                  Icons.delete,
                  size: 30,
                ),
                Icon(
                  Icons.delete,
                  size: 30,
                ),
              ],
            )),
        child: Card(
          child: ListTile(
            leading: Image.network(
              url.toString(),
              fit: BoxFit.fill,
            ),
            title: Text(title.toString()),
            subtitle: Text(desc.toString()),
            trailing: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => EditNote(
                            title: title,
                            desc: desc,
                            img: url,
                            docid: id,
                          ))));
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.green[500],
                )),
          ),
        ));
  }
}
