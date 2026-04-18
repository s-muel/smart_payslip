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
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFD3FF)),
                ),
                child: const Text(
                  'Version : Beta 0.1.1',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
