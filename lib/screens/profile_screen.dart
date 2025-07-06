import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/link_model.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<Box<UserModel>>(
        valueListenable: DatabaseService.getUserListenable(),
        builder: (context, userBox, _) {
          final user = DatabaseService.getUser();
          
          return ValueListenableBuilder<Box<LinkModel>>(
            valueListenable: DatabaseService.getLinksListenable(),
            builder: (context, linkBox, _) {
              final links = DatabaseService.getAllLinks();
              
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(user),
                          _buildProfileInfo(user),
                          _buildStatsSection(links),
                          _buildActionsSection(context, user),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(UserModel? user) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          user?.name ?? 'Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C63FF),
                Color(0xFF9C27B0),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'profile_avatar',
              child: ProfileAvatar(
                size: 80,
                showBorder: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(UserModel? user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', user?.name ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow('Headline', user?.headline ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Joined',
              user?.createdAt != null
                  ? _formatDate(user!.createdAt)
                  : 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Last Updated',
              user?.updatedAt != null
                  ? _formatDate(user!.updatedAt)
                  : 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<LinkModel> links) {
    final totalLinks = links.length;
    final linksWithNotes = links.where((link) => link.note != null && link.note!.isNotEmpty).length;
    final platforms = links.map((link) => link.iconType).toSet().length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard('Total Links', totalLinks.toString(), Icons.link),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('With Notes', linksWithNotes.toString(), Icons.note),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Platforms', platforms.toString(), Icons.hub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6C63FF),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, UserModel? user) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 16),
        _buildActionTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Change your name and headline',
          onTap: () => _showEditProfileDialog(context, user),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _buildActionTile(
              icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              title: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              subtitle: 'Change app appearance',
              onTap: () {
                themeProvider.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Switched to ${themeProvider.isDarkMode ? 'Dark' : 'Light'} Mode',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            );
          },
        ),
        _buildActionTile(
          icon: Icons.backup,
          title: 'Export Data',
          subtitle: 'Export your links data',
          onTap: () => _exportData(context),
        ),
        _buildActionTile(
          icon: Icons.delete_forever,
          title: 'Clear All Data',
          subtitle: 'Remove all links and profile data',
          onTap: () => _showClearDataDialog(context),
          isDestructive: true,
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF6C63FF),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final headlineController = TextEditingController(text: user?.headline ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: headlineController,
              decoration: const InputDecoration(
                labelText: 'Headline',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = UserModel(
                name: nameController.text.trim(),
                headline: headlineController.text.trim(),
                createdAt: user?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await DatabaseService.saveUser(updatedUser);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final links = DatabaseService.getAllLinks();
    final user = DatabaseService.getUser();
    
    String exportText = 'LinksHub Export\n\n';
    exportText += 'Profile:\n';
    exportText += 'Name: ${user?.name ?? 'Not set'}\n';
    exportText += 'Headline: ${user?.headline ?? 'Not set'}\n\n';
    exportText += 'Links:\n';
    
    for (int i = 0; i < links.length; i++) {
      final link = links[i];
      exportText += '${i + 1}. ${link.title}\n';
      exportText += '   URL: ${link.url}\n';
      exportText += '   Platform: ${link.iconType}\n';
      if (link.note != null && link.note!.isNotEmpty) {
        exportText += '   Note: ${link.note}\n';
      }
      exportText += '\n';
    }
    
    await Clipboard.setData(ClipboardData(text: exportText));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all your data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
