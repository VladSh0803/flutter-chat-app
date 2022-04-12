import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class DBService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static Future<void> sendMessage(
      CollectionReference chatRef, String text, String uid,
      {String? imageURL}) async {
    await chatRef.add(
      {
        'text': text,
        'sender_uid': uid,
        'image_url': imageURL ?? '',
        'time': FieldValue.serverTimestamp(),
      },
    );
    if ((await chatRef.parent!.get()).get('last_sender_uid') != uid) {
      await chatRef.parent!.update(
        {'last_sender_uid': uid},
      );
    }
  }

  static Future<void> sendMessageViewed(CollectionReference chatRef) async {
    await chatRef.parent!.update(
      {'last_sender_uid': ''},
    );
  }

  static Future<String?> sendImage(String uid) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        String fileName =
            'images/img_${uid}_${DateTime.now().millisecondsSinceEpoch.toString()}';
        if (kIsWeb) {
          await _storage.ref(fileName).putData(await image.readAsBytes());
        } else {
          final file = File(image.path);
          await _storage.ref(fileName).putFile(file);
        }
        return await _storage.ref(fileName).getDownloadURL();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return await null;
    }
  }

  static Future<void> addUser(
      String uid, String displayName, String email, String photoURL) async {
    if (kIsWeb) {
      await _db.enablePersistence();
    } else {
      _db.settings = const Settings(persistenceEnabled: true);
    }
    _db.collection('users').doc(uid).set(
      {
        'name': displayName,
        'email': email,
        'photoURL': photoURL,
      },
    );
  }

  static Stream<DocumentSnapshot> getUserInfoByUid(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  static Future<String?> getUserUidByEmail(String email) async {
    QuerySnapshot snapshot = await _db
        .collection('users')
        .where(
          'email',
          isEqualTo: email,
        )
        .get();
    String? id = snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
    return id;
  }

  static Stream<QuerySnapshot> getMessages(CollectionReference chatRef) {
    return chatRef.orderBy('time', descending: true).snapshots();
  }

  static Stream<QuerySnapshot> getUserChats(String uid) {
    return _db
        .collection('chats')
        .where('contacts', arrayContains: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserInfoExceptCurrent(
      List<String> uids, String currentUid) {
    return _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .where(FieldPath.documentId, isNotEqualTo: currentUid)
        .snapshots();
  }

  static Future<DocumentReference> getChat(List<String> uids) async {
    QuerySnapshot snapshot = await _db
        .collection('chats')
        .where(
          'contacts',
          isEqualTo: uids,
        )
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.reference;
    } else {
      return await _db.collection('chats').add(
        {
          'contacts': uids,
          'last_sender_uid': '',
        },
      );
    }
  }

  static CollectionReference getChatMessages(DocumentReference doc) {
    return doc.collection('messages');
  }
}
