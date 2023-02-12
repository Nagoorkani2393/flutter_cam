import 'dart:io';

import 'package:flutter/material.dart';

class ListPreviewTile extends StatelessWidget {
  const ListPreviewTile({
    Key? key,
    required this.file,
    required this.onRemoveTap,
  }) : super(key: key);

  final File file;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5)),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          file,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
