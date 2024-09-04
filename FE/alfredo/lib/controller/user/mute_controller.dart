import 'package:volume_controller/volume_controller.dart';

class MuteController {
  static void toggleMute() async {
    double currentVolume = await VolumeController().getVolume();
    if (currentVolume > 0.0) {
      VolumeController().setVolume(0);
      print("System muted");
    } else {
      VolumeController().setVolume(0.5);
      print("Volume restored to 50%");
    }
  }
}
