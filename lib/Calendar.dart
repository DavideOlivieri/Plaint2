import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key});

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

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aggiungi nuovo Evento', textAlign: TextAlign.center),

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
              TextField(
                controller: descController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                ),
              ),
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
            ],
          ),
          actions: [  // Bottoni dentro il dialog evento
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancella'),
            ),
            TextButton(
              child: const Text('Aggiungi evento'),
              onPressed: () {
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
        body: TableCalendar(
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
        floatingActionButton: FloatingActionButton.extended(
            onPressed: ()  => showaddEventDialog(),
            label: const Text('Add event')
        )
    );
  }
}
