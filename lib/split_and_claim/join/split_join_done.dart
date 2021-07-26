import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../split_data.dart';
import '../../item.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';

class SplitJoinDone extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: GradientContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SplitJoinDoneTitle(),
              Result(),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/splitclaimbridge')),
                child: Text('Done!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplitJoinDoneTitle extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    SplitAndClaimData splitData = ModalRoute.of(context).settings.arguments;
    return Container(
      child: Column(
        children: [
          Text('Split Result', style: Theme.of(context).textTheme.headline2),
          Text('Here is your split!', style: TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tax: ${splitData.taxPercentage.toString()}\t', style: TextStyle(fontSize: 20)),
              Text('Tips: ${splitData.tipPercentage.toString()}', style: TextStyle(fontSize: 20)),
            ],
          )
        ],
      ),
    );
  }
}

class Result extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    SplitAndClaimData data = ModalRoute.of(context).settings.arguments;
    String individualPrice = data.getIndividualPrice(data.username);

    print('data.items.isNotEmpty is ' + data.items.isNotEmpty.toString());
    print('data is ' + data.items.toString());

    return (data.items.isNotEmpty) ? Container(
      child: Column(
        children: [
          Text('Your name: ${data.username}'),
          OrderedItem(items: data.items),
          SizedBox(height: 20,),
          Text('Your total price: \$$individualPrice', style: Theme.of(context).textTheme.bodyText1)
        ],
      ),
    )
    : Container(
      child: Column(
        children: [
          Text('You did not claim any item :('),
          Text('Be sure to claim it next time!')
        ],
      ),
    );
  }
}

class OrderedItem extends StatelessWidget{
  final List<Item> items;

  OrderedItem({
    Key key,
    @required this.items
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SplitAndClaimData splitData = ModalRoute.of(context).settings.arguments;
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index){
          if(splitData.username == items[index].claim){
            return Text('${items[index].name} (\$${items[index].price})', style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,);
          } else {
            return SizedBox.shrink();
          }
        }
    );
  }
}