import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'components/filter_sidebar.dart';
import 'components/record_list_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService(baseUrl: 'http://127.0.0.1:8000');
  List<String> _categories = [];
  List<String> _months = [];
  List<String> _records = [];
  String _clientversions = '';
  String _backendversions = '';
  String _selectedCategory = '朋友圈';
  String _selectedMonth = '';
  String _selectedName = '';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _loadFilteredRecords();
      setState(() {
        _selectedMonth = '月';
      });
      _loadFilteredRecords();
      setState(() {
      _selectedName = '【';
      });
      _loadFilteredRecords();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loadFilteredRecords() async {
    try {
      final response = await _apiService.fetchCategories(
        category: _selectedCategory.isNotEmpty ? _selectedCategory : "",
        month: _selectedMonth.isNotEmpty ? _selectedMonth : "",
        name: _selectedName.isNotEmpty ? _selectedName : "",
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

  Future<void> _searchFiltered() async {
    try {
      final response = await _apiService.searchCategories(
        name: _search.isNotEmpty ? _search : "",
      );

      final data = response;

      if (data.containsKey('names')) {
        final List<String> categories = List<String>.from(data['names']);
        setState(() {
          _categories = categories;
        });
      }

    } catch (e) {
      print('Error: $e');
    }
  }

   Future<void> _getversion() async {
    try {
      final infoData = await _apiService.fetchInfo();
      final String clientversions = infoData['client_versions'];
      final String backendversions = infoData['backend_versions'];
      setState(() {
        _clientversions = clientversions;
        _backendversions = backendversions;
      });
      _showDialog(
        title: '关于',
        message: '当前版本：$_clientversions\n当前后端版本：$_backendversions',
      );
    } catch (e) {
      _showDialog(
        title: '软件版本',
        message: '检查失败，请检查网络连接',
      );
    }
  }

  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _showDialog(
                title: '更新提示',
                message: '这是一个更新提示消息。',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _getversion();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          FilterSidebar(
            months: _months,
            categories: _categories,
            selectedMonth: _selectedMonth,
            selectedCategory: _selectedCategory,
            selectedName: _selectedName,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _selectedMonth = "";
                _selectedName = '';
              });
              _loadFilteredRecords();
            },
            onMonthChanged: (month) {
              setState(() {
                _selectedMonth = month;
                _selectedName = '';
              });
              _loadFilteredRecords();
            },
            onNameChanged: (name) {
              setState(() {
                _selectedName = name;
              });
              _loadFilteredRecords();
            },
            onSearchChanged: (name) {
              setState(() {
                _search = name;
              });
              _searchFiltered();
            },
          ),
          Expanded(
            child: RecordListView(
              records: _records,
            ),
          ),
        ],
      ),
    );
  }
}
