import 'dart:async';

import 'package:flutter/services.dart';

import '../utils/logger.dart';
import '../utils/platform_info.dart';

/// Observes whether the microphone is currently in use by *any* application
/// (Teams, Zoom, Meet, Slack, Discord, FaceTime, Webex, Skype, …).
///
/// The Dart side is fully implemented here; each desktop platform provides the
/// native sensor through an [EventChannel]. See `docs/NATIVE_INTEGRATION.md`
/// for the Swift / C++ handlers to drop into the generated runners.
///
/// On platforms without a reliable, permission-free detector the stream simply
/// reports `false` (microphone free) so reminders are never wrongly withheld.
class MicrophoneActivityService {
  MicrophoneActivityService({
    EventChannel? eventChannel,
    MethodChannel? methodChannel,
  })  : _eventChannel =
            eventChannel ?? const EventChannel('eyeguard/mic_activity/events'),
        _methodChannel =
            methodChannel ?? const MethodChannel('eyeguard/mic_activity');

  final EventChannel _eventChannel;
  final MethodChannel _methodChannel;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<dynamic>? _nativeSub;
  bool _inUse = false;

  /// Latest known state. `true` => microphone is currently active.
  bool get isInUse => _inUse;

  /// Broadcast stream emitting `true` when the mic becomes busy and `false`
  /// when it is released.
  Stream<bool> get stream => _controller.stream;

  /// Begin listening to native microphone-activity events.
  Future<void> start() async {
    if (!PlatformInfo.supportsMicDetection) {
      AppLogger.info(
        'Mic detection unsupported on this platform; assuming microphone free.',
      );
      _emit(false);
      return;
    }

    try {
      _nativeSub = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) => _emit(event == true),
        onError: (Object error) {
          AppLogger.warning('Mic activity stream error: $error');
          _emit(false);
        },
      );
      // Seed with the current value so callers start from a known state.
      final bool current = await _queryCurrent();
      _emit(current);
    } on PlatformException catch (e) {
      AppLogger.warning('Mic detection unavailable: ${e.message}');
      _emit(false);
    }
  }

  Future<bool> _queryCurrent() async {
    try {
      final bool? value =
          await _methodChannel.invokeMethod<bool>('isMicrophoneInUse');
      return value ?? false;
    } on PlatformException {
      return false;
    }
  }

  void _emit(bool value) {
    if (value == _inUse && _controller.hasListener) return;
    _inUse = value;
    if (!_controller.isClosed) _controller.add(value);
  }

  Future<void> dispose() async {
    await _nativeSub?.cancel();
    await _controller.close();
  }
}
