import 'package:flutter/material.dart';
import 'package:smartpayslip/UI%20Element/slider_bar_item.dart';

class SideBar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onItemSelected;

  const SideBar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Payslip System',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                SideBarItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isSelected: selectedItem == 'Dashboard',
                  onTap: () => onItemSelected('Dashboard'),
                ),
                SideBarItem(
                  icon: Icons.upload_file_outlined,
                  title: 'Upload Files',
                  isSelected: selectedItem == 'Upload Files',
                  onTap: () => onItemSelected('Upload Files'),
                ),
                SideBarItem(
                  icon: Icons.call_split_outlined,
                  title: 'Split & Match',
                  isSelected: selectedItem == 'Split & Match',
                  onTap: () => onItemSelected('Split & Match'),
                ),
                SideBarItem(
                  icon: Icons.send_outlined,
                  title: 'Send Emails',
                  isSelected: selectedItem == 'Send Emails',
                  onTap: () => onItemSelected('Send Emails'),
                ),
                SideBarItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Reports',
                  isSelected: selectedItem == 'Reports',
                  onTap: () => onItemSelected('Reports'),
                ),
                SideBarItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  isSelected: selectedItem == 'Settings',
                  onTap: () => onItemSelected('Settings'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SideBarItem(
              icon: Icons.logout,
              title: 'Logout',
              isSelected: false,
              onTap: () {
                // TODO: logout logic
              },
            ),
          ),
        ],
      ),
    );
  }
}
