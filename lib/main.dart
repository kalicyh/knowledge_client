import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_service.dart'; // 导入 ApiService

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '果之都智库',
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
  final ApiService _apiService = ApiService(baseUrl: 'https://zk.jiuyue1688.vip');
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

  Future<void> _updateData() async {
    try {
      final infoData = await _apiService.fetchInfo();
      final List<String> categories = List<String>.from(infoData['name_categories']);

      // Clear existing categories and insert new ones
      await _dbHelper.deleteAllCategories(); // Clear all categories
      for (var category in categories) {
        await _dbHelper.insertCategory(category);
      }

      // Update categories list and show success dialog
      setState(() {
        _categories = categories;
      });
      _showUpdateDialog(message: '数据已更新');
    } catch (e) {
      _showUpdateDialog(message: '更新失败，请检查网络连接');
    }
  }

  Future<void> _updateRecords() async {
    try {
      final data = await _apiService.fetchData();
      final List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(data['records']);

      // Clear existing records and insert new ones
      await _dbHelper.deleteAllRecords(); // Clear all records
      for (var record in records) {
        await _dbHelper.insertRecord(
          record['序号'],
          record['名字'],
          record['分类'],
          record['文案']
        );
      }

      _showUpdateDialog(message: '记录已更新');
    } catch (e) {
      _showUpdateDialog(message: '更新记录失败，请检查网络连接');
    }
  }

  void _showUpdateDialog({required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('更新提示'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
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
              _updateData();
              _updateRecords();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: () {}, child: Text('话术')),
                    ElevatedButton(onPressed: () {}, child: Text('朋友圈')),
                  ],
                ),
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
