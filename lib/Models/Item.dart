class Item {
  String item; // avocado, tomato, milk
  String store; // WalMart, CostCo
  String category; // Produce, Dairy, Household
  bool star; // starred items will show up in the "To buy" tab

  Item({
    this.item,
    this.store = 'Other',
    this.category = 'Misc',
    this.star = false,
  });
}
