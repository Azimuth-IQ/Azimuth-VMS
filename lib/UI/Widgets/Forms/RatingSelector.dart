import 'package:flutter/material.dart';

/// Rating selector with emoji ratings (for Theme 2 - Volunteer theme only)
/// Provides a friendly, accessible way to rate events
class RatingSelector extends StatelessWidget {
  final int? selectedRating;
  final ValueChanged<int>? onRatingChanged;
  final String? label;
  
  const RatingSelector({
    Key? key,
    this.selectedRating,
    this.onRatingChanged,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              label!,
              style: theme.textTheme.titleMedium,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildRatingOption(context, 1, '😢', 'Very Poor'),
            _buildRatingOption(context, 2, '😕', 'Poor'),
            _buildRatingOption(context, 3, '😐', 'Average'),
            _buildRatingOption(context, 4, '😊', 'Good'),
            _buildRatingOption(context, 5, '😍', 'Excellent'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRatingOption(
    BuildContext context,
    int rating,
    String emoji,
    String label,
  ) {
    final ThemeData theme = Theme.of(context);
    final bool isSelected = selectedRating == rating;
    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color borderColor = theme.colorScheme.outline;
    
    return GestureDetector(
      onTap: () => onRatingChanged?.call(rating),
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : surfaceColor,
              border: Border.all(
                color: isSelected ? primaryColor : borderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected ? primaryColor : theme.textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
