class ICalData {
  final String uid;
  final DateTime? dtstart;
  final DateTime? dtend;
  final DateTime created;
  final String summary;
  final String? location;
  final String? description;

  ICalData({
    required this.uid,
    required this.created,
    required this.summary,
    this.description,
    this.dtend,
    this.dtstart,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'dtstart': dtstart,
      'dtend': dtend,
      'created': created,
      'summary': summary,
      'location': location,
      'description': description,
    };
  }
}
