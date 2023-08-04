import 'package:flutter/material.dart';

class Box extends StatelessWidget{
  final String child;

  Box({required this.child});

  @override
  Widget build(BuildContext context){

        return Padding(
          // Vado ad inserire un padding laterale e verticale
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),

         child: Container(
          height: 135,
           decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [
                 Colors.deepPurple[200]!, // Colore di sfondo
                 Colors.deepPurple.withOpacity(0.8), // Colore lucido con opacità 0.8
               ],
             ),
             borderRadius: BorderRadius.circular(8.0),
             boxShadow: [
               BoxShadow(
                 color: Colors.deepPurple.withOpacity(0.3), // Ombra con opacità 0.3
                 spreadRadius: 2,
                 blurRadius: 4,
                 offset: Offset(0, 2), // Spostamento dell'ombra verso il basso
               ),
             ],
           ),
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