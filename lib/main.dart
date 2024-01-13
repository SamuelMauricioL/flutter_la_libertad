// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_la_libertad/dance_gesture.dart';
import 'package:flutter_la_libertad/utils/debouncer.dart';
import 'package:rive/rive.dart';

void main() {
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

  final debouncer = Debouncer(milliseconds: 1000);
  void _dashDance(bool dance) {
    debouncer.run(() {
      print('dance: $dance');
      setState(() => isDance?.value = dance);
    });
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

  @override
  Widget build(BuildContext context) {
    return DanceGesture(
      onAddNotes: () => toggleDance(true),
      onSingleTap: () => toggleDance(false),
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
