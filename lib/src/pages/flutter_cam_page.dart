import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cam/src/pages/preview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;

import '../enum/cam_mode.dart';
import '../enum/file_category.dart';
import '../enum/slide_direction.dart';
import '../enum/video_mode.dart';
import '../repo/cam_controller.dart';
import '../widget/widgets.dart';

class FlutterCam extends StatefulWidget {
  const FlutterCam({
    super.key,
    required this.title,
    required this.cameraDescriptions,
    required this.onUploadTap,
    required this.onBackTap,
  });

  final List<CameraDescription> cameraDescriptions;
  final String title;
  final void Function(List<File> files, List<File> previews) onUploadTap;
  final VoidCallback onBackTap;

  @override
  State<FlutterCam> createState() => _FlutterCamState();
}

class _FlutterCamState extends State<FlutterCam> with TickerProviderStateMixin {
  static const String _introKey = "introductory_overlay";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  double? deviceWidth;
  double? deviceHeight;
  double? topPadding;
  late final ValueNotifier<CameraDescription> camNotifier;
  late final StreamController<VideoMode> _videoModeNotifier;
  late final ValueNotifier<List<File>> fileListNotifier;
  late final ValueNotifier<CamMode> _camModeNotifier;
  final ValueNotifier<bool> _isVideoRecorded = ValueNotifier(false);
  final ValueNotifier<bool> _splashNotifier = ValueNotifier(false);
  static const Duration _splashDuration = Duration(milliseconds: 100);
  static const Duration _animSwitchDuration = Duration(milliseconds: 250);
  final double _headerHeight = 70;
  final FilePicker _filePicker = FilePicker.platform;
  static const String _helperText = "Tap to image | Tap and hold to video";
  late final ScrollController _scrollController;
  final List<File> _files = [];
  late final AnimationController _slideAnimController;
  bool _isPreviewOpened = false;
  SlideDirection _slideDirection = SlideDirection.none;

