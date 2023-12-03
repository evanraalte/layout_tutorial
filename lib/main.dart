import 'package:flutter/material.dart';
import 'package:layout_tutorial/db.dart';
import 'package:layout_tutorial/expandable_floating_action_button.dart';
import 'package:layout_tutorial/likable_item.dart';
import 'package:layout_tutorial/utils.dart';

// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SuccessDatabaseService().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Success>> _successListFuture;
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
              onPressed: () async {
                if (title.isNotEmpty && subtitle.isNotEmpty) {
                  Success newSuccess =
                      Success(title: title, subtitle: subtitle);
                  await SuccessDatabaseService().insertSuccess(newSuccess);
                  _refreshSuccessList();
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
    _successListFuture = SuccessDatabaseService().successes();
  }

  void _addLikableItem() async {
    String title = getRandomTitle(adjectives, nouns);
    String subtitle =
        'Subtitle ${DateTime.now().millisecondsSinceEpoch}'; // Example subtitle

    Success newSuccess = Success(title: title, subtitle: subtitle);
    await SuccessDatabaseService().insertSuccess(newSuccess);
    _refreshSuccessList();
  }

  void _refreshSuccessList() {
    setState(() {
      _successListFuture = SuccessDatabaseService().successes();
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
              child: FutureBuilder<List<Success>>(
                future: _successListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return ListView(
                      children: snapshot.data!
                          .map((success) => LikableItem(
                                success: success,
                              ))
                          .toList(),
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
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
