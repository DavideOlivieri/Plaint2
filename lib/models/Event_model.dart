class Event{
  final int? id;
  final String data;
  final String titolo;
  final String descrizione;

  const Event({required this.id, required this.data, required this.titolo,required this.descrizione});

  factory Event.fromJson(Map<String,dynamic> json) => Event(
    id: json['id'],
    data: json['data'],
    titolo: json['titolo'],
    descrizione: json['descrizione']
  );

  Map<String,dynamic> toJson() => {
    'id': id,
    'data': data,
    'titolo': titolo,
    'descrizione': descrizione
  };

}