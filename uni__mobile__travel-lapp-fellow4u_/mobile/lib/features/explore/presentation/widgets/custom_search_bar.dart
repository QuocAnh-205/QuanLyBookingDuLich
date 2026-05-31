import 'package:flutter/material.dart';
import '../../../search/presentation/screens/search_screen.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly 
        ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()))
        : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AbsorbPointer(
          absorbing: readOnly,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            readOnly: readOnly,
            decoration: const InputDecoration(
              hintText: 'Hi, where do you want to explore?',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }
}
