import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../enum/button_state.dart';
import '../enum/file_category.dart';
import '../widget/edit_btn.dart';
import '../widget/video_player_widget.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({
    Key? key,
    required this.file,
    this.onDeleteTap,
    this.onSaveTap,
    required this.thumbnail,
  }) : super(key: key);

  final File file;
  final void Function()? onDeleteTap;
  final void Function(File file)? onSaveTap;
  final File thumbnail;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late final ValueNotifier<File> _fileNotifier;

  late final FileCategory _fileCategory;

  @override
  void initState() {
    super.initState();
    _fileCategory = getFileCategory(widget.file);
    _fileNotifier = ValueNotifier<File>(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                width: 300,
                height: (300 * 16) / 9,
                child: Hero(
                  tag: widget.file.path,
                  child: ValueListenableBuilder<File>(
                      valueListenable: _fileNotifier,
                      builder: (context, image, child) {
                        return _fileCategory == FileCategory.image
                            ? Image.file(
                                image,
                                fit: BoxFit.contain,
                              )
                            : VideoPlayerWidget(
                                file: widget.file,
                                thumbnail: widget.thumbnail,
                              );
                      }),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EditButton(
                          btnText: "Crop",
                          icon: Icons.crop,
                          btnState: _fileCategory == FileCategory.image
                              ? ButtonState.enabled
                              : ButtonState.disabled,
                          onPressed: () async {
                            if (_fileCategory == FileCategory.image) {
                              final file =
                                  await _cropImage(_fileNotifier.value.path);
                              if (file != null) {
                                _fileNotifier.value = File(file.path);
                              }
                            }
                          },
                        ),
                        EditButton(
                          btnText: "Delete",
                          icon: Icons.delete_forever_rounded,
                          onPressed: () {
                            widget.onDeleteTap?.call();
                            Navigator.pop(context);
                          },
                        ),
                        EditButton(
                          btnText: "Save",
                          icon: Icons.done,
                          onPressed: () {
                            if (_fileCategory == FileCategory.image) {
                              widget.onSaveTap?.call(_fileNotifier.value);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.1)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<CroppedFile?> _cropImage(String path) {
    return ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            hideBottomControls: true,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop',
        ),
      ],
    ).then((value) => value);
  }
}
