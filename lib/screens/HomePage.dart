import "dart:convert";
import "dart:math";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";
import "package:meteo/config.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String weather = "Loading...";
  String temperature = "Loading...";
  String windSpeed = "Loading...";
  String minTemperature = "Loading...";
  String maxTemperature = "Loading...";
  String city = "Lyon";
  String icon = "";

  @override
  void initState() {
    super.initState();
    _getWeather();
    getData();
  }

// Récupération data user
  getData() async {}

// Récupération méteo par API
  Future<void> _getWeather() async {
    var url = Uri.https(
        url_api, url_data_weather, {'q': 'city', 'appid': appid, 'lang': 'fr'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var TempUrl = Uri.https(url_api, url_data_forecast,
          {'q': 'city', 'appid': appid, 'lang': 'fr'});
      var minMaxTempResponse = await http.get(TempUrl);
      if (minMaxTempResponse.statusCode == 200) {
        var minMaxTempData = jsonDecode(minMaxTempResponse.body);
        var list = minMaxTempData['list'];
        var minTemp = double.infinity;
        var maxTemp = double.negativeInfinity;
        for (var item in list) {
          var tempMin = item['main']['temp_min'];
          var tempMax = item['main']['temp_max'];
          minTemp = min(tempMin, minTemp);
          maxTemp = max(tempMax, maxTemp);
        }
        setState(() {
          weather = data['weather'][0]['description'];
          temperature = (data['main']['temp'] - 273.15).toStringAsFixed(0);
          windSpeed =
              (data['wind']['speed'] * 3.6).toStringAsFixed(0) + " km/h";
          minTemperature = (minTemp - 273.15).toStringAsFixed(1) + "°C";
          maxTemperature = (maxTemp - 273.15).toStringAsFixed(1) + "°C";
          icon = data['weather'][0]['icon'];
        });
      } else {
        setState(() {
          print("error statuscode : ${response.statusCode}");
          weather = "Failed to get weather";
        });
      }
    }
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("$city")],
        ),
      ),
    );
  }
}
