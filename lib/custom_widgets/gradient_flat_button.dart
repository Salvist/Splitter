import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientFlatButton extends StatelessWidget{
  final Widget child;
  final double width;
  final Gradient gradient;
  final Function onPressed;

  const GradientFlatButton({
    Key key,
    @required this.child,
    this.width = 200,
    this.gradient,
    @required this.onPressed
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 3),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)]
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Color(0xFF5B86E5),
            onTap: onPressed,
            child: Center(
                child: child
            )
        ),
      ),
    );
  }
}