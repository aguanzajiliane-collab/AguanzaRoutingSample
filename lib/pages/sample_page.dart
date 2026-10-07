import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiItem {
  final int id;
  final String title;
  final String body;

  const ApiItem({required this.id, required this.title, required this.body});

  factory ApiItem.fromJson(Map<String, dynamic> json) {
    return ApiItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled item',
      body: json['body'] as String? ?? '',
    );
  }
}

class SamplePage extends StatefulWidget {
  const SamplePage({super.key, this.httpClient});

  final http.Client? httpClient;

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  late final http.Client _client = widget.httpClient ?? http.Client();
  late final Future<List<ApiItem>> _itemsFuture;
  List<ApiItem> _items = [];

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();
  }

  Future<List<ApiItem>> _fetchItems() async {
    final response = await _client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load items.');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((item) => ApiItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  void _deleteItem(int id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Page'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ApiItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Something went wrong: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? _items;
          _items = items;

          if (_items.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.body,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _deleteItem(item.id),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (widget.httpClient == null) {
      _client.close();
    }
    super.dispose();
  }
}
