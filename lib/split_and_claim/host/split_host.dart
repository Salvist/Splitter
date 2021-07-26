import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:splitter_app/split_data.dart';
import 'package:splitter_app/splitter_button_style.dart';

import '../../item.dart';
import '../../db_transaction.dart';
import 'package:splitter_app/custom_widgets/gradient_container.dart';

/*
From Bridge to Split Host, SplitAndClaimData should have note, username, tax, and tip being set.
Split Host will set the code, items, pre bill, and total bill of the whole order.
 */

class SplitHost extends StatefulWidget {
  static _SplitHost of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<SplitHostInherited>().data;
  }

  @override
  _SplitHost createState() => _SplitHost();
}

class _SplitHost extends State<SplitHost>{
  List<Item> items = <Item>[];

  SplitAndClaimData splitData;
  final dbRef = FirebaseDatabase.instance.reference();

  void setItems(List<Item> i){
    setState((){
      splitData.setItems(i);
    });
  }

  void addItem(Item i){
    setState(() {
      items.add(i);
    });
  }

  void removeItem(int index){
    setState((){
      items.removeAt(index);
    });
  }

  bool checkItems(){
    if(items.isEmpty){
      Fluttertoast.showToast(
          msg: 'There is no item, please add some item',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    splitData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SplitHostInherited(
          data: this,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GradientContainer(),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  //top: 50
                  child: SplitHostTitle()
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.17,
                  //top: 150,
                  left: 20,
                  child: Text('Items', style: Theme.of(context).textTheme.bodyText1)
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.20,
                //top: 160,
                child: ItemList(),
              ),
              Positioned(
                bottom: 20,
                child: ElevatedButton(
                  child: Text('Host', style: TextStyle(fontSize: 18)),
                  onPressed: (){
                    //TODO: Don't forget to remove testingHost on production
                    if(checkItems()) return;
                    String code = SplitterDatabase.pushToDatabase(dbRef, splitData, items);
                    splitData.setCode(code);
                    splitData.setItems(items);
                    splitData.calculateBill();
                    //username, tax tip, note, preBill, totalbill, date

                    // now splitData has username, code, tax, tip, and items
                    Navigator.pushNamedAndRemoveUntil(context, '/splitclaim', ModalRoute.withName('/splitclaimbridge'), arguments: splitData);
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}

class SplitHostInherited extends InheritedWidget{
  final _SplitHost data;
  SplitHostInherited({
    Key key,
    @required this.data,
    @required Widget child
  }) : super(key: key, child: child);

  @override bool updateShouldNotify(SplitHostInherited old) => true;
}

class SplitHostTitle extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    SplitAndClaimData splitData = ModalRoute.of(context).settings.arguments;
    return Container(
        child: Column(
          children: [
            Text('Split Host', style: Theme.of(context).textTheme.headline2),
            Text('Place your items', style: Theme.of(context).textTheme.subtitle1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tax: ${splitData.taxPercentage.toString()}\t', style: Theme.of(context).textTheme.subtitle1),
                Text('Tips: ${splitData.tipPercentage.toString()}', style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
          ],
        )

    );
  }
}

class ItemList extends StatefulWidget{
  @override
  _ItemList createState() => _ItemList();
}

class _ItemList extends State<ItemList>{
  final itemsNameController = TextEditingController();
  final itemsPriceController = TextEditingController();

  List<Item> items;

  int quantity = 1;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    items = SplitHost.of(context).items;
  }

  void addItemToLists(){
    if(itemsNameController.text == '') {
      Fluttertoast.showToast(
          msg: 'Please insert item\'s name',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16
      );
      return;
    }
    if(itemsPriceController.text == ''){
      itemsPriceController.text = '0';
    }

    setState((){
      Item item = new Item();
      item.setItem(itemsNameController.text, itemsPriceController.text, quantity);
      //items.add(item);
      SplitHost.of(context).addItem(item);

      reset();
    });
  }

  void reset(){
    itemsNameController.clear();
    itemsPriceController.clear();
    quantity = 1;
  }

  void removeItem(int index){
    SplitHost.of(context).removeItem(index);
  }

  void addQty(){
    setState((){
      quantity++;
    });
  }

  void decreaseQty(){
    setState((){
      if(quantity > 1) quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 20,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: itemsNameController,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                      labelText: 'Enter item\'s name',
                      // fillColor: Colors.black54,
                      // border: OutlineInputBorder(),
                      // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
                      labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
                      // focusColor: Colors.black54
                  ),
                ),
              ),
              Container(
                width: 110,
                padding: EdgeInsets.all(8),
                child: TextField(
                  controller: itemsPriceController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      labelText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(
                      new RegExp(r"^\d+\.?\d{0,3}")
                  ),],
                ),
              ),
              // QUANTITY SECTION
              // Text('$quantity'),
              // Column(
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.keyboard_arrow_up_rounded),
              //       onPressed: addQty,
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.keyboard_arrow_down_rounded),
              //       onPressed: decreaseQty,
              //     ),
              //   ],
              // ),
              ElevatedButton(
                style: smallCyanElevatedButtonStyle,
                child: Text('Add', style: TextStyle(fontSize: 16),),
                onPressed: addItemToLists,
              ),
            ],
          ),
        ),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.6
            ),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 0),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index){
                return Card(
                    child: ListTile(
                        title: Text(items[index].name, style: TextStyle(fontSize: 24)),
                        subtitle: Text('Price: \$${items[index].price}; Quantity: ${items[index].quantity}', style: TextStyle(color: Colors.white, fontSize: 18),),
                        trailing: IconButton(
                            icon: Icon(Icons.cancel),
                            color: Colors.red,
                            onPressed: (){removeItem(index);}
                        )
                    )
                );
              },
            )
        )
      ],
    );
  }
}