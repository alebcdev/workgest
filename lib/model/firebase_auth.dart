import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireAuth{

  static Future<User?> signInUsingEmailAndPass({
    required String email,
    required String password,
  }) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      user = userCredential.user;

    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        print('Usuario no encontrado');
      }else if(e.code == 'wrong-password'){
        print('contraseña incorrecta');
      }
    }
    return user;
  }

  static Future<User?> signUpUsingEmailAndPass({
    required String name,
    required String email,
    required String password
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      user = userCredential.user;

      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;

    }on FirebaseAuthException catch(e){
      if (e.code == 'weak-password'){
        const Text('Warning: Weak password');
      }else if (e.code == 'email-already-in-use'){
      }
    }catch (e){
      print(e);
    }
    return user;
  }
}