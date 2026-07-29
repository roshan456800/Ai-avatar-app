import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TalkingAvatarApp());
}

class TalkingAvatarApp extends StatelessWidget {
  const TalkingAvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Talking Avatar',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
