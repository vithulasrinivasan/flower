import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String _weather = "Enter a city to get the weather";
  bool _isLoading = false;

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _weather = "Fetching weather...";
    });

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=211922dc4575ca7aa489da81548a4965&units=metric'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _weather = "${data['main']['temp']}°C | ${data['weather'][0]['description'].toUpperCase()}";
      });
    } else {
      setState(() {
        _weather = "City not found. Try again.";
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => fetchWeather(_cityController.text),
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                _weather,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
