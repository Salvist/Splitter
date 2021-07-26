import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter_app/splitter_button_style.dart';

import 'package:splitter_app/custom_widgets/gradient_container.dart';
import 'item.dart';

import 'split_data.dart';
import 'db_transaction.dart';

class SplitTest extends StatefulWidget{
  static _SplitTest of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitTestInherited>().data;
  }

  @override
  _SplitTest createState() => _SplitTest();
}

class _SplitTest extends State<SplitTest>{
  String username;
  String code = '';
  final dbRef = FirebaseDatabase.instance.reference();
  bool codeVerified = false;

  List<Item> items;
  List<String> participants;

  @override
  void initState(){
    super.initState();

    code = '';
    items = <Item>[];
    participants = <String>[];
    codeVerified = false;
  }

  void setCode(String c){
    setState(() {
      this.code = c;
      codeVerified = true;

    });
    SplitterDatabase.setParticipantName(dbRef, code, username);
  }

  void setItems(List<Item> i){
    this.items = i;
  }

  void setParticipant(List<String> p){
    this.participants = p;
  }

  @override
  Widget build(BuildContext context) {
    username = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: SplitTestInherited(
        data: this,
        child: Center(
          child: GradientContainer(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SplitJoinTitle(),
                EnterCode(),
                ItemsList(),
                WaitForHost()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplitTestInherited extends InheritedWidget{
  final _SplitTest data;

  SplitTestInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SplitTestInherited old) => data == old.data;
}

class SplitJoinTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Split Join', style: Theme.of(context).textTheme.headline1),
          Text('Join friend\'s split and claim your items', style: Theme.of(context).textTheme.subtitle1)
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
    codeVerified = SplitTest.of(context).codeVerified;
  }

  void verifyCode(BuildContext context) async {
    String code = codeController.text;
    if(!(await SplitterDatabase.verifyCode(SplitTest.of(context).dbRef, code))){
      Fluttertoast.showToast(
          msg: "Invalid Code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16
      );
      print('Invalid Code');
      return;
    }
    print('Code exist in the database');
    SplitTest.of(context).setCode(code);
  }

  @override
  Widget build(BuildContext context){
    return codeVerified ? Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Code: ', style: TextStyle(fontSize: 22),),
          Text('${codeController.text} ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
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
              ),
            ),
          ),
          IconButton(
              onPressed: (){
                verifyCode(context);
                },
              icon: Icon(Icons.arrow_forward)
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
  List<String> participants;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    code = SplitTest.of(context).code;
    participants = <String>[];
    username = ModalRoute.of(context).settings.arguments;
  }

  void showParticipants(){
    showModalBottomSheet(
        context: context,
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
        stream: SplitTest.of(context).dbRef.child(code).child('participants').onValue,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            DataSnapshot dataSnapshot = asyncSnapshot.data.snapshot;
            Map<dynamic, dynamic> data = dataSnapshot.value;
            // participants.clear();
            data.forEach((key, val) {
              if(!participants.contains(val)) participants.add(val);
            });
            SplitTest.of(context).setParticipant(participants);
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
                          style: TextStyle(fontSize: 12),),
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

class ItemsList extends StatefulWidget{
  @override
  _ItemsList createState() => _ItemsList();
}

class _ItemsList extends State<ItemsList> {
  String username;
  String code;
  List<Item> items = <Item>[];

  DatabaseReference dbRefOrder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    username = ModalRoute.of(context).settings.arguments;
    code = SplitTest.of(context).code;
    dbRefOrder = SplitTest.of(context).dbRef.child(code).child('order');
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
                SplitTest.of(context).setItems(items);

                return ListView.builder(
                    padding: EdgeInsets.only(top: 0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if(items[index].claim == '' || items[index].claim == null){
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index]
                                    .price}; Quantity: ${items[index]
                                    .quantity}'),
                                trailing: OutlinedButton(
                                    style: greenOutlineButtonStyle,
                                    onPressed: () => SplitterDatabase.claimItem(dbRefOrder, index, username),
                                    child: Text('Claim',
                                        style: TextStyle(fontSize: 16, color: Colors.black87))
                                )
                            )
                        );
                      } else if(items[index].claim == username) {
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index]
                                    .price}; Quantity: ${items[index]
                                    .quantity}'),
                                trailing: OutlinedButton(
                                    style: redOutlineButtonStyle,
                                    onPressed: () => SplitterDatabase.cancelItem(dbRefOrder, index),
                                    child: Text('Cancel',
                                        style: TextStyle(fontSize: 16, color: Colors.black87))
                                )
                            )
                        );
                      } else {
                        return Card(
                            child: ListTile(
                                title: Text(items[index].name),
                                subtitle: Text('Price: \$${items[index]
                                    .price}; Quantity: ${items[index]
                                    .quantity}'),
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
  String code;
  bool codeVerified;

  List<Item> items;
  List<String> participants;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    code = SplitTest.of(context).code;
    codeVerified = SplitTest.of(context).codeVerified;
    items = SplitTest.of(context).items;
    participants = SplitTest.of(context).participants;
  }

  @override
  Widget build(BuildContext context) {
    return codeVerified ? StreamBuilder(
        stream: SplitTest.of(context).dbRef.child(code).child('isSplitFinish').onValue,
        builder: (context, streamSnapshot){
          if(streamSnapshot.hasData){
            DataSnapshot dataSnapshot = streamSnapshot.data.snapshot;
            if(dataSnapshot.value == 'true'){
              SplitAndClaimData data = new SplitAndClaimData();
              data.setData(items, participants);
              Future((){
                Navigator.pushNamedAndRemoveUntil(context, '/splitjoindone', ModalRoute.withName('/splitclaimbridge'), arguments: data);
              });
            }
          }
          return Text('Waiting for host to start the split...');
        }
    ) : SizedBox.shrink();
  }
}