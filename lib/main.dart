import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'features/home/home_screen.dart';

void main() => runApp(const DetechXApp());

class DetechXApp extends StatelessWidget {
  const DetechXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DetechX',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    home: const HomeScreen(),
    builder: (context, child) => ColoredBox(
      color: const Color(0xfff1e6df),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: child!,
        ),
      ),
    ),
  );
}
