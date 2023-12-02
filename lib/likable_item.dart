import 'package:flutter/material.dart';
import 'favorite_widget.dart'; // Assuming FavoriteWidget is in a separate file

class LikableItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const LikableItem({
    super.key,
    this.title = "title",
    this.subtitle = "subtitle",
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          const FavoriteWidget(),
        ],
      ),
    );
  }
}
