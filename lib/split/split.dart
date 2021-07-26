import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';

import '../main.dart';
import '../split_data.dart';
import 'split_done.dart';
import '../splitter_button_style.dart';

class SplitMain extends StatefulWidget{
  static _SplitMain of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitMainInherited>().data;
  }

  @override
  _SplitMain createState() => _SplitMain();
}

class SplitMainInherited extends InheritedWidget{
  final _SplitMain data;
  SplitMainInherited({
    Key key,
    @required this.data,
    @required Widget child
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SplitMainInherited old) => true;
}

class _SplitMain extends State<SplitMain>{
  SplitMainData splitData;

  //Text Controller
  final noteController = TextEditingController();
  final billController = TextEditingController();
  final salesTaxController = TextEditingController();
  final tipController = TextEditingController();

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final String administrativeArea = ModalRoute.of(context).settings.arguments;
    splitData = new SplitMainData(administrativeArea);
    salesTaxController.text = splitData.taxPercentage.toString();
    tipController.text = splitData.tipPercentage.toStringAsFixed(0);
  }

  void setDefaultNote() async {
    splitData.note = await splitData.defaultNote;

    setState(() {
      noteController.text = splitData.note;
    });
  }

  void addPeople(){
    setState(() {
      splitData.peopleCount++;
    });
    print('add');
  }

  void subtractPeople(){
    if(splitData.peopleCount > 2){
      setState(() {
        splitData.peopleCount--;
      });
      print('sub');
    }
  }

  void setIncludeTax(bool tax){
    setState(() {
      splitData.includeTax = tax;
    });
  }

  void setIncludeTip(bool tip){
    setState(() {
      splitData.includeTip = tip;
    });
  }

  void setSplitDataFromTextController(){
    if(noteController.text != "") splitData.note = noteController.text;

    splitData.preBill = double.parse(billController.text);
    if(salesTaxController.text != "") {
      if(double.parse(salesTaxController.text) > 0.0){
        splitData.taxPercentage = double.parse(salesTaxController.text);
      }
      else {
        splitData.includeTax = false;
        splitData.taxPercentage = 0.0;
      }
    }
    else {
      splitData.includeTax = false;
      splitData.taxPercentage = 0.0;
    }

    if(tipController.text != ""){
      if(double.parse(tipController.text) > 0.0){
        splitData.tipPercentage = double.parse(tipController.text);
      }
      else {
        splitData.includeTip = false;
        splitData.tipPercentage = 0.0;
      }
    }
    else {
      splitData.includeTip = false;
      splitData.tipPercentage = 0.0;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.cyan[200],
      body: SplitMainInherited(
        data: this,
        child: Center(
          child: GradientContainer(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SplitTitle(),
                NoteTextField(),
                BillTextField(),
                TaxOption(),
                TipOption(),
                PeopleCount(),
                ElevatedButton(
                    onPressed: () async {
                      Fluttertoast.cancel();
                      setSplitDataFromTextController();
                      if(splitData.note == null || splitData.note == "") splitData.note = await splitData.defaultNote;
                      splitData.calculateSplit();

                      if(splitData.splitAmount <= 0.00 || splitData.splitAmount == null){
                        Fluttertoast.showToast(
                            msg: "Please insert the bill amount",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            fontSize: 16
                        );
                      }
                      else {
                        SplitterStateScope.of(context).bloc.addHistory(splitData, 1);
                        Navigator.pushNamedAndRemoveUntil(context, '/splitdone', ModalRoute.withName('/'), arguments: splitData);
                      }
                    },
                    child: Text('Split the bill!')
                ),
                // SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplitTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Split',
        style: Theme.of(context).textTheme.headline1,
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
          controller: SplitMain.of(context).noteController,
          decoration: InputDecoration(
              labelText: 'Enter note',
          ),
      ),
    );
  }
}

class BillTextField extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      width: 300,
      child: TextField(
        controller: SplitMain.of(context).billController,
        textAlign: TextAlign.center,
        // style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Enter your total bill',
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(
            new RegExp(r"^\d+\.?\d{0,3}")
        )],
      ),
    );
  }
}

class TaxOption extends StatefulWidget{
  @override
  _TaxOption createState() => _TaxOption();
}

class _TaxOption extends State<TaxOption>{
  String administrativeAreaCode;
  bool includeTax;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    administrativeAreaCode = SplitMain.of(context).splitData.administrativeAreaCode;
    includeTax = SplitMain.of(context).splitData.includeTax;
  }

  Widget build(BuildContext context){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
              activeColor: Colors.cyan[300],
              value: includeTax,
              onChanged: (checkTax) => SplitMain.of(context).setIncludeTax(checkTax),
          ),
          Text('Include Tax: ', style: Theme.of(context).textTheme.bodyText2,),
          Text(administrativeAreaCode, style: Theme.of(context).textTheme.bodyText2,),
          SizedBox(width: 10),
          Container(
            width: 100,
            // height: 45,
            child: TextField(
              controller: SplitMain.of(context).salesTaxController,
              textAlign: TextAlign.center,
              // style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  labelText: 'Tax (%)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(
                  new RegExp(r"^\d+\.?\d{0,3}")
              )],
            ),
          )
        ],
      )
    );
  }
}

class TipOption extends StatefulWidget{
  @override
  _TipOption createState() => _TipOption();
}

class _TipOption extends State<TipOption>{
  bool includeTip;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    includeTip = SplitMain.of(context).splitData.includeTip;
  }

  Widget build(BuildContext context){
    return Container(
      child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                activeColor: Colors.cyan[300],
                value: includeTip,
                onChanged: (checkTip) => SplitMain.of(context).setIncludeTip(checkTip),
              ),
              Text('Include Tips:  ', style: Theme.of(context).textTheme.bodyText2,),
              SizedBox(width: 10),
              Container(
                width: 100,
                // height: 60,
                child: TextField(
                  controller: SplitMain.of(context).tipController,
                  textAlign: TextAlign.center,
                  // style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      labelText: 'Tips (%)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
              )
            ],
          ),
          // SLIDER
          // Container(
          //   width: 300,
          //   child: Slider(
          //       value: tipPercentage,
          //       min: 0,
          //       max: 30,
          //       divisions:6,
          //       label: tipPercentage.round().toString() + '%',
          //       onChanged: (double value){
          //         setState(() {
          //           tipPercentage = value;
          //         });
          //       }
          //   ),
          // )
    );
  }
}

class PeopleCount extends StatefulWidget{
  @override
  _PeopleCountState createState() => _PeopleCountState();
}

class _PeopleCountState extends State<PeopleCount>{
  int peopleCount;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    peopleCount = SplitMain.of(context).splitData.peopleCount;
  }

  Widget build(BuildContext context){
    return Container(
      child:
        Column(
          children: [
            Text('How many people?\n', style: Theme.of(context).textTheme.bodyText2,),
            Text('$peopleCount', style: TextStyle(fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: smallCyanElevatedButtonStyle,
                  onPressed: SplitMain.of(context).subtractPeople,
                  child: Icon(Icons.remove),
                ),
                SizedBox(width: 20,),
                ElevatedButton(
                  style: smallCyanElevatedButtonStyle,
                  onPressed: SplitMain.of(context).addPeople,
                  child: Icon(Icons.add),
                ),
              ],
            )
          ],
        )
    );
  }
}