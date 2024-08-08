import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

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
  final ApiService _apiService = ApiService(baseUrl: 'https://zk.jiuyue1688.vip/talking_points');
  List<String> _categories = [];
  List<String> _months = [];
  List<String> _records = [];
  String _selectedMonth = '';
  String _selectedcategory = '';
  String _selectedname = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadFilteredRecords() async {
  try {
    final response = await _apiService.fetchCategories(
        category: _selectedcategory.isNotEmpty ? _selectedcategory : "",
        month: _selectedMonth.isNotEmpty ? _selectedMonth : "",
        name: _selectedname.isNotEmpty ? _selectedname : "",
    );

    final data = response;

    if (data.containsKey('months')) {
      final List<String> months = List<String>.from(data['months']);
      setState(() {
      _months = months;
    });
    }

    if (data.containsKey('names')) {
      final List<String> categories = List<String>.from(data['names']);
      setState(() {
      _categories = categories;
    });
    }

    if (data.containsKey('texts')) {
      final List<String> records = List<String>.from(data['texts']);
      setState(() {
      _records = records;
    });
    }
  } catch (e) {
    print('Error: $e');
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
                Navigator.of(context).pop();
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
                    ElevatedButton(onPressed: () {
                      setState(() {
                          _selectedcategory = "朋友圈";
                          _selectedMonth = "";
                          _selectedname = '';
                        });
                        _loadFilteredRecords();
                    }, child: Text('朋友圈')),
                    ElevatedButton(onPressed: () {
                      setState(() {
                          _selectedcategory = "话术";
                          _selectedMonth = "";
                          _selectedname = '';
                        });
                        _loadFilteredRecords();
                    }, child: Text('话术')),
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
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = "月";
                          // _selectedname = '';
                        });
                        _loadFilteredRecords();
                      },
                      child: Text('全部'),
                    ),
                    ...List.generate(_months.length, (index) {
                      final month = _months[index];
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedMonth = month;
                            // _selectedname = '';
                          });
                          _loadFilteredRecords();
                        },
                        child: Text(month),
                      );
                    }),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedname = '';
                          });
                          _loadFilteredRecords();
                        },
                        child: Text('全部'),
                      ),
                      ..._categories.map((name) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedname = name;
                              });
                              _loadFilteredRecords();
                            },
                            child: Text(name),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(_records.length, (index) {
                final record = _records[index];
                return ListTile(
                  title: Text(record),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: record));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('成功复制到剪贴板: $record'),
                        duration: Duration(milliseconds: 280),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
