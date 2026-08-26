import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final lastModified = file.existsSync() ? file.lastModifiedSync() : DateTime.now();
    
    final dateFormatted = DateFormat('dd MMMM, yyyy').format(lastModified);
    final timeFormatted = DateFormat('hh:mm a').format(lastModified);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormatted, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(timeFormatted, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Image.file(file, fit: BoxFit.contain),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {
                Share.shareXFiles([XFile(imagePath)], text: 'Captured with Meco GPS Camera');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Photo'),
                      content: const Text('Are you sure you want to delete this photo?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  if (file.existsSync()) {
                    file.deleteSync();
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo deleted')),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
