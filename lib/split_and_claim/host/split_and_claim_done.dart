import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splitter_app/split_data.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';
import '../../item.dart';

class SplitClaimDone extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GradientContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SplitClaimDoneTitle(),
              Result(),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/splitclaimbridge')),
                child: Text('Done!'),
              )
            ],
          ),
        ),
      )
    );
  }
}

class SplitClaimDoneTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    SplitAndClaimData splitData = ModalRoute.of(context).settings.arguments;

    return Container(
      child: Column(
        children: [
          Text('Split Result', style: Theme.of(context).textTheme.headline2),
          Text('Here is the result!', style: TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tax: ${splitData.taxPercentage.toString()}\t', style: Theme.of(context).textTheme.bodyText2),
              Text('Tips: ${splitData.tipPercentage.toString()}', style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
          Text('Combined Price : ${splitData.getCombinedPrice().toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyText1,)
        ],
      ),
    );
  }
}

class Result extends StatefulWidget{
  @override
  _Result createState() => _Result();
}

class _Result extends State<Result>{
  @override
  Widget build(BuildContext context) {
    SplitAndClaimData splitData = ModalRoute.of(context).settings.arguments;
    List<double> participantsPrice = splitData.getTotalPrice();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(top: 10),
      child: ListView.separated(
          padding: EdgeInsets.only(top: 0),
          // shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(
            color: Colors.white,
            thickness: 2,
            indent: MediaQuery.of(context).size.width * 0.1,
            endIndent: MediaQuery.of(context).size.width * 0.1,
          ),
          itemCount: splitData.getParticipants().length,
          itemBuilder: (context, index){
            return Container(
              child: Column(
                children: [
                  (splitData.username == splitData.participantsName[index]) ? Text('Name: ${splitData.participantsName[index]} (You)') : Text('Name: ${splitData.participantsName[index]}'),
                  OrderedItem(name: splitData.participantsName[index], items: splitData.items),
                  Text('Total Price: \$${participantsPrice[index].toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyText1)
                ],
              ),
            );
          }
      )
    );
  }
}

class OrderedItem extends StatelessWidget{
  final String name;
  final List<Item> items;

  OrderedItem({
    Key key,
    @required this.name,
    @required this.items
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        primary: false,
        padding: EdgeInsets.only(top: 0),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index){
          if(name == items[index].claim){
            return Text('${items[index].name} (\$${items[index].price})', style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,);
          } else {
            return SizedBox.shrink();
          }
        }
    );
  }
}