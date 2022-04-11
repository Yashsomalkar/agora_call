import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../agora_config.dart';
import '../../../components/dial_user_pic.dart';
import '../../../components/rounded_button.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import 'dial_button.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _joined = false;
  int _remoteUid = 0;
  bool isMuted = false;
  bool isSpeakerOpen = false;
  late RtcEngine engine;

  @override
  void initState() {
    super.initState();
    initPlatformState(context);
  }

  // Init the app
  Future<void> initPlatformState(BuildContext buildContext) async {
    // Get microphone permission
    await [Permission.microphone].request();

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(appId);
    engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print('joinChannelSuccess ${channel} ${uid}');
        setState(() {
          _joined = true;
        });
      },
      userJoined: (int uid, int elapsed) {
        print('userJoined ${uid}');
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        print('userOffline ${uid} ${reason.toString()}');
        setState(() {
          _remoteUid = 0;
        });
        engine.leaveChannel();
        Navigator.pop(buildContext);
      },
    ));
    // Join channel with channel name as 123
    await engine.joinChannel(token, 'test', null, 0);
  }

  void switchSpeakerphone() {
    setState(() {
      isSpeakerOpen = !isSpeakerOpen;
    });
    try {
      engine.setEnableSpeakerphone(isSpeakerOpen).then((value) {
        engine.setInEarMonitoringVolume(400);
      }).catchError((err) {
        print('setEnableSpeakerphone $err');
      });
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VerticalSpacing(),
            DialUserPic(image: "assets/images/calling_face.png"),
            VerticalSpacing(),
            Text(
              "Defne Demir",
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(color: Colors.white),
            ),
            Text(
              !_joined
                  ? "Bağlanılıyor..."
                  : _remoteUid == 0
                      ? "Kullanıcı bekleniyor..."
                      : _remoteUid.toString(),
              style: TextStyle(color: Colors.white60),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DialButton(
                  iconSrc: "assets/icons/mic_off.svg",
                  text: "Sessiz",
                  isActive: isMuted,
                  press: () {
                    setState(() {
                      isMuted = !isMuted;
                    });
                    engine.muteLocalAudioStream(isMuted);
                  },
                ),
                RoundedButton(
                  iconSrc: "assets/icons/call_end.svg",
                  press: () {
                    engine.leaveChannel();
                    Navigator.pop(context);
                  },
                  color: kRedColor,
                  iconColor: Colors.white,
                ),
                DialButton(
                  isActive: isSpeakerOpen,
                  iconSrc: "assets/icons/Icon Volume.svg",
                  text: "Hoparlör",
                  press: () {
                    switchSpeakerphone();
                  },
                ),
              ],
            ),
            VerticalSpacing(),
          ],
        ),
      ),
    );
  }
}
