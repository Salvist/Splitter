import 'package:intl/intl.dart';
import 'package:splitter_app/sales_tax.dart';

import 'db_local.dart';
import 'item.dart';
import 'locator.dart';

class SplitAndClaimData{
  String note;
  double preBill;
  double taxPercentage;
  double tipPercentage;
  double totalBill;
  int peopleCount;
  double splitAmount;

  String username;
  String code;

  //for split
  bool includeTax;
  bool includeTip;

  List<Item> items;
  List<String> participantsName;
  List<double> participantsBill;

  SplitAndClaimData(){
    note = "";
    username = '';
    this.items = <Item>[];
    this.participantsName = <String>[];
    this.participantsBill = <double>[];
    taxPercentage = 0.0;
    tipPercentage = 0.0;
    totalBill = 20.0;
  }

  void setUsername(String u){
    this.username = u;
  }

  void setCode(String c){
    this.code = c;
  }

  void setTaxTip(double tax, double tip){
    this.taxPercentage = tax;
    this.tipPercentage = tip;
  }

  void setIncludeTaxTip(bool tax, bool tip){
    this.includeTax = tax;
    this.includeTip = tip;
  }

  void setItems(List<Item> i){
    this.items = i;
  }

  void setParticipants(List<String> p){
    this.participantsName= p;
  }

  void setData(List<Item> i, List<String> p){
    this.items = i;
    this.participantsName = p;
  }

  List<Item> getItems(){
    return items;
  }

  List<String> getParticipants(){
    return participantsName;
  }

  double getCombinedPrice(){
    double combinedPrice = 0;
    for(int i = 0; i < items.length; i++){                                            //
      double itemPrice = double.parse(items[i].price) * (1 + taxPercentage / 100);   //price after tax
      itemPrice = itemPrice * (1 + tipPercentage / 100);                            //price after tips
      combinedPrice += itemPrice;                                                  //
    }
    return combinedPrice;
  }

  void calculateBill(){
    this.preBill = 0;
    this.totalBill = 0;
    double itemTotalPrice = 0;
    items.forEach((Item item) {
      preBill += double.parse(item.price);
      itemTotalPrice = double.parse(item.price) * (1 + taxPercentage / 100) * (1 + tipPercentage / 100);
      totalBill += itemTotalPrice;
    });
    preBill = roundUpTwo(preBill);
    totalBill = roundUpTwo(preBill);
  }

  void setParticipantsBill(){
    participantsBill = List<double>.filled(participantsName.length, 0);
    for(int i = 0; i < this.participantsBill.length; i++){
      for(int j = 0; j < this.items.length; j++){
        if(participantsName[i] == items[j].claim) participantsBill[i] += double.parse(items[j].price);
      }
      participantsBill[i] += participantsBill[i] * taxPercentage / 100;   //calculate tax
      participantsBill[i] += participantsBill[i] * tipPercentage / 100;  //calculate tips
      participantsBill[i] = roundUpTwo(participantsBill[i]);
    }
  }

  void setSplitAmount(){
    this.splitAmount = 0;
    for(int i = 0; i < participantsName.length; i++){
      if(participantsName[i] == username) splitAmount = participantsBill[i];
    }
    splitAmount = roundUpTwo(splitAmount);
  }

  List<double> getTotalPrice(){
    participantsBill = List<double>.filled(participantsName.length, 0);

    for(int i = 0; i < this.participantsBill.length; i++){
      participantsBill[i] = 0;
      for(int j = 0; j < this.items.length; j++){
        if(participantsName[i] == items[j].claim) participantsBill[i] += double.parse(items[j].price);
      }
      participantsBill[i] += participantsBill[i] * taxPercentage / 100;   //calculate tax
      participantsBill[i] += participantsBill[i] * tipPercentage / 100;  //calculate tips
      participantsBill[i] = roundUpTwo(participantsBill[i]);
    }

    return participantsBill;
  }

  //Round up two digits after comma
  double roundUpTwo(double val){
    return double.parse(val.toStringAsFixed(2));
  }


  String getIndividualPrice(String un){
    double price = 0;

    for(int i = 0; i < items.length; i++){
      if(items[i].claim == un) price += double.parse(items[i].price);
    }                                        //
    price += price * taxPercentage / 100;   //calculate tax
    price += price * tipPercentage / 100;  //calculate tips
    return price.toStringAsFixed(2);
  }

