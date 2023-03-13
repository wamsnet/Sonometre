import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

ThemeMode appTheme = ThemeMode.system; //dark / light

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'Sonomètre',
      home: const NoiseApp(),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
            ),
        primaryTextTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
            ),
        // ignore: deprecated_member_use
        accentTextTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.comfortaa().fontFamily,
            ),
      ),
      theme: ThemeData(
        fontFamily: GoogleFonts.comfortaa().fontFamily,
      ),
      themeMode: appTheme,
    );
  }
}
