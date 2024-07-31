import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _addCategory(String name) async {
    await _dbHelper.insertCategory(name);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('果之都智库'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Update data from API
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            child: Column(
              children: [
                ElevatedButton(onPressed: () {}, child: Text('话术')),
                ElevatedButton(onPressed: () {}, child: Text('朋友圈')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '搜索',
                    ),
                  ),
                ),
                Wrap(
                  children: List.generate(12, (index) {
                    return ElevatedButton(
                      onPressed: () {},
                      child: Text('${index + 1}月'),
                    );
                  }),
                ),
                Expanded(
                  child: ListView(
                    children: _categories.map((category) {
                      return ElevatedButton(
                        onPressed: () {},
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(10, (index) {
                return ListTile(
                  title: Text('Record $index'),
                  onTap: () {
                    // Copy content to clipboard
                  },
                  trailing: Text('😊'), // Emoji example
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
