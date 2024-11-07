import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // firebase_options.dart import 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // FirebaseOptions 추가
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirestoreTestPage(),
    );
  }
}

class FirestoreTestPage extends StatefulWidget {
  @override
  _FirestoreTestPageState createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addSampleData() async {
    await _firestore.collection('Users').add({
      'nickname': 'TestUser',
      'profile_image': 'https://example.com/profile.png',
      'groups': [],
      'memos': []
    });
  }

  Future<void> _getSampleData() async {
    QuerySnapshot snapshot = await _firestore.collection('Users').get();
    snapshot.docs.forEach((doc) {
      print('User ID: ${doc.id}');
      print('Nickname: ${doc['nickname']}');
      print('Profile Image: ${doc['profile_image']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _addSampleData,
              child: Text('Add Sample Data to Firestore'),
            ),
            ElevatedButton(
              onPressed: _getSampleData,
              child: Text('Get Data from Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
