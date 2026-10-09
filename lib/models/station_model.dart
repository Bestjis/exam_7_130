import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String? id;
  final String stationId, zone, officerEmail;
  final int aqi;
  final double pm25;

  Station({this.id, required this.stationId, required this.zone,
      required this.officerEmail, required this.aqi, required this.pm25});

  Map<String, dynamic> toMap() => {
        'stationId': stationId, 'zone': zone, 'officerEmail': officerEmail,
        'aqi': aqi, 'pm25': pm25,
      };

  factory Station.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return Station(
      id: d.id, stationId: m['stationId'], zone: m['zone'],
      officerEmail: m['officerEmail'], aqi: (m['aqi'] as num).toInt(),
      pm25: (m['pm25'] as num).toDouble(),
    );
  }
}