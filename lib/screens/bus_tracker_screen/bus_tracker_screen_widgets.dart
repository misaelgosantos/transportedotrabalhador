import 'package:flutter/material.dart';

import '../../theme/app_theme_extensions.dart';
import '../../theme/app_tokens.dart';
import '../../utils/theme.dart';
import '../../widgets/bus_card.dart';
import '../../widgets/loading_indicator.dart';

class MockDataIndicator extends StatelessWidget {
  const MockDataIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: 14,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'Dados simulados',
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: const LoadingIndicator(
                message: 'Carregando linhas...',
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;
  final bool isSmallScreen;

  const EmptyState({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isEmpty ? Icons.directions_bus : Icons.search_off,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'Nenhuma linha disponível'
                  : 'Nenhum resultado para "$searchQuery"',
              style: TextStyle(
                color: context.colors.onSurface,
                fontSize: isSmallScreen ? 16 : 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  onPressed: onClearSearch,
                  child: Text(
                    'Limpar busca',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BusList extends StatelessWidget {
  final List<Map<String, dynamic>> expandedList;
  final List<Map<String, dynamic>> filteredLines;
  final bool isSmallScreen;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onBusTap;

  const BusList({
    super.key,
    required this.expandedList,
    required this.filteredLines,
    required this.isSmallScreen,
    required this.scrollController,
    required this.onBusTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: AppSpacing.bottomBarClearance),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: expandedList.length,
      itemBuilder: (context, index) {
        final directionData = expandedList[index];
        final bus = filteredLines.firstWhere(
          (b) => b["idLinha"] == directionData["idLinha"],
        );

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: BusCard(
                    busData: bus,
                    directionData: directionData,
                    isSmallScreen: isSmallScreen,
                    onTap: () => onBusTap(directionData),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
