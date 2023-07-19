import 'package:flutter/material.dart';

class Box extends StatelessWidget{
  final String child;

  Box({required this.child});

  @override
  Widget build(BuildContext context){

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),

        child: Container(
          height: 200,
          color: Colors.deepPurple[100],
          child: Center(
            child: Text(
              child,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
  }
}