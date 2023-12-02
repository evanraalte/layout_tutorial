import 'package:flutter/material.dart';
import 'package:layout_tutorial/expandable_floating_action_button.dart';
import 'package:layout_tutorial/likable_item.dart';
import 'package:layout_tutorial/utils.dart';

// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> likableItems = [];
  bool isExpanded = false;

  Future<void> _showAddItemDialog(BuildContext context) async {
    String title = '';
    String subtitle = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    title = value;
                  },
                  decoration: const InputDecoration(hintText: "Enter title"),
                ),
                TextField(
                  onChanged: (value) {
                    subtitle = value;
                  },
                  decoration: const InputDecoration(hintText: "Enter subtitle"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (title.isNotEmpty && subtitle.isNotEmpty) {
                  setState(() {
                    likableItems
                        .add(LikableItem(title: title, subtitle: subtitle));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize with some items if necessary
    likableItems = List.generate(
      2,
      (index) => LikableItem(
        title: getRandomTitle(adjectives, nouns),
        subtitle: 'Subtitle ${index + 1}',
      ),
    );
  }

  void _addLikableItem() {
    setState(() {
      likableItems.add(
        LikableItem(
          title: getRandomTitle(adjectives, nouns),
          subtitle: 'Subtitle ${likableItems.length + 1}',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate a list of LikableItem widgets

    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Flutter layout demo'),
        // ),
        body: Column(
          children: [
            Image.asset(
              'images/lake.jpg',
              width: 600,
              height: 240,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: ListView(
                children: [
                  ...likableItems,
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
        floatingActionButton: ExpandableFloatingActionButton(
          onAddItem: _addLikableItem,
          onAddCustomItem: _showAddItemDialog,
        ),
      ),
    );
  }
}
