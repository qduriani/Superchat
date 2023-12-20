import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superchat/users/user_model.dart';

class Repository {
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<UserModel?> getUser(String currentUserId) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot =
        await collection.where('id', isEqualTo: currentUserId).get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return UserModel.fromFirestore(doc.data());
    } else {
      return null;
    }
  }

  static Future<List<UserModel>> getUsers(String currentUserId) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot =
        await collection.where('id', isNotEqualTo: currentUserId).get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data()))
        .toList();
  }

  static Future createUser(User user, String displayName) async {
    // Créer un objet UserModel avec les informations de l'utilisateur
    UserModel userModel = UserModel(
      id: user.uid,
      displayName: displayName,
      bio: '', // Ajoutez d'autres champs si nécessaire
    );

    // Convertir l'objet UserModel en une carte JSON
    Map<String, dynamic> userData = userModel.toJson();

    // Ajouter l'utilisateur à la collection "users" dans Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData);
  }

  static Stream<List<Map<String, dynamic>>> fetchMessages(
      String from, String to) {
    var collection = FirebaseFirestore.instance.collection('messages');
    return collection
        .where(Filter.or(
            Filter.and(
                Filter('from', isEqualTo: from), Filter('to', isEqualTo: to)),
            Filter.and(
                Filter('from', isEqualTo: to), Filter('to', isEqualTo: from))))
        .snapshots()
        .map((event) => event.docs.map((doc) => doc.data()).toList());
  }

  static void sendMessage(Map<String, dynamic> message) {
    var collection = FirebaseFirestore.instance.collection('messages');
    collection.add(message);
  }
}
