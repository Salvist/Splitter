import 'package:flutter/material.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';

class SplitterHelp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                HelpTitle(),
                SizedBox(height: 20,),
                SplitHelp(),
                SplitAndClaimHelp(),
                SizedBox(height: 20,),
                ElevatedButton(
                    child: Text('Go back'),
                    onPressed: (){Navigator.pop(context);}),
                SizedBox(height: 20,),
              ],
            ),
          )
        ),
      ),
    );
  }
}

class HelpTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('How to Use', style: Theme.of(context).textTheme.headline3,),
    );
  }
}

class SplitHelp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: RichText(
        text: TextSpan(
          text: 'Split\n',
          style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Comfortaa', fontWeight: FontWeight.w700, ),
          children: <TextSpan>[
            TextSpan(
              text: 'Split is an easy way to split your bill between your friends equally.\n' +
                    'Enter your total bill, check whether you should include tax and/or tips, and put how many people will pay the bill. ' +
                    'When you are done, press "Split the bill!" and it will tell you how much each person should pay along with other details.\n',
              style: Theme.of(context).textTheme.bodyText2
            )
          ]
        ),
      ),
    );
  }
}

class SplitAndClaimHelp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: RichText(
        text: TextSpan(
          text: 'Split and Claim\n',
          style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Comfortaa', fontWeight: FontWeight.w700, ),
          children: <TextSpan>[
            TextSpan(
              text: 'Split and Claim is a fun way to split the bill fairly according to what you buy. ' +
                    'Enter your name and make sure it is not the same with any of your friends. ' +
                    'One person must be the host, and do not forget to fill in the tax and tips. If there should be no tax or tips, then just insert 0. ' +
                    'Do note that this feature requires internet connection.\n\n',
              style: Theme.of(context).textTheme.bodyText2
            ),
            TextSpan(
              text: 'Split Host\n'
            ),
            TextSpan(
              text: 'When you become a host, specify all of the items that you and your friends are buying. ' +
                    'Then press "Host" and it will create a room with a code. Tell your friends about the code so that they can join the room. ' +
                    'After all items are claimed, then you can press "Split" and proceed to the result. ' +
                    'As a host, you will have the perk of looking at your friend\'s total bill.\n\n',
              style: Theme.of(context).textTheme.bodyText2
            ),
            TextSpan(
              text: 'Split Join\n',
            ),
            TextSpan(
              text: 'If your friend is the host, then ask for the code to join the room. After you enter the code, it will show all of the items that the host specify. ' +
                    'Claim all of the items that you buy and wait for everyone else to finish their claim. ' +
                    'When the host start the split, you will be able to see how much is your total bill.',
              style: Theme.of(context).textTheme.bodyText2
            )
          ]
        ),
      ),
    );
  }
}