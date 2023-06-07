import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProductName {
  videoCalling,
  voiceCalling,
  interactiveLiveStreaming,
  broadcastStreaming
}

class AgoraManager {
  // The RtcEngine instance
  late RtcEngine agoraEngine;
  ProductName currentProduct = ProductName.videoCalling;
  int localUid = 0;
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false;
  String appId = "";

  AgoraManager(this.appId) {
    // retrieve or request camera and microphone permissions
    [Permission.microphone, Permission.camera].request();
  }

  Future<void> setupVideoSDKEngine() async {

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
        appId: appId
    ));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          //showMessage("Local user uid:${connection.localUid} joined the channel");
            _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          sendMessage("Remote user uid:$remoteUid joined the channel");
            _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          sendMessage("Remote user uid:$remoteUid left the channel");
            _remoteUid = null;
        },
      ),
    );
  }

  Future<int> joinChannel(String channelName, String token, int localUid) async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: localUid,
    );

    return 0;
  }

  void sendMessage(String message) {
    // raise event to display message
  }
}
