import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_admob/firebase_admob.dart';

import '../../main.dart';
import '../../ad_manager.dart';
import '../../db_transaction.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';
import '../../item.dart';
import '../../split_data.dart';

import '../../splitter_button_style.dart';

/*
From Split Host to Split and Claim, the data should have note, username, code, tax, tip, pre bill, and total bill being set.
Split and Claim will set the participants' name, participants' bill, people count, and split amount.
 */

class SplitAndClaim extends StatefulWidget {
  static _SplitAndClaim of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitAndClaimInherited>().data;
  }

  @override
  _SplitAndClaim createState() => _SplitAndClaim();
}

class SplitAndClaimInherited extends InheritedWidget{
  final _SplitAndClaim data;
  SplitAndClaimInherited({
    Key key,
    @required this.data,
    @required Widget child
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SplitAndClaimInherited old) => true;
}

class _SplitAndClaim extends State<SplitAndClaim>{
  SplitAndClaimData splitData;

  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;

  @override
  void initState(){
    super.initState();
    _isInterstitialAdReady = false;
    _interstitialAd = InterstitialAd(
        adUnitId: AdManager.interstitialAdUnitId,
        listener: _onInterstitialAdEvent
    );
    _interstitialAd.load();
  }

  @override
  void dispose(){
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _onInterstitialAdEvent(MobileAdEvent event){
    switch(event){
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        break;

      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('Failed to load an interstitial ad');
        break;

      case MobileAdEvent.closed:
      //TODO: go back to somewhere;
        break;
      default:
      //do nothing
    }
  }

  void setItems(List<Item> i){
    setState((){
      this.splitData.setItems(i);
    });
  }

  void setParticipant(List<String> p){
    this.splitData.setParticipants(p);
    this.splitData.peopleCount = p.length;
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: Text('Do you want to go back?', style: Theme.of(context).textTheme.bodyText1,),
          content: Text('If you press "YES" it will cancel the current split ' +
              'and you will not be able to return to this split.',
              style: Theme.of(context).textTheme.bodyText2),
          actions: [
            TextButton(
                child: Text('YES', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                onPressed: (){
                  Navigator.of(context).pop(true);
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
  Widget build(BuildContext context){
    splitData = ModalRoute.of(context).settings.arguments;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: SplitAndClaimInherited(
            data: this,
            child: Center(
              child: GradientContainer(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SplitAndClaimTitle(),
                    SizedBox(height: 20,),
                    ItemList(),
                    SizedBox(height: 20,),
                    //Going to Split And Claim Done
                    ElevatedButton(
                        child: Text('Split', style: TextStyle(fontSize: 18)),
                        onPressed: () async {
                          final dbRef = FirebaseDatabase.instance.reference().child(splitData.code);
                          if(await SplitterDatabase.isAllItemsClaimed(dbRef)){
                            SplitterDatabase.finishSplit(dbRef);
                            splitData.setParticipantsBill();
                            splitData.setSplitAmount();
                            splitData.calculateBill();
                            print(splitData.toString());
                            //addHistory requires note, pre bill, tax, tip, total bill, people count, split amount
                            SplitterStateScope.of(context).bloc.addHistory(splitData, 2);

                            //TODO: TURN OFF ADS WHEN TESTING, BUT ALSO DON'T FORGET TO TURN ON BACK
                            if(_isInterstitialAdReady){
                              _interstitialAd.show();
                            }
                            Navigator.pushNamedAndRemoveUntil(context, '/splitclaimdone', ModalRoute.withName('/splitclaimbridge'), arguments: splitData);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'All items must be claimed!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                fontSize: 16
                            );
                          }
                        }
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}

class SplitAndClaimTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Split & Claim', style: Theme.of(context).textTheme.headline3,),
          Text('Claim your items!', style: Theme.of(context).textTheme.subtitle1,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tax: ${SplitAndClaim.of(context).splitData.taxPercentage.toString()}\t', style: Theme.of(context).textTheme.subtitle1),
              Text('Tips: ${SplitAndClaim.of(context).splitData.tipPercentage.toString()}', style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Code: ', style: TextStyle(fontSize: 22),),
              Text('${SplitAndClaim.of(context).splitData.code} ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
              ParticipantIcon(),
            ],
          )
        ],
      ),
    );
  }
}

class ItemList extends StatefulWidget{
  @override
  _ItemList createState() => _ItemList();
}

class _ItemList extends State<ItemList>{
  String username;
  String code;
  DatabaseReference dbRefOrder;

  List<Item> items = <Item>[];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    username = SplitAndClaim.of(context).splitData.username;
    code = SplitAndClaim.of(context).splitData.code;
    dbRefOrder = FirebaseDatabase.instance.reference().child(code).child('order');
  }

  void claimItem(int index){
    SplitterDatabase.claimItem(dbRefOrder, index, username);
    SplitAndClaim.of(context).setItems(items);
  }

  void cancelItem(int index){
    SplitterDatabase.cancelItem(dbRefOrder, index);
    SplitAndClaim.of(context).setItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.6
            ),
            child: StreamBuilder(
              stream: dbRefOrder.onValue,
              builder: (context, asyncSnapshot){
                if(asyncSnapshot.hasData){
                  DataSnapshot dataSnapshot = asyncSnapshot.data.snapshot;
                  Map<dynamic, dynamic> data = dataSnapshot.value;
                  items.clear();

                  int i = 0;
                  while(i < data.length){
                    Item item = new Item();
                    item.setItem(data['item$i']['name'], data['item$i']['price'], data['item$i']['qty']);
                    if(data['item$i']['claimed'] != null)item.setClaim(data['item$i']['claimed']);
                    items.add(item);
                    i++;
                  }
                  print(items);
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 0),
                    itemCount: items.length,
                    itemBuilder: (context, index){

                      if(items[index].claim == '' || items[index].claim == null){
                        return Card(
                            child: ListTile(
                                title: Text(
                                    items[index].name,
                                    style: TextStyle(color: Colors.black54),
                                ),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}',
                                          style: TextStyle(fontSize: 16),),
                                trailing: OutlinedButton(
                                    style: greenOutlineButtonStyle,
                                    onPressed: (){claimItem(index);},
                                    child: Text('Claim',
                                        style: TextStyle(fontSize: 16, color: Colors.black45)
                                    ),
                                )
                            )
                        );
                      } else if(items[index].claim == username) {
                        return Card(
                            child: ListTile(
                                title: Text(
                                    items[index].name,
                                    style: TextStyle(color: Colors.black54),
                                ),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}',
                                          style: TextStyle(fontSize: 16)),
                                trailing: OutlinedButton(
                                    style: redOutlineButtonStyle,
                                    onPressed: (){cancelItem(index);},
                                    child: Text('Cancel',
                                        style: TextStyle(fontSize: 16, color: Colors.white70)
                                    ),
                                )
                            )
                        );
                      } else {
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}',
                                          style: TextStyle(fontSize: 16)),
                                trailing: Text('Claimed by\n${items[index].claim}', textAlign: TextAlign.center,)
                            )
                        );
                      }
                    }

                  );
                }
                return Container(
                  child: CircularProgressIndicator(),
                );
              }
            )
        )
      ],
    );
  }
}

