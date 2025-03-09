import 'package:flutter/material.dart';
import 'weather.dart'; // Import your Calculator screen

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TODO',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: WeatherApp(), // Set BMICalculatorScreen as the home screen
  ));
}
