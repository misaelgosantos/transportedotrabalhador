import 'package:flutter/material.dart';

class AppHeaderWidget extends StatelessWidget {
  const AppHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.searchController,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchClear,
    this.showClearButton = true,
    this.showSearch = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final bool showClearButton;
  final bool showSearch;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
              Icon(icon, color: colors.primary, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showSearch && searchController != null) ...[
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint ?? 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: showClearButton && searchController!.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: onSearchClear,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
