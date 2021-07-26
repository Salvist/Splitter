import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';
import 'package:splitter_app/split_data.dart';

class SplitDone extends StatelessWidget{
  SplitMainData splitData;

  // SplitDone({
  //   Key key,
  //   @required this.splitData,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context){
    splitData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      body: GradientContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SplitDoneTitle(),
              SplitDoneResult(
                splitData: splitData,
              ),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done!', style: Theme.of(context).textTheme.button,))
            ],
          ),
        ),
      )

    );
  }
}

class SplitDoneTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Split Result', style: Theme.of(context).textTheme.headline2),
    );
  }
}

class SplitDoneResult extends StatelessWidget{
  final SplitMainData splitData;

  SplitDoneResult({
    Key key,
    @required this.splitData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String totalBillText;
    totalBillText = "The total bill ";
    if(splitData.includeTax || splitData.includeTip) totalBillText += "(";
    if((splitData.includeTax && !splitData.includeTip) || (!splitData.includeTax && splitData.includeTip)) totalBillText += "with ";
    if(splitData.includeTax) totalBillText += "Tax";
    if(splitData.includeTax && splitData.includeTip) totalBillText += "+";
    if(splitData.includeTip) totalBillText += "Tip";
    if(splitData.includeTax || splitData.includeTip) totalBillText += ")";
    totalBillText += " is " + splitData.totalBill.toStringAsFixed(2) + "\n";

    return Container(
      child: Column(
        children: [
          Text('The bill is \$${splitData.preBill.toStringAsFixed(2)}\n'),
          if(splitData.includeTax) Text('Tax amount is \$' + splitData.taxAmount.toStringAsFixed(2) + '\n'),
          if(splitData.includeTip) Text('Tips amount is \$' + splitData.tipAmount.toStringAsFixed(2) + '\n'),
          if(splitData.includeTax || splitData.includeTip) Text(totalBillText),
          Text("Divided by ${splitData.peopleCount} people\n"),
          Text( 'Each person pay..\n', style: Theme.of(context).textTheme.bodyText2,),
          Text('\$${splitData.splitAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 50),),
          Text('\nPlease tell your friends\nabout the split!\n', style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
          ElevatedButton.icon(
              onPressed: () async => Share.share(
                  "Hi guys and gals, the total bill is \$${splitData.totalBill.toStringAsFixed(2)}.\n" +
                  "Divided by ${splitData.peopleCount} people, each person pay \$${splitData.splitAmount.toStringAsFixed(2)}.\n" +
                  "Don't forget to pay, thank you!"
              ),
              icon: Icon(Icons.share),
              label: Text('Share')),
        ],
      ),
    );
  }
}