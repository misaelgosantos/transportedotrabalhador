import 'package:flutter/material.dart';
import '../theme/app_theme_extensions.dart';
import '../theme/app_tokens.dart';

class BusCard extends StatelessWidget {
  final Map<String, dynamic> busData;
  final Map<String, dynamic> directionData;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const BusCard({
    super.key,
    required this.busData,
    required this.directionData,
    required this.isSmallScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final vehicles = directionData['vehicles'] as List?;
    final vehicleCount = vehicles?.length ?? 0;

    final isToCenter =
        directionData['directionName'].toString().toUpperCase().contains(
          'BAIRRO → CENTRO',
        ) ||
        directionData['directionName'].toString().toUpperCase().contains(
          'SHOPPING → RODOVIÁRIA',
        ) ||
        directionData['direction'] == 1;

    // Cores temáticas do sentido (Verde para Bairro -> Centro, Azul para Centro -> Bairro)
    final Color accentColor = isToCenter
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF0284C7));

    final Color bgColor = isToCenter
        ? (isDark ? const Color(0xFF0D2F1D) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF0F2642) : const Color(0xFFF0F7FF));

    final Color borderColor = accentColor.withValues(alpha: isDark ? 0.35 : 0.25);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        color: colors.surface,
        boxShadow: isDark ? null : context.glass.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                // Cabeçalho tematizado na cor do sentido (verde ou azul)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.14 : 0.07),
                    border: Border(
                      bottom: BorderSide(
                        color: accentColor.withValues(alpha: isDark ? 0.25 : 0.16),
                        width: 1,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          busData["codigo"],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          busData["nome"],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildDirectionInfo(
                        context,
                        isToCenter: isToCenter,
                        accentColor: accentColor,
                        bgColor: bgColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _buildVehicleDetails(
                        context,
                        vehicleCount,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionInfo(
    BuildContext context, {
    required bool isToCenter,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isToCenter
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 15,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              directionData['directionName'],
              style: TextStyle(
                fontSize: isSmallScreen ? 12.5 : 13.5,
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails(
    BuildContext context,
    int total, {
    required Color accentColor,
  }) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.14),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              size: 15,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$total ${total == 1 ? "van simulada" : "vans simuladas"} em operação',
              style: TextStyle(
                fontSize: isSmallScreen ? 12.5 : 13.5,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
