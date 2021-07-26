import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'item.dart';
import 'split_data.dart';

class SplitterDatabase{
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static Random _rand = Random.secure();

  static String pushToDatabase(final dbRef, SplitAndClaimData data, List<Item> items){
    String code = getRandomString(5);
    int length = items.length;
    print('setting order...');
    //set tip and tax
    dbRef.child(code).set({
      'note': data.note,
      'tax': data.taxPercentage,
      'tip': data.tipPercentage,
      'isSplitFinish': 'false'
    });

    //set host name
    dbRef.child(code).child('participants').set({
      'host': data.username
    });

    for(int i = 0; i < length; i++){
      dbRef.child(code).child('order').child('item$i').set({
        'name': items[i].name,
        'price': items[i].price,
        'qty': items[i].quantity
      });
    }

    //Increase transactionNumber
    int transactionNumber;
    dbRef.orderByKey().equalTo('transactionNumber').once().then(
        (DataSnapshot ss){
          transactionNumber = ss.value['transactionNumber'];
          transactionNumber++;
          dbRef.update({
            'transactionNumber': transactionNumber
          });
        }
    );
    return code;
  }

  static Future<String> getNote(final dbRef, String code) async {
    String note;

    await dbRef.orderByKey().equalTo(code).once().then(
        (DataSnapshot ss){
          if(ss.value[code]['note'] != null) note = ss.value[code]['note'];
        }
    );

    return note;
  }

  static List<Item> getItems(final dbRef, String code) {
    List<Item> items = <Item>[];

    dbRef.orderByKey().equalTo(code).once().then(
        (DataSnapshot ss){
          Map<dynamic, dynamic> itemsPlaceholder = ss.value[code]['order'];
          for(int i = 0; i < itemsPlaceholder.length; i++){
            Item item = new Item();
            item.setItem(itemsPlaceholder['item$i']['name'], itemsPlaceholder['item$i']['price'], itemsPlaceholder['item$i']['qty']);
            if(itemsPlaceholder['item$i']['claimed'] != null) item.setClaim(itemsPlaceholder['item$i']['claimed']);
            items.add(item);
          }
        }
    );
    return items;
  }

  static List<String> getParticipants(final dbRef, String code) {
    List<String> participants = <String>[];

    dbRef.orderByKey().equalTo(code).once().then(
      (DataSnapshot ss){
        Map<dynamic, dynamic> participantsPh = ss.value[code]['participants'];
        participantsPh.forEach((key, value) {
          (key != 'host') ? participants.add(value) : participants.add(value + ' (Host)');
        });
      }
    );
    return participants;
  }

  static Future<bool> verifyCode(final dbRef, String code) async {
    Future<bool> codeExist = Future<bool>.value(false);
    await dbRef.orderByKey().equalTo(code).once().then(
        (DataSnapshot ss) {
          if(ss.value != null) {
            codeExist = Future<bool>.value(true);
          }
        }
    );
    return codeExist;
  }

  static Future<double> getTax(final dbRef, String code) async {
    double taxPercentage = 0;
    await dbRef.orderByKey().equalTo(code).once().then(
        (DataSnapshot ss) {
          if(ss.value[code]['tax'] != null){
            taxPercentage = double.parse(ss.value[code]['tax'].toString());
          }
        }
    );
    print('tax is $taxPercentage');
    return taxPercentage;
  }

  static Future<double> getTip(final dbRef, String code) async {
    double tipPercentage = 0;
    await dbRef.orderByKey().equalTo(code).once().then(
        (DataSnapshot ss) {
          if(ss.value[code]['tip'] != null) tipPercentage = double.parse(ss.value[code]['tip'].toString());
        }

    );
    print('tip is $tipPercentage');
    return tipPercentage;
  }

  static void setParticipantName(final dbRef, String code, String name){
    if(name == '') return;
    dbRef.child(code).orderByKey().equalTo('participants').once().then(
            (DataSnapshot ss){
          dbRef.child(code).child('participants').once().then(
                  (DataSnapshot sss){
                Map<dynamic, dynamic> p = sss.value;
                if(p.containsValue(name)) {
                  print('participant already exist');
                  return;
                }
                print('participant d.n.e., adding participant');
                dbRef.child(code).child('participants').update({
                  'participant${p.length}' : name
                });
              }
          );
        }
    );
  }

  static void claimItem(final dbRef, int index, String username){
    print('item$index is claimed by $username');
    dbRef.child('item$index').update({
      'claimed': username
    });
  }

  static void cancelItem(final dbRef, int index){
    dbRef.child('item$index').child('claimed').remove();
  }

  static void cancelOrder(final dbRef, String code){
    print('Order $code is cancelled. It will be deleted in the database.');
    dbRef.child(code).remove();
  }

  static Future<bool> isAllItemsClaimed(final dbRef) async {
    //DatabaseReference must be directed to the code already.
    bool isClaimed = true;
    await dbRef.once().then(
            (DataSnapshot ss){
          Map<dynamic, dynamic> itemsPlaceholder = ss.value['order'];
          for(int i = 0; i < itemsPlaceholder.length; i++){
            if(itemsPlaceholder['item$i']['claimed'] == null && isClaimed) isClaimed = false;
          }
        }
    );
    return isClaimed;
  }

  static void finishSplit(final dbRef){
    dbRef.update({
      'isSplitFinish': 'true'
    });
  }

  //TODO: FINISH TESTING HOST
  static void testingHost(final dbRef, SplitAndClaimData splitData){
    String code = 'TEST';

    print('setting order...');

    List<Item> items = <Item>[];
    items.add(Item.setItem('chicken', '4', 1));
    items.add(Item.setItem('soup', '7', 1));
    int length = items.length;

    //set tip and tax
    dbRef.child(code).set({
      'note': 'HOST TEST',
      'tax': 0.0,
      'tip': 0.0,
      'isSplitFinish': 'false'
    });

    //set host name
    dbRef.child(code).child('participants').set({
      'host': splitData.username
    });


    for(int i = 0; i < length; i++){
      dbRef.child(code).child('order').child('item$i').set({
        'name': items[i].name,
        'price': items[i].price,
        'qty': items[i].quantity
      });
    }

    //Increase transactionNumber
    int transactionNumber;
    dbRef.orderByKey().equalTo('transactionNumber').once().then(
            (DataSnapshot ss){
          transactionNumber = ss.value['transactionNumber'];
          transactionNumber++;
          dbRef.update({
            'transactionNumber': transactionNumber
          });
        }
    );
  }

  static void testingJoin(final dbRef){
    String code = 'TEST';

    print('setting order...');

    List<Item> items = <Item>[];
    items.add(Item.setItem('chicken', '4', 1));
    items.add(Item.setItem('soup', '7', 1));
    int length = items.length;

    //set tip and tax
    dbRef.child(code).set({
      'note': 'JOIN TEST',
      'tax': 0.0,
      'tip': 0.0,
      'isSplitFinish': 'false'
    });

    //set host name
    dbRef.child(code).child('participants').set({
      'host': 'testUser'
    });


    for(int i = 0; i < length; i++){
      dbRef.child(code).child('order').child('item$i').set({
        'name': items[i].name,
        'price': items[i].price,
        'qty': items[i].quantity
      });
    }

    //Increase transactionNumber
    int transactionNumber;
    dbRef.orderByKey().equalTo('transactionNumber').once().then(
            (DataSnapshot ss){
          transactionNumber = ss.value['transactionNumber'];
          transactionNumber++;
          dbRef.update({
            'transactionNumber': transactionNumber
          });
        }
    );
  }

  static getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rand.nextInt(_chars.length))));
}