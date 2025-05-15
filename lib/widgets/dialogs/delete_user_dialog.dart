import 'package:flutter/material.dart';
import 'package:workgest/managers/user_manager.dart';


class DeleteUser extends StatefulWidget {
  final String userId;

  const DeleteUser({super.key, required this.userId});

  @override
  DeleteUserState createState() => DeleteUserState();
}
class DeleteUserState extends State<DeleteUser> {
  @override
  Widget build(BuildContext context) {
    double dialogPadding = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: dialogPadding, vertical: dialogPadding),
      title: Text(
        '¿Desea borrar el usuario?',
        style: TextStyle(fontSize: fontSize),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await UserManager().deleteUserById(widget.userId, context);
          },
          child: Text(
            'Borrar',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancelar',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}