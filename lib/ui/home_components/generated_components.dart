import 'package:flutter/material.dart';

class GeneratedButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GeneratedButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? CircularProgressIndicator()
    : ElevatedButton(
      onPressed: onPressed, 
      child: Text("Generate Schedule")
    );
  }
}