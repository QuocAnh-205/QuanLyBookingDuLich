import 'package:flutter/material.dart';

class DetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CEA6),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onRetry,
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
