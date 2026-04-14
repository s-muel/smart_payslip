import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: App Name
          const Text(
            'BAJ Payslip Distribution System',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // RIGHT: User + Settings
          Row(
            children: [
              const Text(
                'Admin',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Open settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
