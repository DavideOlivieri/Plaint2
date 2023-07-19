class Event{
  final int? id;
  final String data;
  final String titolo;
  final String descrizione;
  final int? id_calendario;

  const Event({required this.id, required this.data, required this.titolo,required this.descrizione,required this.id_calendario});

  factory Event.fromJson(Map<String,dynamic> json) => Event(
    id: json['id'],
    data: json['data'],
    titolo: json['titolo'],
    descrizione: json['descrizione'],
    id_calendario: json['id_caledendario']
  );

  Map<String,dynamic> toJson() => {
    'id': id,
    'data': data,
    'titolo': titolo,
    'descrizione': descrizione,
    'id_calendario' : id_calendario
  };

}