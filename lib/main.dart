import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokeapi/pokecard_entity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PokemonCardBrowser(),
    );
  }
}

class PokemonCardBrowser extends StatefulWidget {
  @override
  _PokemonCardBrowserState createState() => _PokemonCardBrowserState();
}

class _PokemonCardBrowserState extends State<PokemonCardBrowser> {
  List<PokecardEntity> cards = [];
  List<PokecardEntity> filteredCards = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    final response = await http.get(Uri.parse('https://8000-idx-pokeapi-1734620675461.cluster-3g4scxt2njdd6uovkqyfcabgo6.cloudworkstations.dev/cards'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<PokecardEntity> fetchedCards = (data['cards'] as List)
          .map((card) => PokecardEntity.fromJson(card))
          .toList();
      
      // Sort cards by name
      fetchedCards.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      
      setState(() {
        cards = fetchedCards;
        filteredCards = fetchedCards;
      });
    }
  }

  void filterCards(String query) {
    setState(() {
      filteredCards = cards
          .where((card) =>
              card.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Card Browser'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Cards',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterCards,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];
                return Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          'https://8000-idx-pokeapi-1734620675461.cluster-3g4scxt2njdd6uovkqyfcabgo6.cloudworkstations.dev/cards/${card.id}/${card.setNum}.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Image not available')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('Set: ${card.set ?? 'Unknown'}'),
                            Text('Rarity: ${card.rarity ?? 'Unknown'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}