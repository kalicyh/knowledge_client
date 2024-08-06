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
  List<Map<String, dynamic>> _records = [];
  String _selectedMonth = '月';
  String _category = '';

  @override
  void initState() {
    super.initState();
  }

// 筛选语料数据
  Future<void> _loadFilteredRecords(String filterValue1, String filterValue2) async {
    // final filteredRecords = await _dbHelper.getFilteredRecords(
    //   filterValue1: filterValue1,
    //   filterValue2: filterValue2,
    // );
    setState(() {
      // _records = filteredRecords;
    });
  }
// 获取分类数据
  Future<void> _updateData() async {
    try {
      final infoData = await _apiService.fetchInfo();
      final List<String> categories = List<String>.from(infoData['name_categories']);

      // Clear existing categories and insert new ones
      // await _dbHelper.deleteAllCategories(); // Clear all categories
      // for (var category in categories) {
      //   await _dbHelper.insertCategory(category);
      // }

      // Update categories list and show success dialog
      setState(() {
        _categories = categories;
      });
      _showUpdateDialog(message: '数据已更新');
    } catch (e) {
      _showUpdateDialog(message: '更新失败，请检查网络连接');
    }
  }
// 获取语料数据
  Future<void> _updateRecords() async {
    try {
      final data = await _apiService.fetchData();
      final List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(data['records']);

      setState(() {
        _records = records;
      });
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
                  spacing: 8.0, // 按钮之间的水平间距
                  runSpacing: 4.0, // 按钮之间的垂直间距
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = "";
                        });
                        _loadFilteredRecords(_selectedMonth, _category);
                      },
                      child: Text('全部'),
                    ),
                    ...List.generate(12, (index) {
                      final month = '${index + 1}月';
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedMonth = month; // 更新所选的月份
                          });
                          _loadFilteredRecords(month, _category);
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
                            _category = ''; // 清空类别以显示所有记录
                          });
                          _loadFilteredRecords(_selectedMonth, _category);
                        },
                        child: Text('全部'),
                      ),
                      ..._categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0), // 添加垂直间距
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _category = category;
                              });
                              _loadFilteredRecords(_selectedMonth, category);
                            },
                            child: Text(category),
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
                final record = _records[index]; // 获取记录
                final description = record['文案'] ?? 'no description'; // 访问记录中的字段，假设字段名为 'name'

                return ListTile(
                  title: Text(description), // 显示记录的名称
                  onTap: () {
                    // 将内容复制到剪贴板
                    Clipboard.setData(ClipboardData(text: description));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('成功复制到剪贴板: $description'),
                        duration: Duration(milliseconds: 280),
                      ),
                    );
                  },
                  // trailing: Text('😊'),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
