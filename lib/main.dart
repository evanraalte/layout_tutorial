import 'package:flutter/material.dart';
import 'package:layout_tutorial/add_item_dialog.dart';
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

    Success newSuccess =
        Success(title: title, subtitle: subtitle, date: selectedDate);
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

    var boxWithStuff = Expanded(
      child: FutureBuilder<List<Success>>(
        future: _successListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return listViewSuccesses(context, snapshot);
          } else if (selectedDate.isAfter(DateTime.now())) {
            return const Text("You're adding successes in the future😁");
          } else {
            return const Text('No data available');
          }
        },
      ),
    );
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
            boxWithStuff,
          ],
        ),
        floatingActionButton: ExpandableFloatingActionButton(
          onAddItem: _addLikableItem,
          onAddCustomItem: (BuildContext context) {
            return showAddItemDialog(
                context, selectedDate, _refreshSuccessList);
          },
        ),
      ),
    );
  }

  ListView listViewSuccesses(
      BuildContext context, AsyncSnapshot<List<Success>> snapshot) {
    return ListView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
      children: snapshot.data!
          .map((success) => Dismissible(
                key: Key(success.id!
                    .toString()), // Handle null and convert to String
                background: Container(
                  color: Theme.of(context).primaryColorLight,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  // Assuming 'success.id' is the identifier of the Success item
                  await SuccessDatabaseService().deleteSuccess(success.id!);

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
  }
}
