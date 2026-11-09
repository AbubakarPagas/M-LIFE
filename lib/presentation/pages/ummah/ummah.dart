import 'package:flutter/material.dart';

class Ummah extends StatefulWidget {
  const Ummah({super.key});

  @override
  State<Ummah> createState() => _UmmahState();
}

class _UmmahState extends State<Ummah> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Ummah page",
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 20,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(),
    );
  }
}
