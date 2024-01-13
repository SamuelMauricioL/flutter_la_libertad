// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_la_libertad/dance_gesture.dart';
import 'package:flutter_la_libertad/firebase_options.dart';
import 'package:flutter_la_libertad/widgets/note_icon.dart';
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

  final tapsDoc =
      FirebaseFirestore.instance.collection('taps').doc('p5UfoBHiNV1c58T2RpVD');

  Future<void> addTap() async {
    DocumentSnapshot doc = await tapsDoc.get();
    int counter = doc['counter'] as int;
    tapsDoc.update({'counter': counter + 1});
  }

  @override
  Widget build(BuildContext context) {
    return DanceGesture(
      onDoubleTap: () {
        addTap();
        toggleDance(true);
      },
      onStop: () => toggleDance(false),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NoteIcon(size: 30),
                        StreamBuilder(
                          stream: tapsDoc.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!['counter'].toString(),
                                style: const TextStyle(fontSize: 26),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
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