class ParticipantIcon extends StatefulWidget{
  @override
  _ParticipantIcon createState() => _ParticipantIcon();
}

class _ParticipantIcon extends State<ParticipantIcon>{
  String username;
  String code;

  List<String> participants = <String>[];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    username = SplitAndClaim.of(context).splitData.username;
    code = SplitAndClaim.of(context).splitData.code;
  }

  void showParticipants(){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isScrollControlled: true,
        builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.65,
            child: ListView.separated(
                separatorBuilder: (context, index){
                  return Divider();
                },
                padding: EdgeInsets.all(20),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  if(participants[index] == username) return Text('${participants[index]} (You)', style: TextStyle(fontSize: 26),);
                  else return Text('${participants[index]}', style: TextStyle(fontSize: 26),);
                }
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbRefParticipants = FirebaseDatabase.instance.reference().child(code).child('participants');
    return StreamBuilder(
        stream: dbRefParticipants.onValue,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            DataSnapshot dataSnapshot = asyncSnapshot.data.snapshot;
            Map<dynamic, dynamic> data = dataSnapshot.value;
            participants.clear();
            data.forEach((key, val) {
              if(!participants.contains(val)) participants.add(val);
            });
            SplitAndClaim.of(context).setParticipant(participants);
            print(participants);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: Icon(Icons.people_alt_rounded, size: 30,),
                  onPressed: showParticipants,),
                Positioned(
                    bottom: -2,
                    right: -6,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.brightness_1,
                          size: 20,
                          color: Colors.cyanAccent,),
                        Text('${participants.length}',
                          style: TextStyle(fontSize: 12, color: Colors.black),),
                      ],
                    )
                )
              ],
            );
          }
          return Container();
        });
  }
}