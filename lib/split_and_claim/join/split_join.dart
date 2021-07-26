import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_admob/firebase_admob.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';
import 'package:splitter_app/main.dart';
import '../../item.dart';
import '../../splitter_button_style.dart';

import '../../ad_manager.dart';
import '../../split_data.dart';
import '../../db_transaction.dart';

class SplitJoin extends StatefulWidget{
  static _SplitJoin of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitJoinInherited>().data;
  }

  @override
  _SplitJoin createState() => _SplitJoin();
}

class _SplitJoin extends State<SplitJoin>{
  String username;
  String code = '';
  final dbRef = FirebaseDatabase.instance.reference();
  bool codeVerified = false;

  SplitAndClaimData splitData;

  // List<Item> items;
  // List<String> participants;

  //Interstitial Ads
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;

  @override
  void initState(){
    super.initState();
    username = '';
    code = '';

    splitData = new SplitAndClaimData();
    codeVerified = false;

    _isInterstitialAdReady = false;
    _interstitialAd = InterstitialAd(
        adUnitId: AdManager.interstitialAdUnitId,
        listener: _onInterstitialAdEvent
    );
    _interstitialAd.load();
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

  void setCode(String c){
    setState(() {
      this.code = c;
      codeVerified = true;

    });
    SplitterDatabase.setParticipantName(dbRef, code, username);
  }

  void setNote(String n) {
    setState((){
      this.splitData.note = n;
    });
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

  void setData(List<Item> i, List<String> p){
    setState((){
      splitData.setData(i, p);
    });
  }

  void setTaxTips(double tax, double tips){
    setState((){
      splitData.setTaxTip(tax, tips);
    });
  }

  @override
  Widget build(BuildContext context) {
    username = ModalRoute.of(context).settings.arguments;
    splitData.setUsername(username);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SplitJoinInherited(
        data: this,
        child: Center(
          child: GradientContainer(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SplitJoinTitle(),
                SizedBox(height: 10),
                EnterCode(),
                ItemsList(),
                SizedBox(height: 20,),
                WaitForHost()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplitJoinInherited extends InheritedWidget{
  final _SplitJoin data;

  SplitJoinInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SplitJoinInherited old) => data == old.data;
}

class SplitJoinTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Split Join', style: Theme.of(context).textTheme.headline1),
          Text('Join friend\'s split and\nclaim your items', style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

class EnterCode extends StatefulWidget{
  @override
  _EnterCode createState() => _EnterCode();
}

class _EnterCode extends State<EnterCode>{
  bool codeVerified;
  final codeController = TextEditingController();

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    codeVerified = SplitJoin.of(context).codeVerified;
  }

  void verifyCode(BuildContext context) async {
    String code = codeController.text;
    bool codeExist = false;
    //TODO: Don't forget to remove testingJoin on production
    if(code == 'TEST') {
      SplitterDatabase.testingJoin(SplitJoin.of(context).dbRef);
      codeExist = true;
    }
    else codeExist = await SplitterDatabase.verifyCode(SplitJoin.of(context).dbRef, code).timeout(Duration(seconds: 5), onTimeout: (){return false;});
    //if(!(await SplitterDatabase.verifyCode(SplitJoin.of(context).dbRef, code))){
    if(!codeExist){
      Fluttertoast.showToast(
          msg: "Invalid Code / \n No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16
      );
      print('Invalid Code');
      return;
    }
    print('Code $code exist in the database');

    //setting the code
    SplitJoin.of(context).setCode(code);

    String note = await SplitterDatabase.getNote(SplitJoin.of(context).dbRef, code);
    SplitJoin.of(context).setNote(note);

    //getting items and participants from database
    List<Item> items = SplitterDatabase.getItems(SplitJoin.of(context).dbRef, code);
    List<String> participants = SplitterDatabase.getParticipants(SplitJoin.of(context).dbRef, code);
    SplitJoin.of(context).setData(items, participants);

    //getting tax and tips from the database
    double taxPercentage = await SplitterDatabase.getTax(SplitJoin.of(context).dbRef, code);
    double tipsPercentage = await SplitterDatabase.getTip(SplitJoin.of(context).dbRef, code);
    SplitJoin.of(context).setTaxTips(taxPercentage, tipsPercentage);
  }

  @override
  Widget build(BuildContext context){
    return codeVerified ? Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Code: ', style: TextStyle(fontSize: 18),),
          Text('${codeController.text} ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
          ParticipantIcon(),
        ],
      ),
    ) : Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10,),
          Container(
            width: 140,
            child: TextField(
              controller: codeController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Enter Code',
                labelStyle:  TextStyle(fontSize: 18, color: Colors.black87),
                helperText: 'Case Sensitive',
              ),
            ),
          ),
          IconButton(
              onPressed: (){
                verifyCode(context);
              },
              icon: Icon(Icons.arrow_forward),
          )
        ],
      ),
    );
  }
}

