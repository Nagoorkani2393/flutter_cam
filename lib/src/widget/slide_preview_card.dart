import 'dart:io';

import 'package:flutter/material.dart';

import '../enum/file_category.dart';

class SlidePreviewCard extends StatelessWidget {
  const SlidePreviewCard(
      {Key? key,
      required this.file,
      required this.onRemoveTap,
      required this.fileType,
      required this.thumbnail,
      required this.onTap})
      : super(key: key);

  final VoidCallback onRemoveTap;
  final File file;
  final VoidCallback onTap;
  final FileCategory fileType;
  final File thumbnail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: file.path,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(thumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: (fileType == FileCategory.video)
                ? Stack(
                    children: [
                      Center(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 38.0,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.black.withOpacity(0.7)),
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                          ),
                          onPressed: onRemoveTap,
                          child: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Colors.black.withOpacity(0.7)),
                        shape: MaterialStateProperty.all(const CircleBorder()),
                      ),
                      onPressed: onRemoveTap,
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
