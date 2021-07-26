import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter_app/sales_tax.dart';

import 'package:splitter_app/split_data.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';

import '../db_local.dart';

final usernameController = TextEditingController();
final taxController = TextEditingController();
final tipsController = TextEditingController();
final noteController = TextEditingController();


/*
Initialization of SplitAndClaimData
Bridge will set the note, username, tax percentage, and tip percentage.
 */


class SplitBridge extends StatelessWidget{
  String administrativeArea = '';

  Widget build(BuildContext context){
    administrativeArea = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.cyan[200],
      body: GradientContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SplitBridgeTitle(),
              NoteTextField(),
              SplitBridgeField(administrativeArea: administrativeArea,),
              SplitBridgeOption()
            ],
          ),
        ),
      ),
    );
  }
}

class SplitBridgeTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Split and Claim', style: Theme.of(context).textTheme.headline3),
          Text('Split the bill with friends\ntogether or manually!', style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}

class NoteTextField extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      width: 300,
      child: TextField(
        controller: noteController,
        decoration: InputDecoration(
          labelText: 'Enter note',
        ),
      ),
    );
  }
}

class SplitBridgeField extends StatefulWidget {
  final String administrativeArea;
  SplitBridgeField({
    Key key,
    @required this.administrativeArea
  });
  @override
  _SplitBridgeField createState() => _SplitBridgeField();
}

class _SplitBridgeField extends State<SplitBridgeField>{
  @override
  void initState(){
    super.initState();
    if(widget.administrativeArea != '') taxController.text = SalesTax.getSalesTax(widget.administrativeArea).toString();
    tipsController.text = '15';
  }

  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Container(
              width: 180,
              child: TextField(
                  controller: usernameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Enter Name',
                  )
              )
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.only(top: 10),
            width: 220,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38,width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      child: TextField(
                        controller: taxController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Tax (%)',
                          // labelStyle: TextStyle(fontSize: 18)
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(
                            new RegExp(r"^\d+\.?\d{0,3}")
                        )],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 90,
                      child: TextField(
                        controller: tipsController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Tips (%)',
                          // labelStyle: TextStyle(fontSize: 18)
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(
                            new RegExp(r"^\d+\.?\d{0,3}")
                        )],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5,),
                Text('Only for Host!', style: TextStyle(fontSize: 18),)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SplitBridgeOption extends StatefulWidget {
  @override
  _SplitBridgeOption createState() => _SplitBridgeOption();
}

class _SplitBridgeOption extends State<SplitBridgeOption>{
  SplitAndClaimData splitData = new SplitAndClaimData();

  bool checkUsername(){
    if(usernameController.text == ''){
      Fluttertoast.showToast(
          msg: "Please input your username",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16
      );
      return false;
    }
    splitData.setUsername(usernameController.text);
    return true;
  }

  bool checkTaxTips(){
    if(taxController.text == '' || tipsController.text == ''){
      Fluttertoast.showToast(
        msg: "Please fill the tax and tips!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16
      );
      return false;
    }
    splitData.setTaxTip(double.parse(taxController.text), double.parse(tipsController.text));
    return true;
  }

  Future<String> getNote() async {
    if(noteController.text == '') {
      int id = await DatabaseLocal.db.nextId;
      if(id == null) id = 1;
      return "Split No. $id";
    }
    else return noteController.text;
  }

  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if(checkUsername() && checkTaxTips()) {
                splitData.note = await getNote();
                Navigator.pushNamed(context, '/splithost', arguments: splitData);
              }
            },
            child: Text('Host', style: Theme.of(context).textTheme.button),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: (){
              FocusScope.of(context).unfocus();
              if(checkUsername()) Navigator.pushNamed(context, '/splitjoin', arguments: usernameController.text);
            },
            child: Text('Join', style: Theme.of(context).textTheme.button),
          ),
          // SizedBox(height: 20,),
          // // GradientFlatButton(
          // //   onPressed: null,
          // //   child: Text('Offline', style: Theme.of(context).textTheme.button),
          // // ),
        ],
      ),
    );
  }
}