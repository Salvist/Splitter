import 'package:flutter/material.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';

class SplitterAbout extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AboutTitle(),
                AboutText(),
                ElevatedButton(child: Text('Go back'), onPressed: (){Navigator.pop(context);})
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Text(
        'About',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}

class AboutText extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      //padding: EdgeInsets.only(left: 10, right: 10),
      child: RichText(textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 16),
          children: <TextSpan>[
            TextSpan(
              text: 'Splitter is an easy to use app to split your bill with your friends developed by Lone Dream Studio.\n\n'
            ),
            TextSpan(
              text: 'If you find any bug, error, or miscalculation, please report it to:\n\n',
            ),
            TextSpan(
              text: 'LoneDreamStudio@gmail.com\n\n',
              style: TextStyle(fontFamily: 'Comfortaa', fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)
            )
          ]
        ),
      )
    );
  }
}