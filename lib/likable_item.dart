import 'package:flutter/material.dart';
import 'package:layout_tutorial/db.dart';
import 'package:layout_tutorial/utils.dart';
import 'favorite_widget.dart'; // Assuming FavoriteWidget is in a separate file

class LikableItem extends StatelessWidget {
  final Success success;

  const LikableItem({
    super.key,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(success.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(success.subtitle,
                    style: TextStyle(color: Colors.grey[500])),
                Text('created: ${formatDateTime(success.created)}',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          const FavoriteWidget(),
        ],
      ),
    );
  }
}
