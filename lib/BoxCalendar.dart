import 'package:flutter/material.dart';

class Box extends StatelessWidget{
  final String child;

  Box({required this.child});

  @override
  Widget build(BuildContext context){

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),

         child: Container(
          height: 150,
          color: Colors.deepPurple[200],
          child: Center(
            child: Text(
              child,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      );
  }
}