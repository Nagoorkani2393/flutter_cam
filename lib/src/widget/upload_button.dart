import 'package:flutter/material.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: 137.0,
          height: 38.0,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: const Center(
            child: Text(
              "UPLOAD",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// Container(
// padding: const EdgeInsets.all(6.0),
// width: 32.0,
// height: 32.0,
// decoration: BoxDecoration(
// image: DecorationImage(
// image: FileImage(file), fit: BoxFit.cover),
// shape: BoxShape.circle,
// color: Colors.white.withOpacity(0.3)),
// child: Container(
// decoration: const BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.blue,
// ),
// child: Center(
// child: Text(
// "$count",
// style: const TextStyle(color: Colors.white),
// ),
// ),
// ),
// )
//     .animate(delay: const Duration(milliseconds: 300))
//     .fade(duration: const Duration(milliseconds: 300)),
