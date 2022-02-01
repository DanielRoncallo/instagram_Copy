import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insta_test/models/user.dart' as model;
import 'package:insta_test/resources/storage_methods.dart';

class AuthMethods {
  //instacian de la clase auth de firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async{
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('usuarios').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //sign up del usuario
  //funcion asincronica
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    //Una lista de longitud fija de enteros sin signo de 8 bits.
    required Uint8List file,
  }) async {
    String res = "Un error ha ocurrido";

    try {
      //verifica que ningun campo este vacio
      if (email.isNotEmpty ||
              password.isNotEmpty ||
              username.isNotEmpty ||
              bio.isNotEmpty /*||
          file != null*/
          ) {
        //registro el usuario
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        //user.uid es el identificador del usuario.
        //ponemos ! en user porque este puede ser nulo
        print(cred.user!.uid);
        //sube la imagen al storage
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl
        );  

        //añadir usuario a la base de datos
        await _firestore.collection('usuarios').doc(cred.user!.uid).set(user.toJson(),);
        //otro metodo, no se usa porque tiene uid diferentes
        /* await _firestore.collection('usuarios').add({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
        });*/

        res = 'Exito';
      }
    } on FirebaseAuthException catch (err) {
      //res = err.toString();
      if (err.code == 'invalid-email') {
        res = 'Correo no valido';
      } else if (err.code == 'weak-password') {
        res = 'La contraseña debe tener al menos 6 caracteres';
      }
    }
    return res;
  }

  //Login del usuario
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Ocurrio un error';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'exito';
      }else{
        res = 'Por favor rellene todos los campos';
      }
    } on FirebaseAuthException catch (err) {
      //res = err.toString();
      if (err.code == 'invalid-email') {
        res = 'Correo no valido';
      } else if (err.code == 'weak-password') {
        res = 'La contraseña debe tener al menos 6 caracteres';
      }
    }
    return res;
  }
}
