import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShakeAlarmService {
  static final ShakeAlarmService _instance = ShakeAlarmService._internal();
  factory ShakeAlarmService() => _instance;
  ShakeAlarmService._internal();

  static const double _shakeThreshold = 35.0;
  static const int _shakeCountWindowMs = 1000;
  static const int _shakeCountToTrigger = 3;
  static const Duration _cooldown = Duration(seconds: 10);

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  final List<DateTime> _recentShakes = [];
  DateTime? _lastTriggered;
  bool _isAlarmActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Function? onAlarmTriggered;

  void start(BuildContext context) {
    onAlarmTriggered = () => _showAlarmDialog(context);

    _accelSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(_onAccelerometerEvent);
  }

  void stop() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _audioPlayer.stop();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (_isAlarmActive) return;

    final now = DateTime.now();
    if (_lastTriggered != null && now.difference(_lastTriggered!) < _cooldown) {
      return;
    }

    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final g = acceleration / 9.81;

    if (g > _shakeThreshold) {
      _recentShakes.add(now);
    }

    _recentShakes.removeWhere(
      (t) => now.difference(t).inMilliseconds > _shakeCountWindowMs,
    );

    if (_recentShakes.length >= _shakeCountToTrigger) {
      _recentShakes.clear();
      _lastTriggered = now;
      _triggerAlarm();
    }
  }

  void _triggerAlarm() {
    _isAlarmActive = true;
    onAlarmTriggered?.call();
    _playAlarmSound();
    Future.delayed(const Duration(seconds: 3), () => _callEmergency());
  }

  void _playAlarmSound() {
    final bytes = _generateAlarmWav();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(BytesSource(bytes));
  }

  void stopAlarm() {
    _isAlarmActive = false;
    _audioPlayer.stop();
  }

  void _callEmergency() async {
    final uri = Uri.parse('tel:120');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Uint8List _generateAlarmWav() {
    final sampleRate = 44100;
    final durationMs = 1000;
    final numSamples = (sampleRate * durationMs / 1000).floor();
    final frequency = 880.0;
    final amplitude = 0.8;
    final beepOnMs = 300;
    final beepOffMs = 200;

    final pcmData = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final cyclePos = (i * 1000 / (beepOnMs + beepOffMs)) % 1.0;
      final isOn = cyclePos < (beepOnMs / (beepOnMs + beepOffMs));
      if (isOn) {
        final sample = amplitude * sin(2 * pi * frequency * t);
        pcmData[i] = (sample * 32767).round().clamp(-32768, 32767);
      } else {
        pcmData[i] = 0;
      }
    }

    final dataSize = numSamples * 2;
    final fileSize = 44 + dataSize;
    final header = ByteData(44);

    void setString(int offset, String value) {
      for (int i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    setString(0, 'RIFF');
    header.setUint32(4, fileSize - 8, Endian.little);
    setString(8, 'WAVE');
    setString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    setString(36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final wavBytes = Uint8List(fileSize);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    for (int i = 0; i < numSamples; i++) {
      final byteOffset = 44 + i * 2;
      wavBytes[byteOffset] = pcmData[i] & 0xFF;
      wavBytes[byteOffset + 1] = (pcmData[i] >> 8) & 0xFF;
    }

    return wavBytes;
  }

  void _showAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '紧急报警',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.yellow,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  '检测到剧烈晃动！\n疑似发生交通事故！\n正在拨打120急救电话...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ShakeAlarmService().stopAlarm();
                      Navigator.of(dialogContext).pop();
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      '取消报警（误触）',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:120');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                    label: const Text(
                      '立即拨打120',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
