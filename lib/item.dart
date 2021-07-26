class Item{
  String name;
  String price;
  int quantity;
  String claim;

  Item(){
    this.name = '';
    this.price = '';
    this.quantity = 0;
    this.claim = '';
  }

  Item.setItem(String n, String p, int q){
    this.name = n;
    this.price = p;
    this.quantity = q;
  }

  void setItem(String n, String p, int q){
    this.name = n;
    this.price = p;
    this.quantity = q;
  }

  void setName(String n){
    this.name = n;
  }
  void setPrice(String p){
    this.price = p;
  }
  void setQty(int q){
    this.quantity = q;
  }
  void setClaim(String name){
    this.claim = name;
  }

  String toString(){
    String p = '{name: $name, price: $price, qty: $quantity}';
    return p;
  }
}