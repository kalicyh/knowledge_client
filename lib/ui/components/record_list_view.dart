import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecordListView extends StatelessWidget {
  final List<String> records;

  RecordListView({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(records.length, (index) {
        final record = records[index];
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
    );
  }
}
