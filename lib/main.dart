import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String weatherApiKey = 'cf27ea64ee0e2e4a5940092ba96d23f7';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Selector App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApiSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value != '123') {
                    return 'Password must be "123"';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _attemptLogin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose API')),
      body: Center(
        child: ApiButtons(),
      ),
    );
  }
}

class ApiButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WeatherSearchScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Weather API',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatFactsScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Cat Facts API',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class CatFactsScreen extends StatefulWidget {
  @override
  _CatFactsScreenState createState() => _CatFactsScreenState();
}

class _CatFactsScreenState extends State<CatFactsScreen> {
  String? _catFact;
  bool _isLoading = false;

  Future<void> _fetchCatFact() async {
    setState(() {
      _isLoading = true;
      _catFact = null;
    });

    final url = Uri.parse('https://catfact.ninja/fact');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _catFact = data['fact'];
        });
      } else {
        setState(() {
          _catFact = 'Failed to load cat fact. Error code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _catFact = 'An error occurred: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cat Facts')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _fetchCatFact,
                child: Text('Get Random Cat Fact'),
              ),
              SizedBox(height: 20),
              if (_isLoading) CircularProgressIndicator(),
              if (_catFact != null)
                Center(
                  child: Text(
                    _catFact!,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherSearchScreen extends StatefulWidget {
  @override
  _WeatherSearchScreenState createState() => _WeatherSearchScreenState();
}

class _WeatherSearchScreenState extends State<WeatherSearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _weatherInfo;
  bool _isLoading = false;

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _weatherInfo = null;
    });

    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$weatherApiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final kelvinTemp = data['main']['temp'];
        final celsiusTemp = kelvinTemp - 273.15;

        setState(() {
          _weatherInfo = 'City: ${data['name']}\n'
              'Temperature: ${celsiusTemp.toStringAsFixed(1)}°C\n'
              'Weather: ${data['weather'][0]['description']}';
        });
      } else {
        setState(() {
          _weatherInfo = 'Failed to load weather data. Error code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'An error occurred: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Enter city name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  _fetchWeather(_cityController.text);
                }
              },
              child: Text('Get Weather'),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (_weatherInfo != null) Text(_weatherInfo!),
          ],
        ),
      ),
    );
  }
}
