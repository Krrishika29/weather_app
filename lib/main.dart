import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  bool loading = false;
  String? error;
  String city = '';
  String country = '';
  Map<String, dynamic>? weather;

  String getDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2 || code == 3) return 'Cloudy';
    if (code == 61 || code == 63 || code == 65) return 'Rain';
    if (code == 71 || code == 73 || code == 75) return 'Snow';
    return 'Unknown';
  }

  String getIcon(int code) {
    if (code == 0) return '☀️';
    if (code == 1 || code == 2 || code == 3) return '☁️';
    if (code == 61 || code == 63 || code == 65) return '🌧️';
    if (code == 71 || code == 73 || code == 75) return '❄️';
    return '❓';
  }

  Future<void> search() async {
    final name = controller.text;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final geoRes = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$name&count=1'));
      final geo = jsonDecode(geoRes.body);
      final result = geo['results'][0];
      city = result['name'];
      country = result['country'];

      final lat = result['latitude'];
      final lon = result['longitude'];
      final res = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=5&timezone=auto'));
      weather = jsonDecode(res.body);
    } catch (e) {
      error = 'Something went wrong';
      weather = null;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'City'),
                  ),
                ),
                ElevatedButton(onPressed: search, child: const Text('Go')),
              ],
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (error != null) Text(error!),
            if (weather == null && !loading && error == null)
              const Text('Search for a city'),
            if (weather != null && !loading) Expanded(child: buildWeather()),
          ],
        ),
      ),
    );
  }

  Widget buildWeather() {
    final current = weather!['current'];
    final daily = weather!['daily'];
    final code = current['weather_code'];
    return ListView(
      children: [
        Text('$city, $country', style: const TextStyle(fontSize: 24)),
        Text('${getIcon(code)} ${current['temperature_2m']}°C',
            style: const TextStyle(fontSize: 32)),
        Text(getDescription(code)),
        Text('Humidity: ${current['relative_humidity_2m']}%'),
        Text('Wind: ${current['wind_speed_10m']} km/h'),
        const SizedBox(height: 20),
        const Text('Forecast', style: TextStyle(fontSize: 20)),
        for (int i = 0; i < 5; i++)
          ListTile(
            title: Text(daily['time'][i]),
            leading: Text(getIcon(daily['weather_code'][i]),
                style: const TextStyle(fontSize: 24)),
            trailing: Text(
                '${daily['temperature_2m_min'][i]} / ${daily['temperature_2m_max'][i]}'),
          ),
      ],
    );
  }
}
