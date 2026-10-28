import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../services/mock_transport_service.dart';
import '../../utils/theme.dart';

class BusTrackerController extends ChangeNotifier {
  List<Map<String, dynamic>> _lines = [];
  List<Map<String, dynamic>> _filteredLines = [];
  Map<int, List<Map<String, dynamic>>> _lineDirections = {};
  bool _isLoading = true;
  Timer? _searchDebounce;
  bool _isDisposed = false;

  List<Map<String, dynamic>> get filteredLines => _filteredLines;
  bool get isLoading => _isLoading;

  Future<void> initialize() => fetchBusData();

  Future<void> fetchBusData() async {
    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    final activeDirections = await MockTransportService.getActiveBuses();
    _lines = MockTransportService.getAllBuses()
        .where((line) => activeDirections.containsKey(line['idLinha']))
        .toList()
      ..sort(
        (a, b) => a['codigo'].toString().compareTo(b['codigo'].toString()),
      );
    _filteredLines = _lines;
    _lineDirections = activeDirections;
    _isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  void filterLines(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(AppTheme.debounceTime, () {
      if (_isDisposed) return;
      final normalizedQuery = query.toLowerCase();
      _filteredLines = _lines.where((line) {
        final name = line['nome']?.toString().toLowerCase() ?? '';
        final code = line['codigo']?.toString().toLowerCase() ?? '';
        return name.contains(normalizedQuery) || code.contains(normalizedQuery);
      }).toList();
      notifyListeners();
    });
  }

  List<Map<String, dynamic>> getExpandedList() => [
    for (final line in _filteredLines)
      ...?_lineDirections[line['idLinha'] as int],
  ];

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    super.dispose();
  }
}
