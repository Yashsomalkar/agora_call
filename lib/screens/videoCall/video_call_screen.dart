import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_voice_call/utils/commen_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import '../../agora_config.dart';
import '../../components/rounded_button.dart';
import '../../constants.dart';
import '../../size_config.dart';

class VideoCallScreen extends StatefulWidget {
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine engine;

  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool isMicMute = false;
  bool isCameraOff = false;
  Stopwatch watch = Stopwatch();
   Timer? timer;
  String elapsedTime = '';
  bool isTimerRunning = false;

  //late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //player = AudioPlayer();
  }

  // Init the app
  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();
    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(appId);
    engine = await RtcEngine.createWithContext(context);
    // Define event handling printic
    engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print('joinChannelSuccess ${channel} ${uid}');
        //_remoteUid != 0 ? playSound(SoundsData.callerSound) : player.stop();
          _setTimer();

        setState(() {
          _joined = true;
        });
      },
      userJoined: (int uid, int elapsed) async {
        print('userJoined ${uid}');
        // if (player.playing) {
        //   await player.stop();
        // }
        setState(() {
          _remoteUid = uid;
          _switch = !_switch;
        });
      },
      leaveChannel: (stats) {
        watch.stop();
        print('leaveChannel ${stats.toJson()}');
        //playSound(SoundsData.callDisconnected);
      },
      connectionInterrupted: () {
        //playSound(SoundsData.connectionLost);
        print('connectionInterrupted');
      },
      connectionLost: () async {
        print('connectionLost');
        //playSound(SoundsData.connectionLost);
      },
      userOffline: (int uid, UserOfflineReason reason) {
                  watch.stop();

        print('userOffline ${uid}');
        // playSound(SoundsData.connectionLost);

        setState(() {
          _remoteUid = 0;
        });
        leaveChannel();
      },
    ));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name as 123
    await engine.joinChannel(token, 'test', null, 0);
  }

  Future<void> updateTime(Timer? timer) async {
    if (watch.isRunning) {
      elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      print('elapsedTime $elapsedTime');
    }
  }
void _setTimer() {
    watch.start();
    isTimerRunning = true;
    timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
    updateTime(timer);
  }
  // Future<void> playSound(String fileName) async {
  //   if (player.playing) {
  //     await player.stop();
  //   }
  //   await player.setAsset(fileName);
  //   player.setLoopMode(LoopMode.off);
  //   player.play();
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(title: Text(elapsedTime),),
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _switch = !_switch;
                      });
                    },
                    child: Center(
                      child: _switch
                          ? _renderLocalPreview()
                          : _renderRemoteVideo(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }

  // Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: RtcLocalView.SurfaceView());
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: RtcRemoteView.SurfaceView(
          uid: _remoteUid,
          channelId: "test",
        ),
      );
    } else {
      return Text(
        'Kullanıcı bekleniyor...',
        textAlign: TextAlign.center,
      );
    }
  }

  void switchMicrophone() {
    setState(() {
      isMicMute = !isMicMute;
    });
    engine.enableLocalAudio(!isMicMute).then((value) {}).catchError((err) {
      print('enableLocalAudio $err');
    });
  }

  void switchEnableCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
    engine.enableLocalVideo(!isCameraOff).then((value) {}).catchError((err) {
      print('disableCameraSwitch $err');
    });
  }

  Future<void> leaveChannel() async {
    try {
      await engine.leaveChannel();
      await engine.destroy();
      //player.stop();
      Navigator.pop(context);
    } catch (e) {
      print('Error $e');
    }
  }

  void switchCamera() {
    try {
      engine.switchCamera().catchError((err) {
        print('switchCamera $err');
      });
    } catch (e) {
      print('Error $e');
    }
  }

  Container buildBottomNavBar() {
    return Container(
      color: kBackgoundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              RoundedButton(
                color: kRedColor,
                iconColor: Colors.white,
                size: 48,
                iconSrc: "assets/icons/Icon Close.svg",
                press: () {
                  leaveChannel();
                },
              ),
              Spacer(),
              RoundedButton(
                color: isMicMute ? Colors.white : Color(0xFF2C384D),
                iconColor: isMicMute ? Color(0xFF2C384D) : Colors.white,
                size: 48,
                iconSrc: "assets/icons/Icon Mic.svg",
                press: () {
                  switchMicrophone();
                },
              ),
              RoundedButton(
                color: isCameraOff ? Colors.white : Color(0xFF2C384D),
                iconColor: isCameraOff ? Color(0xFF2C384D) : Colors.white,
                size: 48,
                iconSrc: "assets/icons/Icon Video.svg",
                press: () {
                  switchEnableCamera();
                },
              ),
              RoundedButton(
                color: Color(0xFF2C384D),
                iconColor: Colors.white,
                size: 48,
                iconSrc: "assets/icons/Icon Repeat.svg",
                press: () {
                  switchCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
