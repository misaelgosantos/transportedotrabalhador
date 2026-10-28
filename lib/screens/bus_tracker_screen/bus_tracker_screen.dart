import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_header_widget.dart';
import '../../utils/theme.dart';
import 'bus_tracker_screen_controller.dart';
import 'bus_tracker_screen_widgets.dart';

/// Lista de linhas disponíveis para acompanhar.
class BusTrackerScreen extends StatefulWidget {
  const BusTrackerScreen({super.key});

  @override
  State<BusTrackerScreen> createState() => _BusTrackerScreenState();
}

class _BusTrackerScreenState extends State<BusTrackerScreen> {
  late BusTrackerController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = BusTrackerController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    _controller.filterLines(query);
  }

  void _handleClearSearch() {
    _searchController.clear();
    _controller.filterLines('');
  }

  void _handleBusTap(Map<String, dynamic> directionData) {
    final linhaData = {
      ...directionData,
      'idLinha': directionData['idLinha'],
      'codigo': directionData['codigo'],
      'nome': directionData['nome'],
      'direction': directionData['direction'],
      'directionName': directionData['directionName'],
      'veiculos': directionData['vehicles'],
      'directionColor': directionData['direction'] == 1
          ? AppTheme.greenColor
          : AppTheme.blueColor,
    };

    context.push('/localizar', extra: linhaData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppHeaderWidget(
                title: 'Transporte do Trabalhador',
                subtitle: 'Escolha uma linha para acompanhar a van',
                icon: Icons.directions_bus_rounded,
                searchController: _searchController,
                searchHint: 'Pesquisar linha...',
                onSearchChanged: _handleSearchChanged,
                onSearchClear: _handleClearSearch,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_controller.isLoading &&
                          _controller.filteredLines.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    _buildLegendPill(
                                      AppTheme.blueColor,
                                      'Centro → Bairro',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildLegendPill(
                                      AppTheme.greenColor,
                                      'Bairro → Centro',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const MockDataIndicator(),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _controller.fetchBusData,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          displacement: 20,
                          strokeWidth: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildContent(isSmallScreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    if (_controller.isLoading) {
      return const LoadingState();
    }

    if (_controller.filteredLines.isEmpty) {
      return EmptyState(
        searchQuery: _searchController.text,
        onClearSearch: _handleClearSearch,
        isSmallScreen: isSmallScreen,
      );
    }

    return BusList(
      expandedList: _controller.getExpandedList(),
      filteredLines: _controller.filteredLines,
      isSmallScreen: isSmallScreen,
      scrollController: _scrollController,
      onBusTap: _handleBusTap,
    );
  }

  Widget _buildLegendPill(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
