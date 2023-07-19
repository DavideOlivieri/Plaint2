import 'dart:math';

import 'package:flutter/material.dart';
import 'package:planit2/models/Calendar_model.dart';
import 'package:planit2/services/database_helper.dart';
import 'package:planit2/BoxCalendar.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}



class _homeState extends State<home> {
  @override
 List<Calendar> calendars = [];
// Calendar? calendar;

  final titleController = TextEditingController();
  showaddCalendarDialog() async{
    Calendar? calendar;

  await showDialog(
  context: context,
  builder: (context) => AlertDialog(title: const Text('Aggiungi nuovo Calendario', textAlign: TextAlign.center),

      content:Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
       TextField(
      controller: titleController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
      labelText: 'Titolo',
      ),
      ),
      ],
      ),
      actions: [  // Bottoni dentro il dialog evento
      TextButton(
      onPressed: () => Navigator.pop(context),
       child: const Text('Cancella'),
      ),
      TextButton(
       child: const Text('Aggiungi Calendario'),
       onPressed: () async {
         final titolo = titleController.value.text;
         int id = Random().nextInt(1000);

         final Calendar model = Calendar(id: id,titolo: titolo);

        if(calendar == null){
           await DatabaseHelper.addCalendar(model);
           Navigator.pop(context);
         }

       }
      ),
      ],
  ),
  );
  }

  Widget build(BuildContext context) {
    allCalendars();

    return Scaffold(
     appBar: AppBar(
      title: const Text('PlanIt'),
    ),
         body: Column(
         children: [

          Expanded(
           child: ListView.builder(
              itemCount: calendars.length,
              itemBuilder: (context, index) {
                final calendar = calendars[index];

               return GestureDetector(
                 onTap: () {
                   Navigator.pushNamed(context, '/Calendar',arguments: calendar.id);
                   },
                 child: Box(
                 child: calendar.titolo,
                  ),
                   );
                  }


                ),
           // }
          //),
          ),

          //  Navigator.pushNamed(context, '/Calendar');
          ],
    ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: ()  => showaddCalendarDialog(),
            label: const Text('Add Calendar')
        )
    );
  }

  void allCalendars() async{

    final dbHelper = DatabaseHelper();
    final allcalendars = await dbHelper.getAllCalendars();

    setState(() {
      calendars = allcalendars.map((data) => Calendar(
          id: data['id'],
          titolo: data['titolo'],
      )).toList();
    });
  }
}
