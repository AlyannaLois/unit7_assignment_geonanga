import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  Future<List<dynamic>> fetchHPStudentData() async {
    final response = await http.get(Uri.parse('https://hp-api.onrender.com/api/characters/students'));
    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to load student character data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Harry Potter Students"),
      ),
      body: 
      FutureBuilder<List<dynamic>>(
        future: fetchHPStudentData(), 
        builder: (context, snapshot) {
          if 
          (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } 
          else {
          
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var character = snapshot.data![index];
                var controller = ExpandedTileController();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ExpandedTile(
                    controller: controller,  
                   title: Text(
                      character['name'] ?? 'Name Unknown', 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    leading: character['image'] != null
                        ? Image.network(character['image'], width: 80, height: 80) 
                        : const Icon(Icons.account_circle, size: 30),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (character['alternate_names'] != null && character['alternate_names'].isNotEmpty)
                            Text('Alternate Names: ${character['alternate_names']?.join(', ')}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          if (character['species'] != null) Text('Species: ${character['species']}'), 
                          if (character['gender'] != null) Text('Gender: ${character['gender']}'), 
                          if (character['house'] != null) Text('House: ${character['house']}'), 
                          if (character['dateOfBirth'] != null) Text('Date of Birth: ${character['dateOfBirth']}'), 
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
