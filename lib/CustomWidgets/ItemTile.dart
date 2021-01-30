import 'package:flutter/material.dart';

import 'package:beyya/Screens/EditItem.dart';

class ItemTile extends StatelessWidget {
  final String docIdOfListInUse;
  final String item; //potato, avocado, etc
  final String store; // WalMart, CostCo
  final String category; //Produce, Dairy
  final bool star;// starred item or unstarred item
  final Function toggleStar;

  ItemTile({
    this.docIdOfListInUse,
    this.item,
    this.store,
    this.category,
    this.star,
    this.toggleStar
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 0.1, 0, 0.1),
      child: ListTile(
        title: Text(item),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(store, style: TextStyle(color: Colors.grey)),
            ),
            Icon(star ? Icons.star : Icons.star_border),
          ],
        ),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: EditItem(
                currentItem: item,
                currentStore: store,
                currentCategory: category,
                currentStar: star,
              ),
            ),
          );
        },
        onTap: toggleStar,
      ),
    );
  }
}
