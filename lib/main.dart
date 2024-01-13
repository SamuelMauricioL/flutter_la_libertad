// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_la_libertad/dance_gesture.dart';
import 'package:flutter_la_libertad/firebase_options.dart';
import 'package:rive/rive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: View(),
    );
  }
}

class View extends StatefulWidget {
  const View({super.key});

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  Artboard? riveArtboard;
  SMIBool? isDance;
  SMITrigger? isLookUp;

  @override
  void initState() {
    super.initState();
    _loadDashAnimation();
    _setCounter();
  }

  void _loadDashAnimation() {
    rootBundle.load('assets/dash.riv').then(
      (data) async {
        try {
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;
          var controller =
              StateMachineController.fromArtboard(artboard, 'birb');
          if (controller != null) {
            artboard.addController(controller);
            isDance = controller.findSMI('dance');
            isLookUp = controller.findSMI('look up');
          }
          setState(() => riveArtboard = artboard);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  void toggleDance(bool newValue) {
    setState(() => isDance!.value = newValue);
  }

  CollectionReference taps = FirebaseFirestore.instance.collection('taps');
  int counter = 0;

  Future<void> _setCounter() async {
    final tapQuery = await taps.get();
    final tapDoc = tapQuery.docs;

    final tapDataFormated = json.encode(tapDoc.first.data());
    final tapDataDecoded = json.decode(tapDataFormated);
    setState(() {
      counter = tapDataDecoded['counter'] as int;
    });
  }

  Future<void> addTap() async {
    final tapQuery = await taps.get();
    final tapDoc = tapQuery.docs;

    taps.doc(tapDoc.first.id).set({
      'counter': counter += 1,
    });
    await _setCounter();
  }

  @override
  Widget build(BuildContext context) {
    return DanceGesture(
      onAddNotes: () => toggleDance(true),
      onSingleTap: () {
        addTap();
        toggleDance(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/flutter_la_libertad.png',
            width: 140,
          ),
          backgroundColor: Colors.white,
        ),
        body: riveArtboard == null
            ? const SizedBox()
            : GestureDetector(
                child: Column(
                  children: [
                    Text(counter.toString()),
                    Expanded(
                      child: Rive(
                        artboard: riveArtboard!,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
