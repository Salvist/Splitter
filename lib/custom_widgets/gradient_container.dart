import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class GradientContainer extends StatelessWidget{
  final Widget child;
  final double width;
  final double height;
  final Gradient gradient;

  const GradientContainer({
    Key key,
    this.child,
    this.width,
    this.height,
    this.gradient
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF65ACF0), Color(0xFF2685F0)] //0xFF4ADEDE + 0xFF787FF6 || 0xFF1F2F98
        ),
      ),
      child: child
    );
  }
}