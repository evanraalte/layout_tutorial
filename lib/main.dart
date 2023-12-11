import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:layout_tutorial/add_item_dialog.dart';
import 'package:layout_tutorial/date_selector.dart';
import 'package:layout_tutorial/db.dart';
import 'package:layout_tutorial/likable_item.dart';

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
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _successListFuture =
        SuccessDatabaseService().successes(filterCreatedDate: selectedDate);
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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
            return const Text(
                'Come on, you must have achieved soemthing today!');
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
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // Full-screen blast
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // Add more colors as you like
              maxBlastForce: 10, // set a lower max blast force
              minBlastForce: 2, // set a lower min blast force
              numberOfParticles: 50, // number of particles to be emitted
            ),
            boxWithStuff,
          ],
        ),

        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () async {
              bool itemAdded = await showAddItemDialog(context, selectedDate);
              _refreshSuccessList();
              if (itemAdded) {
                _confettiController.play();
              }
            },
            tooltip: 'Create',
            child: const Icon(Icons.create),
          );
        }),
      ),
    );
  }

  ListView listViewSuccesses(
      BuildContext context, AsyncSnapshot<List<Success>> snapshot) {
    return ListView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
      children: snapshot.data!
          .map(
            (success) => LikableItem(
              success: success,
              refreshSuccessList: _refreshSuccessList,
            ),
          )
          .toList(),
    );
  }
}
