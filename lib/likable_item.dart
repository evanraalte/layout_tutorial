import 'package:flutter/material.dart';
import 'package:layout_tutorial/db.dart';

Future<void> showEditItemDialog(BuildContext context, Success item) async {
  String title = item.title; // Assuming the item has a title attribute
  // Other attributes as needed

  TextEditingController titleController = TextEditingController(text: title);
  bool isEdited = false;

  void checkForChanges() {
    if (titleController.text != item.title) {
      isEdited = true;
    } else {
      isEdited = false;
    }
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: titleController,
                onChanged: (value) {
                  checkForChanges();
                },
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(hintText: "Edit title"),
              ),
              // Other fields as needed
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              if (isEdited) {
                showConfirmCancelDialog(dialogContext);
              } else {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              Success updatedItem = Success(
                id: item.id,
                title: titleController.text,
                subtitle: item.subtitle, // todo: delete
                created: item.created, // Preserve the original creation date
                modified: DateTime.now(), // Update the modified date
                date: item
                    .date, // Preserve the original date or update as necessary
              );
              await SuccessDatabaseService().updateSuccess(updatedItem);
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              showConfirmDeleteDialog(dialogContext, item);
            },
          ),
        ],
      );
    },
  );
}

void showConfirmCancelDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Discard changes?'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'You have unsaved changes. Are you sure you want to cancel?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(dialogContext)
                  .pop(); // Close the confirmation dialog
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              Navigator.of(dialogContext)
                  .pop(); // Close the confirmation dialog
              Navigator.of(context).pop(); // Close the edit dialog
            },
          ),
        ],
      );
    },
  );
}

void showConfirmDeleteDialog(BuildContext context, Success item) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete item?'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to delete this item?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              // Implement delete logic
              await SuccessDatabaseService().deleteSuccess(item.id!);
              Navigator.of(dialogContext)
                  .pop(); // Close the confirmation dialog
              Navigator.of(context).pop(); // Close the edit dialog
            },
          ),
        ],
      );
    },
  );
}

class LikableItem extends StatelessWidget {
  final Success success;
  final Function refreshSuccessList;

  const LikableItem({
    super.key,
    required this.success,
    required this.refreshSuccessList,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await showEditItemDialog(context, success);
        refreshSuccessList();
      },
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.emoji_events, color: Colors.amber),
        title: Text(
          success.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Optionally, you can add onTap, leading, subtitle, etc. as needed
      ),
    );
  }
}
