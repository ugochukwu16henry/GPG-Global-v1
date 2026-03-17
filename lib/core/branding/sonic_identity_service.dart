import 'package:flutter/services.dart';

enum GpgToneType {
  messageReceived,
  missionPeerFound,
  dailyScriptureOrBirthday,
}

class GpgToneProfile {
  const GpgToneProfile({
    required this.type,
    required this.displayName,
    required this.emotionalIntent,
    required this.recommendedAssetPath,
  });

  final GpgToneType type;
  final String displayName;
  final String emotionalIntent;
  final String recommendedAssetPath;
}

class SonicIdentityService {
  const SonicIdentityService();

  static const Map<GpgToneType, GpgToneProfile> profiles = {
    GpgToneType.messageReceived: GpgToneProfile(
      type: GpgToneType.messageReceived,
      displayName: 'Acoustic Pluck',
      emotionalIntent: 'Welcoming friendship',
      recommendedAssetPath: 'assets/audio/tones/message_pluck.mp3',
    ),
    GpgToneType.missionPeerFound: GpgToneProfile(
      type: GpgToneType.missionPeerFound,
      displayName: 'Uplifting Riser',
      emotionalIntent: 'Excitement and reunion',
      recommendedAssetPath: 'assets/audio/tones/mission_riser.mp3',
    ),
    GpgToneType.dailyScriptureOrBirthday: GpgToneProfile(
      type: GpgToneType.dailyScriptureOrBirthday,
      displayName: 'Warm Chime',
      emotionalIntent: 'Sacred and caring',
      recommendedAssetPath: 'assets/audio/tones/sacred_chime.mp3',
    ),
  };

  Future<void> preview(GpgToneType toneType) async {
    switch (toneType) {
      case GpgToneType.messageReceived:
      case GpgToneType.missionPeerFound:
        await SystemSound.play(SystemSoundType.click);
      case GpgToneType.dailyScriptureOrBirthday:
        await SystemSound.play(SystemSoundType.alert);
    }
  }
}