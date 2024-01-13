import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  bool isLiked = false;

  void onLikePressed() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter La Libertad"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/flutter_la_libertad.png',
          ),
          GestureDetector(
            onDoubleTap: () => onLikePressed(),
            child: Icon(
              Icons.favorite,
              size: 40,
              color: isLiked ? Colors.red : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