  int? _previewedIndex;
  int curIndex = 0;
  @override
  void initState() {
    camNotifier = ValueNotifier(widget.cameraDescriptions[curIndex]);
    _camModeNotifier = ValueNotifier(CamMode.image);
    _videoModeNotifier = StreamController.broadcast();
    fileListNotifier = ValueNotifier([]);
    _scrollController = ScrollController();
    _slideAnimController = AnimationController(
      vsync: this,
      duration: _animSwitchDuration,
      reverseDuration: _animSwitchDuration,
    );
    _slideAnimController.value = _slideAnimController.upperBound;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _prefs.then((prefs) {
        if (prefs.getBool(_introKey) == true) {
          return;
        } else {
          IntroductoryOverlay.showIntroductoryOverlay(context);
          _prefs.then((prefs) {
            prefs.setBool(_introKey, true);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    camNotifier.dispose();
    _camModeNotifier.dispose();
    _splashNotifier.dispose();
    _slideAnimController.dispose();
    fileListNotifier.dispose();
    _isVideoRecorded.dispose();
    _scrollController.dispose();
    _videoModeNotifier.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    topPadding = MediaQuery.of(context).viewPadding.top;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double dx = 0;
    final Size previewSize =
        Size((deviceHeight! * 0.75), (deviceWidth! / 0.75));
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (_isPreviewOpened) {
            _isPreviewOpened = false;
            _slideAnimController.forward();
          }
        },
        onHorizontalDragStart: (details) {
          if (_camModeNotifier.value == CamMode.image ||
              _isVideoRecorded.value == false) {
            dx = details.globalPosition.dx;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_camModeNotifier.value == CamMode.image ||
              _isVideoRecorded.value == false) {
            final double diff = details.primaryDelta! / deviceWidth!;
            _slideAnimController.value += (2 * diff);
            if (dx > details.globalPosition.dx) {
              _slideDirection = SlideDirection.left;
              _scrollToEnd();
            } else if (dx < details.globalPosition.dx) {
              _slideDirection = SlideDirection.right;
            }
          }
        },
        onHorizontalDragEnd: (details) {
          if (_camModeNotifier.value == CamMode.image ||
              _isVideoRecorded.value == false) {
            if (_slideDirection == SlideDirection.left) {
              _isPreviewOpened = true;
              _slideAnimController.reverse();
            } else if (_slideDirection == SlideDirection.right) {
              _isPreviewOpened = false;
              _slideAnimController.forward();
            }
            _slideDirection = SlideDirection.none;
          }
        },
        child: Container(
          width: deviceWidth,
          height: deviceHeight,
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  child: SizedOverflowBox(
                    size: previewSize,
                    alignment: Alignment.center,
                    child: ValueListenableBuilder<CameraDescription>(
                      valueListenable: camNotifier,
                      builder:
                          (BuildContext context, description, Widget? child) {
                        CamController.i.initCam(description);
                        final camController = CamController.i.controller;
                        return CameraBase(
                          cameraController: camController,
                          previewSize: previewSize,
                        );
                      },
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _splashNotifier,
                builder: (context, value, child) {
                  if (value) {
                    return Container(
                      color: Colors.black,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isVideoRecorded,
                builder: (context, isVideoRecorded, child) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _headerHeight,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: AnimatedSwitcher(
                        duration: _animSwitchDuration,
                        child: isVideoRecorded
                            ? Center(
                                child: VideoDurationTile(
                                videoPlayPause: _videoModeNotifier,
                                durationNotifier: ValueNotifier(Duration.zero),
                              ))
                            : CamHeader(
                                onCamSwitch: _toggle,
                                title: widget.title,
                                onBackTap: widget.onBackTap,
                                camModeNotifier: _camModeNotifier,
                              ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                // height: _footerHeight,
                child: AnimatedContainer(
                  duration: _animSwitchDuration,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _isVideoRecorded,
                              builder: (context, value, child) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: value
                                      ? _VideoPlayPauseButton(
                                          onTap: _videoPlayPause)
                                      : _ImagePickerButton(
                                          onTap: _pickFileFromGallery),
                                );
                              }),
                          CamButton(
                            onTap: _camButtonTap,
                            camModeNotifier: _camModeNotifier,
                            isVideoRecording: _isVideoRecorded,
                          ),
                          Material(
                            type: MaterialType.transparency,
                            shape: const CircleBorder(),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              splashFactory: InkRipple.splashFactory,
                              highlightColor: Colors.white,
                              onTap: () {
                                if (_camModeNotifier.value == CamMode.image ||
                                    _isVideoRecorded.value == false) {
                                  if (fileListNotifier.value.isEmpty) {
                                    return;
                                  }
                                  _isPreviewOpened = true;
                                  _slideAnimController.reverse();
                                  _scrollToEnd();
                                }
                              },
                              child: ValueListenableBuilder<List<File>>(
                                valueListenable: fileListNotifier,
                                builder: (context, file, child) {
                                  return AnimatedSwitcher(
                                    duration: _animSwitchDuration,
                                    child: file.isEmpty
                                        ? Container(
                                            key: UniqueKey(),
                                            width: 34,
                                            height: 34,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          )
                                        : Container(
                                            key: UniqueKey(),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: FileImage(file.last),
                                                  fit: BoxFit.cover),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                                child: Text(
                                                  fileListNotifier.value.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<List<File>>(
                        valueListenable: fileListNotifier,
                        builder: (context, file, child) {
                          return AnimatedSwitcher(
                            duration: _animSwitchDuration,
                            child: fileListNotifier.value.isNotEmpty
                                ? UploadButton(
                                    onTap: () {
                                      if (_camModeNotifier.value ==
                                              CamMode.image ||
                                          _isVideoRecorded.value == false) {
                                        widget.onUploadTap.call(
                                            _files, fileListNotifier.value);
                                      }
                                    },
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 38.0,
                                      child: Center(
                                        child: Text(
                                          _helperText,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _slideAnimController,
                builder: (context, child) {
                  return AnimatedPositioned(
                    duration: _animSwitchDuration,
                    right: -(200 * _slideAnimController.value),
                    width: 200,
                    height: (deviceHeight! - topPadding!),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: ValueListenableBuilder<List<File>>(
                        valueListenable: fileListNotifier,
                        builder: (context, value, child) {
                          if (value.isEmpty) {
                            return const Center(
                              child: Text(
                                "No files",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return ScrollConfiguration(
                            behavior: const ScrollBehavior(),
                            child: GlowingOverscrollIndicator(
                              color: Colors.black,
                              axisDirection: AxisDirection.down,
                              child: GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.56,
                                ),
                                controller: _scrollController,
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: value.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: SlidePreviewCard(
                                      fileType: getFileCategory(_files[index]),
                                      file: _files[index],
                                      thumbnail: value[index],
                                      onRemoveTap: () => _onRemoveTap(index),
                                      onTap: () async {
                                        _previewedIndex = index;
                                        await Navigator.of(context)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (context) => PreviewPage(
                                              file: _files[index],
                                              thumbnail: value[index],
                                              onDeleteTap: () => _onRemoveTap(
                                                  _previewedIndex!),
                                              onSaveTap: (file) {
                                                _updateNewFile(
                                                    file, _previewedIndex!);
                                              },
                                            ),
                                          ),
                                        )
                                            .then((_) {
                                          _previewedIndex = null;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggle() {
    if (curIndex == 0) {
      curIndex = 1;
    } else {
      curIndex = 0;
    }
    camNotifier.value = widget.cameraDescriptions[curIndex];
  }

  void _popThePreview() {
    if (_isPreviewOpened) {
      _slideAnimController.reverse();
    }
  }

  Future<void> _camButtonTap() async {
    _popThePreview();
    _splashNotifier.value = true;
    Future.delayed(_splashDuration, () {
      _splashNotifier.value = false;
    });
    if (_camModeNotifier.value == CamMode.image) {
      await CamController.i.controller.takePicture().then(
        (value) {
          _files.add(File(value.path));
          fileListNotifier.value.add(File(value.path));
          fileListNotifier.value = [...fileListNotifier.value];
        },
      );
    } else {
      if (_isVideoRecorded.value == true) {
        await _onVideoStop();
      } else {
        await _onVideoStart();
      }
    }
  }

  Future<void> _onVideoStart() async {
    _popThePreview();
    _isVideoRecorded.value = true;
    await CamController.i.controller.startVideoRecording();
  }

  Future<String?> _getThumbnail(String path) async {
    return await video_thumbnail.VideoThumbnail.thumbnailFile(
        video: path,
        imageFormat: video_thumbnail.ImageFormat.JPEG,
        quality: 25);
  }

  Future<void> _onVideoStop() async {
    _isVideoRecorded.value = false;
    await CamController.i.controller.stopVideoRecording().then(
      (value) async {
        _files.add(File(value.path));
        final thumbnail = await _getThumbnail(value.path);
        fileListNotifier.value.add(File(thumbnail!));
        fileListNotifier.value = [...fileListNotifier.value];
        _videoModeNotifier.add(VideoMode.pause);
      },
    );
  }

  Future<void> _pickFileFromGallery() async {
    if (_camModeNotifier.value == CamMode.image ||
        _isVideoRecorded.value == false) {
      _popThePreview();
      final FilePickerResult? filePickerResult = await _filePicker.pickFiles(
          type: FileType.custom,
          allowMultiple: true,
          allowedExtensions: ['jpg', 'mp4']);
      final List<PlatformFile>? images = filePickerResult?.files;

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          _files.add(File(images[i].path!));
          if (images[i].extension == 'mp4') {
            final thumbnail = await _getThumbnail(images[i].path!);
            fileListNotifier.value.add(File(thumbnail!));
            fileListNotifier.value = [...fileListNotifier.value];
          } else {
            fileListNotifier.value.add(File(images[i].path!));
            fileListNotifier.value = [...fileListNotifier.value];
          }
        }
      }
    }
  }

  void _onRemoveTap(int index) {
    _files.removeAt(index);
    fileListNotifier.value.removeAt(index);
    fileListNotifier.value = [...fileListNotifier.value];
  }

  void _updateNewFile(File file, int index) {
    _files[index] = file;
    fileListNotifier.value[index] = file;
    fileListNotifier.value = [...fileListNotifier.value];
  }

  Future<void> _scrollToEnd() async {
    if (fileListNotifier.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
        );
      });
    }
  }

  Future<void> _videoPlayPause(VideoMode mode) async {
    if (mode == VideoMode.play) {
      await CamController.i.controller.resumeVideoRecording();
    } else {
      await CamController.i.controller.pauseVideoRecording();
    }
    _videoModeNotifier.add(mode);
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.white,
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _VideoPlayPauseButton extends StatefulWidget {
  const _VideoPlayPauseButton({required this.onTap});
  final Function(VideoMode videoMode) onTap;

  @override
  State<_VideoPlayPauseButton> createState() => _VideoPlayPauseButtonState();
}

class _VideoPlayPauseButtonState extends State<_VideoPlayPauseButton> {
  VideoMode _mode = VideoMode.play;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.white,
        onTap: () {
          if (_mode == VideoMode.play) {
            _mode = VideoMode.pause;
          } else {
            _mode = VideoMode.play;
          }
          widget.onTap.call(_mode);
          setState(() {});
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: _mode == VideoMode.play
              ? const Icon(
                  Icons.pause,
                  color: Colors.white70,
                )
              : const Icon(
                  Icons.play_arrow,
                  color: Colors.white70,
                ),
        ),
      ),
    );
  }
}
