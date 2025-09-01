import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

import 'Notification/Local_Notification.dart';
import 'Screens/Profile_screen.dart';
import 'Screens/Search_screen.dart'; // Added for translation

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedText = '';
  String _translatedText = '';
  String ScreenName = 'Speech and Recognition';
  String _selectedLanguage = 'en';
  String _shortcut = 'No shortcut selected';
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    final QuickActions quickActions = const QuickActions();
    quickActions.initialize((String ShortCutType) {
      setState(() {
        _shortcut = ShortCutType;
      });
      if (_shortcut == 'action_search') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchScreen()),
        );
      } else if (_shortcut == 'action_profile') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_search',
        localizedTitle: 'Search Screen',
        icon: 'search',
      ),
      const ShortcutItem(
        type: 'action_profile',
        localizedTitle: 'Profile Screen',
        icon: 'profile',
      ),
    ]);
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (status) => log("STATUS: $status"),
      onError: (error) => log("ERROR: $error"),
    );
    // if (!mounted) return;
    setState(() {
      _speechAvailable = available;
    });
    log("Speech available: $available");
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      log("Speech recognition not available");
      return;
    }
    await _speech.listen(
      onResult: (result) async {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        if (_recognizedText.isNotEmpty) {
          try {
            final translation = await _translator.translate(
              _recognizedText,
              from: 'auto',
              to: _selectedLanguage,
            );
            setState(() {
              _translatedText = translation.text;
            });
          } catch (e) {
            log("Translation error: $e");
            setState(() {
              _translatedText = _recognizedText;
            });
          }
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _translatedText = '';
    });
  }

  sendLocalNotification() async {
    await LocalNotification.showInstantNotification(
      title: "Instant Message",
      body: "samplee test case",
    );
  }

  sendScheduledNotification() async {
    try {
      await LocalNotification.scheduleNotification(
        "Scheduled Notification",
        "This is the sheduled message",
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          15,
          38,
        ),
        1,
      );
      log("oooooooooooooooooo");
    } catch (e) {
      log("enterr");
      log(e.toString());
    }
  }

  sendRecurringNotification() async {
    await LocalNotification.scheduleRepeatingNotification(
      "Recurring Notification",
      "Sucesss",
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        15,
        38,
      ),
      DateTimeComponents.time,
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${ScreenName}', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 22),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
                DropdownMenuItem(value: 'ta', child: Text('Tamil')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  // Re-translate current text if any
                  if (_recognizedText.isNotEmpty) {
                    try {
                      final translation = await _translator.translate(
                        _recognizedText,
                        from: 'auto',
                        to: _selectedLanguage,
                      );
                      setState(() {
                        _translatedText = translation.text;
                      });
                    } catch (e) {
                      log("Translation error: $e");
                      setState(() {
                        _translatedText = _recognizedText;
                      });
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 22),
            Container(
              height: 233,
              width: 269,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  _translatedText.isEmpty ? _recognizedText : _translatedText,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: sendRecurringNotification,
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 45),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: _translatedText.isEmpty
                            ? _recognizedText
                            : _translatedText,
                      ),
                    );
                  },
                  child: const Text(
                    "Copy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 46),
            IconButton(
              onPressed: () async {
                if (_isListening) {
                  await _stopListening();
                } else {
                  await _startListening();
                }
              },
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 64),
              color: _isListening ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