  Map<String, dynamic> toMapSplit(int nextId, int type) {
    DateTime now = new DateTime.now();
    String dateFormat = DateFormat('yMMMMd').add_jm().format(now);

    return {
      'id': nextId,
      'split_type': type,
      'note' : note,
      'date' : dateFormat,
      'pre_bill' : double.parse(preBill.toStringAsFixed(2)),
      'tax' : taxPercentage,
      'tip' : tipPercentage,
      'total_bill' : totalBill,
      'people_count' : peopleCount,
      'split_amount' : splitAmount
    };
  }
  //TODO: FIX PARTICIPANTS TABLE
  List<Map<String, dynamic>> toMapParticipants(int splitId) {

    return List.generate(participantsBill.length, (index) => {
        // 'participant_id': participantId,
        'participant_name': participantsName[index],
        'participant_bill': participantsBill[index].toStringAsFixed(2),
        'id': splitId
    });
  }
  
  String get host{
    String host;
    print('AAA' + participantsName.toString());
    participantsName.forEach((name) {
      if(name.endsWith(' (Host)')) host = name;
    });
    return host.substring(0, host.length-7);
  }

  String toString(){
    return 'SplitAndClaim(note: $note, preBill: $preBill, tax: $taxPercentage, tip: $tipPercentage, totalBill: $totalBill, peopleCount: $peopleCount, splitAmount: $splitAmount)';
  }
}

class SplitMainData{
  String date;
  String note;
  String administrativeAreaCode;
  int peopleCount = 2;

  double preBill;
  double totalBill;
  double splitAmount;

  bool includeTax;
  double taxPercentage;
  double taxAmount;

  bool includeTip;
  double tipPercentage;
  double tipAmount;

  SplitMainData(String administrativeArea){
    administrativeAreaCode = Locator.getAdministrativeAreaCode(administrativeArea);
    includeTax = true;
    includeTip = true;
    taxPercentage = SalesTax.getSalesTax(administrativeArea);
    tipPercentage = 15;
  }
  SplitMainData.fromDB({
    this.note,
    this.date,
    this.preBill,
    this.taxPercentage,
    this.tipPercentage,
    this.totalBill,
    this.peopleCount,
    this.splitAmount
  });

  Future<String> get defaultNote async {
    int id = await DatabaseLocal.db.nextId;
    if(id == null) id = 1;
    return "Split No. $id";
  }

  void roundDouble(){
    this.preBill = double.parse(this.preBill.toStringAsFixed(2));
    this.totalBill = double.parse(this.totalBill.toStringAsFixed(2));
    this.splitAmount = double.parse(this.splitAmount.toStringAsFixed(2));
  }

  void calculateSplit(){
    double tempBill = preBill;
    if(includeTax) {
      taxAmount = tempBill * taxPercentage / 100;
      tempBill += taxAmount;
    }
    else {
      taxPercentage = 0.0;
    }

    if(includeTip){
      tipAmount = tempBill * tipPercentage / 100;
      tempBill += tipAmount;
    }
    else {
      tipPercentage = 0.0;
    }

    totalBill = tempBill;
    splitAmount = tempBill / peopleCount;
    roundDouble();
  }

  @override
  String toString(){
    return 'SplitMainData(note: $note, date: $date, tax: $taxPercentage, tip: $tipPercentage, totalBill: $totalBill, peopleCount: $peopleCount, splitAmount: $splitAmount)';
  }

  //id | note | date | pre_bill | tax | tip | total_bill | people_count | split_amount
  Map<String, dynamic> toMapSplit(int nextId, int type) {
    DateTime now = new DateTime.now();
    String dateFormat = DateFormat('yMMMMd').add_jm().format(now);

    return {
      'id': nextId,
      'split_type': type,
      'note' : note,
      'date' : dateFormat,
      'pre_bill' : double.parse(preBill.toStringAsFixed(2)),
      'tax' : taxPercentage,
      'tip' : tipPercentage,
      'total_bill' : totalBill,
      'people_count' : peopleCount,
      'split_amount' : splitAmount
    };
  }
}