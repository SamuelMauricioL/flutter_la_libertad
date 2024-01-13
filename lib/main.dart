import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_la_libertad/firebase_options.dart';

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
      home: HeartView(),
    );
  }
}

class HeartView extends StatefulWidget {
  const HeartView({super.key});

  @override
  State<HeartView> createState() => _HeartViewState();
}

class _HeartViewState extends State<HeartView> {
  bool isFavorite = true;

  void _onFavoriteTap() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/flutter_la_libertad.png',
          width: 140,
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onDoubleTap: () => _onFavoriteTap(),
              child: Image.asset('assets/photo.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isFavorite
                ? const Icon(
                    Icons.favorite,
                    size: 30,
                    color: Colors.redAccent,
                  )
                : const Icon(
                    Icons.favorite_border,
                    size: 30,
                  ),
          ),
        ],
      ),
    );
  }
}
