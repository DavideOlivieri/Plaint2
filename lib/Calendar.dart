import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:planit2/models/Event_model.dart';
import 'package:planit2/services/database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key
  }): super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    Key? key
  }): super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay timeEvent = TimeOfDay(hour: 10,minute: 30);
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  List<Event> events = [];



  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }


  showaddEventDialog() async{
    Event? event;
    String data = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final id_calendario = ModalRoute.of(context)!.settings.arguments as int;

    await showDialog(

        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aggiungi nuovo Evento', textAlign: TextAlign.center),

          content:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data, textAlign: TextAlign.center),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                ),
              ),
              TextField(
                controller: descController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                ),
              ),
              /*
              Row(
                children: [
                MaterialButton(
                  onPressed: () async {
                   final TimeOfDay? timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: timeEvent,
                        initialEntryMode: TimePickerEntryMode.dial,
                        );
                          if (timeOfDay != null){
                             setState(() => timeEvent = timeOfDay);
                          }
                        },
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                 ),
                 child: Text('Scegli orario inizio',style: TextStyle(color: Colors.white),),
                 color: Colors.blue,
              ),

                Text("${timeEvent.hour}:${timeEvent.minute}",
                  style: TextStyle(fontSize: 25),
              )

              ]
              )

               */
            ],
          ),
          actions: [  // Bottoni dentro il dialog evento
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancella'),
            ),
            TextButton(
              child: const Text('Aggiungi evento'),
              onPressed: () async {

                final titolo = titleController.value.text;
                final descrizione = descController.value.text;
                // int id = Random().nextInt(1000);
                int? id;

                final Event model = Event(id: id,data: data, titolo: titolo, descrizione: descrizione, id_calendario: id_calendario);

                if(event == null){
                   await DatabaseHelper.addEvent(model);
                   setState(() {
                     events.add(model); // Aggiungi il nuovo evento alla lista events
                   });
                   Navigator.pop(context);
                }

                if(titleController.text.isEmpty &&
                    descController.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sono richiesti titolo e descrizione'),
                        duration: Duration(seconds: 2),
                      )
                    );
                   }
                  },
            )
          ],
        )
    );
  } // fine dialog evento

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('PlanIt')),
        body:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
         TableCalendar(
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          focusedDay: _focusedDay,
          firstDay: _firstDay,
          lastDay: _lastDay,
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              filterEventsByDate();
            });
          },
          calendarStyle: const CalendarStyle(
            weekendTextStyle: TextStyle(
              color: Colors.red,
            ),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.red,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(day.toString()),
              );
            },
          ),
        ),

         Expanded(
            child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                color: Colors.deepPurple[200],
                margin: const EdgeInsets.all(10),
               child: ListTile(
                title: Text(event.titolo),
                subtitle: Text(event.descrizione),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {

                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          int eventId = event.id!.toInt();
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: Text('Conferma eliminazione'),
                                  content: Text(
                                      'Sei sicuro di voler eliminare l evento "' +
                                          event.titolo + '"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Chiudi il dialogo
                                      },
                                      child: Text('Annulla'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Esegui l'eliminazione dal database
                                        await DatabaseHelper.deleteEvent(event);
                                        Navigator.pop(
                                            context); // Chiudi il dialogo
                                        // Aggiorna l'elenco dei calendari per riflettere l'eliminazione
                                        setState(() {
                                          events.removeWhere((event) =>
                                          event.id == eventId);
                                        });
                                      },
                                      child: Text('Elimina'),
                                    ),
                                  ],
                                ),
                          );
                        },

                      )
                    ],
                  ),
                ),
              ),
              );
            }
            )
          ),

    ],
    ),


        floatingActionButton: FloatingActionButton.extended(
            onPressed: ()  => showaddEventDialog(),
            label: const Text('Add event')
        )
    );
  }

  void filterEventsByDate() async {
    String data = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final id_calendario = ModalRoute.of(context)!.settings.arguments as int;
    if (data != null) {
      final dbHelper = DatabaseHelper();
      final filteredEvents = await dbHelper.getEventsByDateAndCalendarId(data.toString(), id_calendario);

      setState(() {
        events = filteredEvents.map((data) => Event(
          id: data['id'],
          data: data['data'],
          titolo: data['titolo'],
          descrizione: data['descrizione'],
          id_calendario: data['id_calendario'],
        )).toList();
      });
    }
  }


}

