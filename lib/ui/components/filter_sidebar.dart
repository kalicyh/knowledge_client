import 'package:flutter/material.dart';

class FilterSidebar extends StatelessWidget {
  final List<String> months;
  final List<String> categories;
  final String selectedMonth;
  final String selectedCategory;
  final String selectedName;
  final Function(String) onCategoryChanged;
  final Function(String) onMonthChanged;
  final Function(String) onNameChanged;

  FilterSidebar({
    required this.months,
    required this.categories,
    required this.selectedMonth,
    required this.selectedCategory,
    required this.selectedName,
    required this.onCategoryChanged,
    required this.onMonthChanged,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: [
          //分类
          Wrap(
            spacing: 8.0, // 按钮之间的水平间隔
            runSpacing: 4.0, // 行间隔
            children: [
              ElevatedButton(
                onPressed: () {
                  onCategoryChanged("未分类");
                },
                child: Text('未分类'),
              ),
              ElevatedButton(
                onPressed: () {
                  onCategoryChanged("朋友圈");
                },
                child: Text('朋友圈'),
              ),
              ElevatedButton(
                onPressed: () {
                  onCategoryChanged("话术");
                },
                child: Text('话术'),
              ),
            ],
          ),
          //搜索
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '搜索',
              ),
              onChanged: (value) {
                onNameChanged(value);
              },
            ),
          ),
          //月份
          Wrap(
            runSpacing: 1.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  onMonthChanged("月");
                },
                child: Text('全部'),
              ),
              ...List.generate(months.length, (index) {
                final month = months[index];
                return ElevatedButton(
                  onPressed: () {
                    onMonthChanged(month);
                  },
                  child: Text(month),
                );
              }),
            ],
          ),
          //产品
          Expanded(
            child: ListView(
              children: categories.map((name) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      onNameChanged(name);
                    },
                    child: Text(name),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
