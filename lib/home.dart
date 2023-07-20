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
           // int id = Random().nextInt(1000);
           int? id;

         final Calendar model = Calendar(id: id,titolo: titolo);

        if(titolo != '') {
          if (calendar == null) {
            await DatabaseHelper.addCalendar(model);
            titleController.text = '';
            Navigator.pop(context);
          }
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inserire il titolo'),
                duration: Duration(seconds: 2),
              )
          );
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

                  onLongPress: () {
                  // Mostra un dialogo di conferma per l'eliminazione
                      int calId = calendar.id!.toInt();
                    showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Conferma eliminazione'),
                      content: Text('Sei sicuro di voler eliminare il calendario "'+calendar.titolo+'"?'),
                      actions: [
                     TextButton(
                      onPressed: () {
                      Navigator.pop(context); // Chiudi il dialogo
                      },
                      child: Text('Annulla'),
                    ),
                     TextButton(
                      onPressed: () async {
                      // Esegui l'eliminazione dal database
                      await DatabaseHelper.deleteCalendar(calId);
                      Navigator.pop(context); // Chiudi il dialogo
                      // Aggiorna l'elenco dei calendari per riflettere l'eliminazione
                      setState(() {
                      calendars.removeWhere((calendar) => calendar.id == calId);
                      });
                      },
                      child: Text('Elimina'),
                    ),
                    ],
                    ),
                    );
                    },

                   child: Box(
                   child: calendar.titolo,
                    ),
                     );
                    }

                ),
             ),
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
