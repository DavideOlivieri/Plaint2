class Calendar {
  final int? id;
  final String titolo;

  const Calendar({required this.id, required this.titolo});

  factory Calendar.fromJson(Map<String,dynamic> json) => Calendar(
      id: json['id'],
      titolo: json['titolo']
  );


  Map<String,dynamic> toJson() => {
    'id': id,
    'titolo': titolo
  };
}
