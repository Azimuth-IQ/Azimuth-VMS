import 'package:flutter/material.dart';

/// A reusable widget that provides archive/unarchive and delete functionality
/// with confirmation dialogs and proper error handling
class ArchiveDeleteMenu extends StatelessWidget {
  final bool isArchived;
  final VoidCallback onArchive;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;
  final String itemName;
  final String itemType; // e.g., "Event", "Location", "Team", "User"

  const ArchiveDeleteMenu({
    super.key,
    required this.isArchived,
    required this.onArchive,
    required this.onUnarchive,
    required this.onDelete,
    required this.itemName,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'archive':
            _showArchiveConfirmation(context);
            break;
          case 'unarchive':
            _showUnarchiveConfirmation(context);
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!isArchived)
          const PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                Icon(Icons.archive, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text('Archive'),
              ],
            ),
          ),
        if (isArchived)
          const PopupMenuItem(
            value: 'unarchive',
            child: Row(
              children: [
                Icon(Icons.unarchive, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('Unarchive'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  void _showArchiveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.archive, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Archive $itemType?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to archive "$itemName"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('This will hide the $itemType from active lists but keep all data intact.', style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onArchive();
            },
            icon: const Icon(Icons.archive),
            label: const Text('Archive'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showUnarchiveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.unarchive, color: Colors.blue),
            const SizedBox(width: 12),
            Text('Unarchive $itemType?'),
          ],
        ),
        content: Text('Are you sure you want to restore "$itemName" to active status?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onUnarchive();
            },
            icon: const Icon(Icons.unarchive),
            label: const Text('Unarchive'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Text('Delete $itemType?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to permanently delete "$itemName"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone! All associated data will be permanently deleted.',
                      style: TextStyle(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// A toggle button to show/hide archived items
class ShowArchivedToggle extends StatelessWidget {
  final bool showArchived;
  final ValueChanged<bool> onChanged;
  final int archivedCount;

  const ShowArchivedToggle({super.key, required this.showArchived, required this.onChanged, this.archivedCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: showArchived ? Colors.grey.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CheckboxListTile(
        dense: true,
        value: showArchived,
        onChanged: (value) => onChanged(value ?? false),
        title: Row(
          children: [
            Icon(showArchived ? Icons.archive : Icons.archive_outlined, size: 20, color: showArchived ? Colors.orange : Colors.grey),
            const SizedBox(width: 8),
            Text('Show Archived', style: TextStyle(fontSize: 14, color: showArchived ? Colors.black87 : Colors.grey.shade700)),
            if (archivedCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  archivedCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A chip/badge to show archived status on list items
class ArchivedBadge extends StatelessWidget {
  const ArchivedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.archive, size: 14, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Text(
            'ARCHIVED',
            style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
