import 'package:flutter/material.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      title: const Text('PlanIt'),
    ),
         body: Column(
        children: [
          ElevatedButton(onPressed: (){
            Navigator.pushNamed(context, '/Calendar');
           }, child: const Text('Calendario'))
          ],
    ),
    );
  }
}
