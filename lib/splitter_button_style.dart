import 'package:flutter/material.dart';

final ButtonStyle redOutlineButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: Colors.redAccent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
  side: BorderSide(
      width: 2,
      color: Colors.red
  ),
);

final ButtonStyle greenOutlineButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: Colors.greenAccent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
  side: BorderSide(
      width: 2,
      color: Colors.green
  ),
);

final ButtonStyle smallCyanElevatedButtonStyle = ElevatedButton.styleFrom(
  primary: Colors.cyan[300],
  minimumSize: Size(60,40),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25),
  ),
  elevation: 4,
);