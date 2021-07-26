
class RecentSplitData{
  int id;
  int type;
  String note;
  String date;
  int peopleCount;

  double preBill;
  double totalBill;
  double splitAmount;

  double taxPercentage;
  double tipPercentage;

  RecentSplitData(
      this.id,
      this.type,
      this.note,
      this.date,
      this.preBill,
      this.taxPercentage,
      this.tipPercentage,
      this.totalBill,
      this.peopleCount,
      this.splitAmount
      );

  RecentSplitData.fromLocalDB({
    this.id,
    this.type,
    this.note,
    this.date,
    this.preBill,
    this.taxPercentage,
    this.tipPercentage,
    this.totalBill,
    this.peopleCount,
    this.splitAmount
  });

  @override
  String toString(){
    return "note: $note, date: $date, tax: $taxPercentage, tip: $tipPercentage, totalBill: $totalBill, peopleCount: $peopleCount, splitAmount: $splitAmount";
  }

  String get splitNote{
    return "Note: $note";
  }

  String showSplitInfo(){
    String info = "Date: $date\n"
        "Bill: \$$preBill\n"
        "Tax: $taxPercentage%\n"
        "Tip: $tipPercentage%\n"
        "Total Bill: \$$totalBill\n"
        "People: $peopleCount\n"
        "Split Amount: \$$splitAmount";
    return info;
  }

}