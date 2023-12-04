import 'package:flutter/material.dart';
import 'package:layout_tutorial/date_selector.dart';
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
  DateTime selectedDate = DateTime.now();

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
    _successListFuture =
        SuccessDatabaseService().successes(filterCreatedDate: selectedDate);
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
      _successListFuture =
          SuccessDatabaseService().successes(filterCreatedDate: selectedDate);
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _refreshSuccessList();
  }

  @override
  Widget build(BuildContext context) {
    // Generate a list of LikableItem widgets

    return MaterialApp(
      title: 'Flutter layout demo',
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
      debugShowCheckedModeBanner: false,
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
            DateSelector(
              selectedDate: selectedDate,
              onDateChanged: _onDateChanged,
            ),
            Expanded(
              child: FutureBuilder<List<Success>>(
                future: _successListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.1),
                      children: snapshot.data!
                          .map((success) => Dismissible(
                                key: Key(success.id!
                                    .toString()), // Handle null and convert to String
                                background: Container(
                                  color: Theme.of(context).primaryColorLight,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) async {
                                  // Assuming 'success.id' is the identifier of the Success item
                                  await SuccessDatabaseService()
                                      .deleteSuccess(success.id!);

                                  setState(() {
                                    snapshot.data!.remove(success);
                                  });
                                },
                                child: LikableItem(
                                  success: success,
                                ),
                              ))
                          .toList(),
                    );
                  } else if (selectedDate.isAfter(DateTime.now())) {
                    return const Text(
                        "You're adding successes in the future😁");
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
            ),
            // const SizedBox(
            //   height: 100,
            // ),
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
