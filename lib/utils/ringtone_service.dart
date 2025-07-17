import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:medinest/utils/debug.dart';
class Ringtone {
  final String title;
  final String uri;

  Ringtone({required this.title, required this.uri});

  factory Ringtone.fromJson(Map<String, dynamic> json) {
    return Ringtone(
      title: json['title'],
      uri: json['uri'],
    );
  }
}
class RingtoneService {
  static AudioPlayer audioPlayer = AudioPlayer();

  static Future<List<Ringtone>> getSystemRingtones() async {
    List<Ringtone> ringtones = [];

    try {
      const MethodChannel platform = MethodChannel('ringtone_channel');
      final List<dynamic> result = await platform.invokeMethod('getSystemRingtones');

      for (var ringtoneData in result) {
        Ringtone ringtone = Ringtone.fromJson(ringtoneData);
        ringtones.add(ringtone);
      }
    } on PlatformException catch (e) {
      Debug.printLog('Failed to get system ringtones: ${e.message}');
    }

    return ringtones;
  }

  static Future<void> playRingtone(String uri) async {
    // AudioSource source = AudioSource.uri(audioUri.toString());
   await audioPlayer.play(DeviceFileSource(uri));
  }

  static Future<void> stopRingtone() async {
    await audioPlayer.stop();
  }
}