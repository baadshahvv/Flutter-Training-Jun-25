import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_app/screens/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  // var groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  // var _isLoading = true;
  // var _error = "";

  @override
  void initState() {
    _loadedItems = _loadItems();
    super.initState();
  }

  void _addItem() async {
    final groceryItem = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (groceryItem == null) {
      return;
    }

    setState(() {
      _loadedItems = _loadItems();
    });

  }

  Future<List<GroceryItem>> _loadItems() async {
    // var url = Uri.https(
    //   'grocery-app-27de5-default-rtdb.firebaseio.com',
    //   'shopping-list.json',
    // );

    var url = Uri.parse("${dotenv.env['BASE_URL']}/shopping-list.json");

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch. Please try again later.");
    }
    if (response.body == 'null') {
      return [];
    }

    Map<String, dynamic> listData = json.decode(response.body);
    List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return loadedItems;
  }

  void _removeItem(item) async {
    // final index = groceryItems.indexOf(item);
    // setState(() {
    //   groceryItems.remove(item);
    // });

    var url = Uri.https(
      'grocery-app-27de5-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // setState(() {
      //   groceryItems.insert(index, item);
      //   // Show Snackbar with error message
      // });
      return;
    }

    setState(() {
      _loadedItems = _loadItems();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No items added yet."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) => {_removeItem(snapshot.data![index])},
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
            ),
          );
        },
      ),
    );
  }
}
