import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define la clase ApiService para manejar la comunicación con la API REST
class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // Método para obtener datos desde un endpoint
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Método para enviar datos a un endpoint
  Future<void> sendData(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 201) { // 201 Created para POST
      throw Exception('Failed to send data');
    }
  }
}

// Define una clase para manejar los recursos como cadenas de texto, colores, y dimensiones
class Resources {
  final BuildContext _context;
  final ApiService apiService;

  Resources(this._context, this.apiService);

  Future<Map<String, dynamic>> fetchDataFromApi(String endpoint) {
    return apiService.fetchData(endpoint);
  }

  static Resources of(BuildContext context, ApiService apiService) {
    return Resources(context, apiService);
  }
}

// Define una pantalla de ejemplo que usa la API REST
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> _futureData;
  final ApiService _apiService = ApiService('https://jsonplaceholder.typicode.com/');

  @override
  void initState() {
    super.initState();
    _futureData = Resources.of(context, _apiService).fetchDataFromApi('posts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API REST Example'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data?['length'] ?? 0) == 0) {
            return Center(child: Text('No data available'));
          } else {
            List<dynamic> posts = snapshot.data!['posts'];
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title']),
                  subtitle: Text(post['body']),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
