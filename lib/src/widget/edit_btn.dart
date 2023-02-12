import 'package:flutter/material.dart';

import '../enum/button_state.dart';

class EditButton extends StatelessWidget {
  const EditButton(
      {super.key,
      required this.btnText,
      required this.icon,
      this.onPressed,
      this.btnState = ButtonState.enabled});
  final String btnText;
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonState btnState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: btnState == ButtonState.enabled ? onPressed : null,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
            shape: MaterialStateProperty.all(const CircleBorder()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: btnState == ButtonState.enabled
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Text(
            btnText,
            style: TextStyle(
              color: btnState == ButtonState.enabled
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.2),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
