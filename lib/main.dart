import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: MaterialApp(
        title: 'Test app',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: Column(
        children: [
          const Row(children: [
            Expanded(child: CheapWidget()),
            Expanded(child: ExpensiveWidget())
          ]),
          const Row(children: [Expanded(child: ObjectProviderWidget())]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().start();
                },
                child: const Text('Start')),
            TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().stop();
                },
                child: const Text('Stop')),
          ]),
        ],
      ),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubs;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubs;

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 1),
    ).listen(
      (_) {
        _cheapObject = CheapObject();
        notifyListeners();
      },
    );

    _expensiveObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 10),
    ).listen(
      (_) {
        _expensiveObject = ExpensiveObject();
        notifyListeners();
      },
    );
  }

  void stop() {
    _cheapObjectStreamSubs.cancel();
    _expensiveObjectStreamSubs.cancel();
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );

    return Container(
      height: 100,
      color: Colors.red,
      child: Column(
        children: [
          const Text('Expensive widget'),
          const Text('Last updated'),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (provider) => provider.cheapObject,
    );

    return Container(
      height: 100,
      color: Colors.green,
      child: Column(
        children: [
          const Text('Cheap widget'),
          const Text('Last updated'),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();

    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text('Object Provider Widget'),
          const Text('ID'),
          Text(provider.id),
        ],
      ),
    );
  }
}
