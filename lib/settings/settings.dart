import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';

import '../main.dart';

class SplitSettings extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SettingsTitle(),
              SettingsOption(),
              // ElevatedButton(
              //   onPressed: (){
              //     Navigator.pop(context);
              //   },
              //   child: Text('Go back'),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Others',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}

class SettingsOption extends StatelessWidget{

  Future<bool> clearHistoryConfirmation(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: Text('Do you want to clear your splits history?', style: Theme.of(context).textTheme.bodyText1,),
          content: Text('If you press "YES" it will clear all of your splits history ' +
              'and this action is irreversible.',
              style: Theme.of(context).textTheme.bodyText2),
          actions: [
            TextButton(
                child: Text('YES', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                onPressed: (){
                  Navigator.of(context).pop(true);
                  return true;
                  // final dbRef = FirebaseDatabase.instance.reference();
                  // SplitterDatabase.cancelOrder(dbRef, splitData.code);
                }
            ),
            TextButton(
                child: Text('NO', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                onPressed: (){
                  Navigator.of(context).pop(false);
                }
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.cyan[300],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/splithelp');
            },
            child: Text('How to Use'),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/splitabout');
            },
            child: Text('About'),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () async {
              if(await clearHistoryConfirmation(context)) SplitterStateScope.of(context).bloc.deleteHistory();
              },
            child: Text('Clear History'),
          )
        ],
      ),
    );
  }
}