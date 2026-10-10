import 'package:flutter/material.dart';

class WorkChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const WorkChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
      ),
      label: Text(label),
    );
  }
}