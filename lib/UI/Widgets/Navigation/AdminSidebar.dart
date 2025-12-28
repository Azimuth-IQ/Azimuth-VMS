import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Admin sidebar navigation for desktop layouts
class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  
  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          _buildHeader(theme),
          Expanded(
            child: _buildNavigationItems(context, theme),
          ),
          _buildFooter(context, theme),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Azimuth VMS',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationItems(BuildContext context, ThemeData theme) {
    final List<_NavItem> items = <_NavItem>[
      _NavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        index: 0,
      ),
      _NavItem(
        icon: Icons.event_outlined,
        selectedIcon: Icons.event,
        label: 'Events',
        index: 1,
      ),
      _NavItem(
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: 'Volunteers',
        index: 2,
      ),
      _NavItem(
        icon: Icons.supervisor_account_outlined,
        selectedIcon: Icons.supervisor_account,
        label: 'Team Leaders',
        index: 3,
      ),
      _NavItem(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        label: 'Teams',
        index: 4,
      ),
      _NavItem(
        icon: Icons.location_on_outlined,
        selectedIcon: Icons.location_on,
        label: 'Locations',
        index: 5,
      ),
      _NavItem(
        icon: Icons.campaign_outlined,
        selectedIcon: Icons.campaign,
        label: 'Notifications',
        index: 6,
      ),
    ];
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: items.map((item) {
        final bool isSelected = selectedIndex == item.index;
        return _buildNavItem(context, theme, item, isSelected);
      }).toList(),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context,
    ThemeData theme,
    _NavItem item,
    bool isSelected,
  ) {
    final Color primaryColor = theme.colorScheme.primary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onDestinationSelected(item.index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected ? primaryColor : onSurfaceColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            title: Text(
              'Settings',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  
  _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
  });
}