class ParticipantIcon extends StatefulWidget{
  @override
  _ParticipantIcon createState() => _ParticipantIcon();
}

class _ParticipantIcon extends State<ParticipantIcon>{
  String code;
  String username;
  List<String> participants = <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    code = SplitJoin.of(context).code;
    username = ModalRoute.of(context).settings.arguments;
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
    return StreamBuilder(
        stream: SplitJoin.of(context).dbRef.child(code).child('participants').onValue,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            DataSnapshot dataSnapshot = asyncSnapshot.data.snapshot;
            Map<dynamic, dynamic> data = dataSnapshot.value;
            data.forEach((key, val) {
              if(key == 'host') val += ' (Host)';
              if(!participants.contains(val)) participants.add(val);
            });
            SplitJoin.of(context).setParticipant(participants);
            return GestureDetector(
              onTap: showParticipants,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.people_alt_rounded, size: 30,),
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
              ),
            );
            // return
          }
          return Container();
        });
  }
}

class ItemsList extends StatefulWidget{
  @override
  _ItemsList createState() => _ItemsList();
}

class _ItemsList extends State<ItemsList> {
  String username;
  String code;
  List<Item> items = <Item>[];

  DatabaseReference dbRefOrder;

  void setItem(BuildContext context, List<Item> i) {
    SplitJoin.of(context).setItems(i);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    username = SplitJoin.of(context).splitData.username;
    code = SplitJoin.of(context).code;
    dbRefOrder = SplitJoin.of(context).dbRef.child(code).child('order');
  }

  void claimItem(int index){
    SplitterDatabase.claimItem(dbRefOrder, index, username);
    SplitJoin.of(context).setItems(items);
  }

  void cancelItem(int index){
    SplitterDatabase.cancelItem(dbRefOrder, index);
    SplitJoin.of(context).setItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return (code != '') ? Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.6,
        child: StreamBuilder(
            stream: dbRefOrder.onValue,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasData) {
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

                return ListView.builder(
                    padding: EdgeInsets.only(top: 0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if(items[index].claim == '' || items[index].claim == null){
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}'),
                                trailing: OutlinedButton(
                                    style: greenOutlineButtonStyle,
                                    onPressed: (){
                                      claimItem(index);
                                    },
                                    child: Text('Claim',
                                        style: TextStyle(fontSize: 14))
                                )
                            )
                        );
                      } else if(items[index].claim == username) {
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}'),
                                trailing: OutlinedButton(
                                    style: redOutlineButtonStyle,
                                    onPressed: (){
                                      cancelItem(index);
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(fontSize: 14))
                                )
                            )
                        );
                      } else {
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}'),
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
    ) : Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.6,
    );
  }
}

class WaitForHost extends StatefulWidget{
  @override
  _WaitForHost createState() => _WaitForHost();
}

class _WaitForHost extends State<WaitForHost>{
  SplitAndClaimData splitData;

  String code;
  bool codeVerified;

  List<Item> items;
  List<String> participants;

  //Interstitial Ads
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    splitData = SplitJoin.of(context).splitData;
    code = SplitJoin.of(context).code;
    codeVerified = SplitJoin.of(context).codeVerified;
  }

  @override
  Widget build(BuildContext context) {
    return codeVerified ? StreamBuilder(
        stream: SplitJoin.of(context).dbRef.child(code).child('isSplitFinish').onValue,
        builder: (context, streamSnapshot){
          if(streamSnapshot.hasData){
            DataSnapshot dataSnapshot = streamSnapshot.data.snapshot;
            if(dataSnapshot.value == 'true'){
              Future((){
                //split data has note, tax, tip, items, participants
                splitData.setParticipantsBill();
                splitData.setSplitAmount();
                splitData.calculateBill();
                _interstitialAd = SplitJoin.of(context)._interstitialAd;
                _isInterstitialAdReady = SplitJoin.of(context)._isInterstitialAdReady;
                SplitterStateScope.of(context).bloc.addHistory(splitData, 3);
                if(_isInterstitialAdReady){
                  _interstitialAd.show();
                }
                Navigator.pushNamedAndRemoveUntil(context, '/splitjoindone', ModalRoute.withName('/splitclaimbridge'), arguments: splitData);
              });
            }
          }
          return Text('Waiting for host to start the split...');
        }
    ) : SizedBox.shrink();
  }
}