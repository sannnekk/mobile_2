import 'package:flutter/material.dart';

class NooPagination extends StatelessWidget {
  final int currentPage;
  final int? totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final ValueChanged<int>? onPageSelected;
  final bool isLoading;

  const NooPagination({
    super.key,
    required this.currentPage,
    this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.onNextPage,
    this.onPreviousPage,
    this.onPageSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages == null || totalPages! <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: hasPreviousPage && !isLoading ? onPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            color: hasPreviousPage && !isLoading
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),

          // Page numbers
          ..._buildPageNumbers(context),

          // Next button
          IconButton(
            onPressed: hasNextPage && !isLoading ? onNextPage : null,
            icon: const Icon(Icons.chevron_right),
            color: hasNextPage && !isLoading
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final pages = <Widget>[];
    final total = totalPages!;

    // For small number of pages, just show all of them
    if (total <= 5) {
      for (int i = 1; i <= total; i++) {
        pages.add(_buildPageButton(context, i));
      }
      return pages;
    }

    // Show first page
    pages.add(_buildPageButton(context, 1));

    // Show ellipsis if needed
    if (currentPage > 3) {
      pages.add(_buildEllipsis());
    }

    // Show pages around current page
    final start = (currentPage - 1).clamp(2, total - 1);
    final end = (currentPage + 1).clamp(start, total - 1);

    for (int i = start; i <= end; i++) {
      if (i != 1 && i != total) {
        pages.add(_buildPageButton(context, i));
      }
    }

    // Show ellipsis if needed
    if (currentPage < total - 2) {
      pages.add(_buildEllipsis());
    }

    // Show last page
    pages.add(_buildPageButton(context, total));

    return pages;
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final isSelected = page == currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: isLoading ? null : () => onPageSelected?.call(page),
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          page.toString(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: const Text('...', style: TextStyle(color: Colors.grey)),
    );
  }
}
