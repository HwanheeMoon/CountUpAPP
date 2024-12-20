import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MaterialApp(home: MainPage()));
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int time = 3;
  int count = 10;
  bool startTimer = false;
  int bpm = 20;
  bool start = false;
  bool clicked = false;
  int exeCnt = 1;
  String ment = "시작";

  Timer? timer;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> playBeep(double frequency, double duration) async {
    // Flutter에는 Web AudioContext가 없으므로 TTS나 추가 패키지를 이용해 구현 가능
    // 현재는 비어있지만, 구현 가능성을 염두에 둠
  }

  Future<void> speech(String query) async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.speak(query);
  }

  String numberToKoreanNative(int num) {
    if (num < 1 || num > 999) return "지원하지 않는 숫자입니다.";

    const units = ["", "백", "십", ""];
    const nativeNumbers = [
      "",
      "하나",
      "둘",
      "셋",
      "넷",
      "다섯",
      "여섯",
      "일곱",
      "여덟",
      "아홉",
    ];
    const tenPrefixes = [
      "",
      "열",
      "스물",
      "서른",
      "마흔",
      "쉰",
      "예순",
      "일흔",
      "여든",
      "아흔",
    ];

    final digits = num.toString().padLeft(3, '0').split('').map(int.parse).toList();

    return digits.asMap().entries.map((entry) {
      int idx = entry.key;
      int digit = entry.value;

      if (digit == 0) return "";
      if (idx == 0) return nativeNumbers[digit] + units[idx];
      if (idx == 1) return tenPrefixes[digit];
      return nativeNumbers[digit];
    }).join().replaceAll("하나백", "백");
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (time > 0) {
          time--;
        } else {
          t.cancel();
          playBeep(1000, 0.4); // 비프음
          setState(() {
            startTimer = false;
            ment = "";
            start = true;
          });
        }
      });
    });
  }

  void startExercise() {
    timer = Timer.periodic(Duration(milliseconds: (60000 / bpm).toInt()), (Timer t) {
      setState(() {
        if (exeCnt >= count + 1) {
          t.cancel();
          start = false;
          clicked = false;
          ment = "시작";
        } else {
          exeCnt++;
          speech(numberToKoreanNative(exeCnt));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              "COUNT UP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            if (startTimer && time > 0)
              Text(
                "$time",
                style: const TextStyle(color: Colors.white, fontSize: 32),
              )
            else if (clicked)
              Text(
                ment,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            const SizedBox(height: 20),
            if (!clicked)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    time = 3;
                    startTimer = true;
                    clicked = true;
                    exeCnt = 1;
                  });
                  startCountdown();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(32),
                  backgroundColor: Colors.grey[700],
                ),
                child: const Text(
                  "시작하기",
                  style: TextStyle(color: Colors.white),
                ),
              )
            else if (start)
              Column(
                children: [
                  Text(
                    "$exeCnt",
                    style: const TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        clicked = false;
                        start = false;
                        startTimer = false;
                        ment = "시작";
                      });
                      timer?.cancel();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("정지", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              "분당 $bpm회 실시",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => bpm = bpm > 0 ? bpm - 1 : 0),
                  icon: const Icon(Icons.remove, color: Colors.white),
                ),
                Text(
                  "$bpm",
                  style: const TextStyle(color: Colors.white, fontSize: 32),
                ),
                IconButton(
                  onPressed: () => setState(() => bpm = bpm < 60 ? bpm + 1 : 60),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
