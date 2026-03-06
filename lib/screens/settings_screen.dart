import 'package:flutter/material.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1F44),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ilyess mlaouhi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    SizedBox(height: 4),
                    Text('ilyessmlaouhi@pharma.com',
                        style: TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white60),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionLabel('Application'),
          _buildTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.language_outlined,
            label: 'Language',
            trailing: Text('English',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.color_lens_outlined,
            label: 'Theme',
            trailing: Text('Navy Blue',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            onTap: () {},
          ),

          const SizedBox(height: 16),

          _buildSectionLabel('Pharmacy'),
          _buildTile(
            icon: Icons.business_outlined,
            label: 'Pharmacy Info',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.schedule_outlined,
            label: 'Working Hours',
            onTap: () {},
          ),

          const SizedBox(height: 16),

          _buildSectionLabel('Support'),
          _buildTile(
            icon: Icons.help_outline,
            label: 'Help & FAQ',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.info_outline,
            label: 'About',
            trailing: Text('v1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log out',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade400,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1F44).withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A1F44), size: 20),
        ),
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing ??
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}