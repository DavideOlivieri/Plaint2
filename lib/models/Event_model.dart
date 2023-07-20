class Event{
  final int? id;
  final String data;
  final String titolo;
  final String descrizione;
  final String orario_inizio;
  final String orario_fine;
  final int? id_calendario;

  const Event({required this.id, required this.data, required this.titolo,required this.descrizione,required this.orario_inizio,required this.orario_fine,required this.id_calendario});

  factory Event.fromJson(Map<String,dynamic> json) => Event(
    id: json['id'],
    data: json['data'],
    titolo: json['titolo'],
    descrizione: json['descrizione'],
    orario_inizio: json['orario_inizio'],
    orario_fine: json['orario_fine'],
    id_calendario: json['id_caledendario']
  );

  Map<String,dynamic> toJson() => {
    'id': id,
    'data': data,
    'titolo': titolo,
    'descrizione': descrizione,
    'orario_inizio': orario_inizio,
    'orario_fine' : orario_fine,
    'id_calendario' : id_calendario
  };

}