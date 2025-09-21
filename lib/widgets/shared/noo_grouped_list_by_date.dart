import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/core/utils/date_helpers.dart';

/// A reusable widget that groups a list of items by date and displays them
/// with date headers.
class NooGroupedListByDate<T> extends StatelessWidget {
  /// The list of items to group and display.
  final List<T> items;

  /// Function to extract the date from each item.
  final DateTime Function(T) dateExtractor;

  /// Function to build the widget for each item.
  final Widget Function(T) itemBuilder;

  /// Optional function to format dates for display.
  /// Defaults to a Russian locale formatter that shows relative dates.
  final String Function(DateTime)? dateFormatter;

  /// Optional comparator for sorting date groups.
  /// Defaults to descending order (newest first).
  final int Function(String, String)? dateKeyComparator;

  /// Optional padding for the list.
  final EdgeInsetsGeometry? padding;

  /// Optional spacing between groups.
  final double groupSpacing;

  /// Optional spacing between items within a group.
  final double itemSpacing;

  /// Optional widget to display at the bottom of the list.
  final Widget? bottomWidget;

  const NooGroupedListByDate({
    super.key,
    required this.items,
    required this.dateExtractor,
    required this.itemBuilder,
    this.dateFormatter,
    this.dateKeyComparator,
    this.padding,
    this.groupSpacing = 8.0,
    this.itemSpacing = 0.0,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByDate();
    final sortedGroups = _sortGroups(groupedItems);
    final filteredGroups = sortedGroups
        .where((g) => g.items.isNotEmpty)
        .toList();

    return ListView.builder(
      padding: padding,
      itemCount: filteredGroups.length + (bottomWidget != null ? 1 : 0),
      itemBuilder: (context, index) {
        // If this is the last item and we have a bottomWidget, return it
        if (bottomWidget != null && index == filteredGroups.length) {
          return bottomWidget!;
        }

        final group = filteredGroups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.symmetric(vertical: groupSpacing),
              child: NooText(group.date, dimmed: true),
            ),
            // Items for this date
            ...(() {
              final itemWidgets = group.items
                  .map(itemBuilder)
                  .expand(
                    (widget) => [
                      widget,
                      if (itemSpacing > 0) SizedBox(height: itemSpacing),
                    ],
                  )
                  .toList();
              if (itemSpacing > 0) {
                itemWidgets.removeLast(); // Remove the last spacing
              }
              return itemWidgets;
            })(),
          ],
        );
      },
    );
  }

  List<_GroupedItems<T>> _groupItemsByDate() {
    final groups = <String, List<T>>{};

    for (final item in items) {
      final date = dateExtractor(item);
      final dateKey = _formatDateKey(date);
      groups.putIfAbsent(dateKey, () => []).add(item);
    }

    return groups.entries
        .map(
          (entry) => _GroupedItems(
            dateKey: entry.key,
            date: _formatDisplayDate(DateTime.parse(entry.key)),
            items: entry.value,
          ),
        )
        .toList();
  }

  List<_GroupedItems<T>> _sortGroups(List<_GroupedItems<T>> groups) {
    if (dateKeyComparator != null) {
      // Custom sorting
      final dateKeys = groups.map((g) => g.dateKey).toList();
      final sortedIndices = List.generate(groups.length, (i) => i)
        ..sort((a, b) => dateKeyComparator!(dateKeys[a], dateKeys[b]));
      return sortedIndices.map((i) => groups[i]).toList();
    } else {
      // Default: sort by date descending (newest first)
      return groups..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    }
  }

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDisplayDate(DateTime date) {
    final formatter = dateFormatter ?? _defaultDateFormatter;
    return formatter(date);
  }

  String _defaultDateFormatter(DateTime date) {
    return formatRelativeDate(date);
  }
}

class _GroupedItems<T> {
  final String dateKey;
  final String date;
  final List<T> items;

  const _GroupedItems({
    required this.dateKey,
    required this.date,
    required this.items,
  });
}
