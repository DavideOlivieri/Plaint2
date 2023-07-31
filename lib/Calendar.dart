import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TimeOfDay timeEventI = TimeOfDay.now();
  TimeOfDay timeEventF = TimeOfDay.now();


  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  List<Event> events = [];
  List<Event> all_events = [];
  Map<DateTime, List<Event>> dateConEvento = {};
  Set<String> dates = {};



  final titleController = TextEditingController();
  final descController = TextEditingController();
  late String ora_inizio;
  late String ora_fine;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    allEvents();
  }

 _groupEvents (List<Event> events) {
   Map<DateTime, List<Event>> _groupedEvents = {};
   events.forEach((event) {
     DateTime date = DateTime.parse(event.data);
     if(_groupedEvents[date] == null) _groupedEvents[date] = [];
     _groupedEvents[date]?.add(event);
   });
   return _groupedEvents;
 }

  Set<String> getDatesWithEvents(List<Event> events) {
    Set<String> datesWithEvents = {};

    events.forEach((event) {
      DateTime date = DateTime.parse(event.data); // Correzione qui
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      datesWithEvents.add(formattedDate);
    });

    return datesWithEvents;
  }

  showaddEventDialog() async{
    Event? event;
    String data = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final id_calendario = ModalRoute.of(context)!.settings.arguments as int;

    await showDialog(

        context: context,
        builder: (context) => StatefulBuilder(
         builder: (context, setState) => AlertDialog(
          title: const Text('Aggiungi nuovo Evento', textAlign: TextAlign.center),

          content:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data, textAlign: TextAlign.center),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                ),
              ),
              TextField(
                controller: descController,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                ),
              ),

              Row(
                children: [
                MaterialButton(
                  onPressed: () async {
                   final TimeOfDay? timeSelectedInizio = await showTimePicker(
                        context: context,
                        initialTime: timeEventI,
                        initialEntryMode: TimePickerEntryMode.dial,
                        );
                          if (timeSelectedInizio != null){
                            ora_inizio = timeSelectedInizio.hour.toString().padLeft(2, '0') +':'+ timeSelectedInizio.minute.toString().padLeft(2, '0');
                             setState(() {
                               timeEventI = timeSelectedInizio;
                             });
                          }
                        },

                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                 ),
                 child: Text('Scegli orario inizio',style: TextStyle(color: Colors.white),),
                 color: Colors.blue,

              ),
                // padLeft, invece di 8 scrive 08
                Text("${timeEventI.hour.toString().padLeft(2, '0')}:${timeEventI.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 25),
                 )

              ]
              ),

              Row(
                  children: [
                    MaterialButton(
                      onPressed: () async {

                        final TimeOfDay? timeSelectedFine  = await showTimePicker(
                          context: context,
                          initialTime: timeEventF,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                          if (timeSelectedFine != null) {
                            setState(() {ora_fine =
                                  timeSelectedFine.hour.toString().padLeft(2, '0') + ':' +
                                      timeSelectedFine.minute.toString().padLeft(2, '0');
                              timeEventF = timeSelectedFine;
                            });
                          }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('Scegli orario fine',style: TextStyle(color: Colors.white),),
                      color: Colors.blue,
                    ),

                    Text("${timeEventF.hour.toString().padLeft(2, '0')}:${timeEventF.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 25),
                    )
                  ]
              )
            ],
          ),
          actions: [
            // Bottoni dentro il dialog evento
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancella'),
            ),
            TextButton(
              child: const Text('Aggiungi evento'),
              onPressed: () async {

                final titolo = titleController.value.text;
                final descrizione = descController.value.text;

                TimeOfDay inizio = stringToTimeOfDay(ora_inizio);
                TimeOfDay fine = stringToTimeOfDay(ora_fine);

                // int id = Random().nextInt(1000);
                int? id;
                // Se l'orario di fine è maggiore rispetto all'orario di inizio i dati
                // vengono salvati nel database
                if(titolo != '') {
                  if (fine.hour >= inizio.hour || fine.hour == inizio.hour &&
                      fine.minute >= inizio.minute) {
                    final Event model = Event(id: id,
                        data: data,
                        titolo: titolo,
                        descrizione: descrizione,
                        orario_inizio: ora_inizio,
                        orario_fine: ora_fine,
                        id_calendario: id_calendario);

                    if (event == null) {
                      await DatabaseHelper.addEvent(model);
                      setState(() {
                        events.add(model); // Aggiungi il nuovo evento alla lista events
                      });
                      titleController.text = '';
                      descController.text = '';
                      Navigator.pop(context);
                    }
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orario fine > orario inizio'),
                          duration: Duration(seconds: 2),
                        )
                    );
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
               )
              ],
             )
            )
            ).then((value) {
              setState(() {
                events;
              });
            });
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
          markerBuilder: (context, date, events) {
            //  allEvents();

            // dateConEvento = _groupEvents(all_events);
             dates = getDatesWithEvents(all_events);


           String formattedDate = DateFormat('yyyy-MM-dd').format(date);
             // List<Widget> positionedWidgets = dates.map((dateWithEvent) {
             if(dates.contains(formattedDate)){
              return Positioned(
                top: 37,
                right: 23,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    // Colore del pallino
                  ),
                  width: 8,
                  height: 8,
                ),
              );
            }
         },

                headerTitleBuilder: (context, day) {
                  String formattedDate = DateFormat('MMMM yyyy').format(day);

                   return Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(formattedDate,textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),

                  );

                },
            )
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
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column( // Prima riga: mostra l'orario di inizio e fine
                        children: [
                          Icon(Icons.access_time), // Icona per indicare l'orario
                          SizedBox(width: 5),
                          Text(
                            "${event.orario_inizio} - ${event.orario_fine}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Expanded(
                       child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(height: 5), // Spazio tra righe
                        Text(
                        event.titolo, // Seconda riga: mostra il titolo
                        style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5), // Spazio tra righe
                        Text(
                        event.descrizione, // Terza riga: mostra la descrizione
                        style: TextStyle(fontSize: 14),
                        ),
                        ]
                        )
                      )
                    ],
                  ),

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
                                  content: Text('Sei sicuro di voler eliminare l evento "' +
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
               )
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
          orario_inizio: data['orario_inizio'],
          orario_fine: data['orario_fine'],
          id_calendario: data['id_calendario'],
        )).toList();
      });
    }
  }

  void allEvents() async{

    final dbHelper = DatabaseHelper();
    final allevents = await dbHelper.allEvents();
    setState(() {
      all_events = allevents.map((data) => Event(
        id: data['id'],
        data: data['data'],
        titolo: data['titolo'],
        descrizione: data['descrizione'],
        orario_inizio: data['orario_inizio'],
        orario_fine: data['orario_fine'],
        id_calendario: data['id_calendario'],
      )).toList();
    });

  }

  void allEventsForCalendar() async{

    final id_calendario = ModalRoute.of(context)!.settings.arguments as int;
    final dbHelper = DatabaseHelper();
    final allevents = await dbHelper.allEventsForThisCalendar(id_calendario);
    setState(() {
      all_events = allevents.map((data) => Event(
        id: data['id'],
        data: data['data'],
        titolo: data['titolo'],
        descrizione: data['descrizione'],
        orario_inizio: data['orario_inizio'],
        orario_fine: data['orario_fine'],
        id_calendario: data['id_calendario'],
      )).toList();
    });

  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    List<String> parts = timeString.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }


}

