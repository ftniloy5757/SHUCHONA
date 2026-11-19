import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shuchona/core/localization/app_locale.dart';

/// Unified Voice Engine wrapping `flutter_tts` (Bangla & English read-aloud)
/// and `speech_to_text` (Bangla `bn_BD` & English `en_US` push-to-talk).
/// Includes graceful fallback state handling for emulators/simulators.
class VoiceState {
  const VoiceState({
    this.isSpeaking = false,
    this.speakingTag,
    this.isListening = false,
    this.sttAvailable = false,
    this.recognizedWords = '',
    this.soundLevel = 0.0,
    this.statusMessage,
  });

  final bool isSpeaking;
  final String? speakingTag;
  final bool isListening;
  final bool sttAvailable;
  final String recognizedWords;
  final double soundLevel;
  final String? statusMessage;

  VoiceState copyWith({
    bool? isSpeaking,
    String? speakingTag,
    bool clearSpeakingTag = false,
    bool? isListening,
    bool? sttAvailable,
    String? recognizedWords,
    double? soundLevel,
    String? statusMessage,
    bool clearStatus = false,
  }) {
    return VoiceState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speakingTag: clearSpeakingTag ? null : (speakingTag ?? this.speakingTag),
      isListening: isListening ?? this.isListening,
      sttAvailable: sttAvailable ?? this.sttAvailable,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      soundLevel: soundLevel ?? this.soundLevel,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
    );
  }
}

class VoiceController extends StateNotifier<VoiceState> {
  VoiceController() : super(const VoiceState()) {
    _initTts();
  }

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _sttInitialized = false;

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.02);
      await _tts.setVolume(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) {
          state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
        }
      });
      _tts.setCancelHandler(() {
        if (mounted) {
          state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
        }
      });
      _tts.setErrorHandler((_) {
        if (mounted) {
          state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
        }
      });
    } catch (e) {
      debugPrint('SHUCHONA TTS init note: $e');
    }
  }

  Future<void> speak(
    String text, {
    required AppLocale locale,
    String? tag,
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    // Toggle off if pressing the same speaking button
    if (state.isSpeaking && tag != null && state.speakingTag == tag) {
      await stopSpeaking();
      return;
    }

    try {
      await _tts.stop();
      await _tts.setLanguage(locale.ttsLanguageCode);
      state = state.copyWith(
        isSpeaking: true,
        speakingTag: tag ?? cleaned.hashCode.toString(),
        clearStatus: true,
      );
      final result = await _tts.speak(cleaned);
      // On headless test runners where TTS doesn't fire completion callbacks,
      // ensure state cleanly resets if speak returns immediately without playing.
      if (result == 0 && mounted) {
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (mounted && state.speakingTag == (tag ?? cleaned.hashCode.toString())) {
            state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
          }
        });
      }
    } catch (e) {
      debugPrint('SHUCHONA TTS speak fallback: $e');
      state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (mounted) {
      state = state.copyWith(isSpeaking: false, clearSpeakingTag: true);
    }
  }

  Future<bool> _ensureSttInitialized() async {
    if (_sttInitialized) return state.sttAvailable;
    try {
      final ok = await _stt.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            state = state.copyWith(isListening: false, soundLevel: 0.0);
          }
        },
        onError: (err) {
          if (!mounted) return;
          state = state.copyWith(
            isListening: false,
            soundLevel: 0.0,
            statusMessage: err.errorMsg,
          );
        },
      );
      _sttInitialized = true;
      state = state.copyWith(sttAvailable: ok);
      return ok;
    } catch (e) {
      debugPrint('SHUCHONA STT init unavailable on this platform: $e');
      _sttInitialized = true;
      state = state.copyWith(sttAvailable: false);
      return false;
    }
  }

  /// Starts Bangla (`bn_BD`) or English (`en_US`) voice recognition.
  Future<bool> startListening({
    required AppLocale locale,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    await stopSpeaking();
    final available = await _ensureSttInitialized();
    if (!available) {
      state = state.copyWith(
        isListening: false,
        statusMessage: locale.isBangla
            ? 'মাইক্রোফোন পাওয়া যায়নি — নিচের দ্রুত ভয়েস বাটন বা টাইপ ব্যবহার করুন'
            : 'Microphone unavailable on this device — tap quick voice phrases or type below',
      );
      return false;
    }

    try {
      state = state.copyWith(
        isListening: true,
        recognizedWords: '',
        soundLevel: 0.3,
        clearStatus: true,
      );
      await _stt.listen(
        listenOptions: SpeechListenOptions(
          localeId: locale.sttLocaleId,
          listenFor: const Duration(seconds: 25),
          pauseFor: const Duration(seconds: 4),
        ),
        onSoundLevelChange: (level) {
          if (mounted) {
            final normalized = ((level + 2) / 12).clamp(0.1, 1.0);
            state = state.copyWith(soundLevel: normalized);
          }
        },
        onResult: (result) {
          if (!mounted) return;
          state = state.copyWith(recognizedWords: result.recognizedWords);
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult) {
            state = state.copyWith(isListening: false, soundLevel: 0.0);
          }
        },
      );
      return true;
    } catch (e) {
      debugPrint('SHUCHONA STT listen error: $e');
      state = state.copyWith(isListening: false, soundLevel: 0.0);
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
    if (mounted) {
      state = state.copyWith(isListening: false, soundLevel: 0.0);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }
}

final voiceControllerProvider =
    StateNotifierProvider<VoiceController, VoiceState>((ref) {
  return VoiceController();
});
