import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Gap(16),
          _buildSectionHeader("Preferences"),
          _buildListTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            trailing: Switch(value: false, onChanged: (val) {}), // Placeholder
          ),
          _buildListTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            trailing: Switch(value: true, onChanged: (val) {}), // Placeholder
          ),
          
          const Gap(24),
          _buildSectionHeader("Data"),
          _buildListTile(
            icon: Icons.download_outlined,
            title: "Export Data",
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.delete_outline,
            title: "Clear All Data",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),

          const Gap(24),
          _buildSectionHeader("About"),
          _buildListTile(
            icon: Icons.info_outline,
            title: "Version",
            trailing: Text(_version, style: const TextStyle(color: Colors.grey)),
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: "Terms of Service",
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),

          const Gap(24),
          _buildSectionHeader("Account"),
          _buildListTile(
            icon: Icons.logout,
            title: "Logout",
            textColor: Colors.red,
            iconColor: Colors.red,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500, 
          color: textColor ?? Colors.black,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
