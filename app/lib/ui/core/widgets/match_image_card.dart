import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:netshots/data/models/match_model.dart';

/// Reusable widget for displaying match images with weather, location, and other overlays
class MatchImageCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int index;

  const MatchImageCard({
    super.key,
    required this.match,
    required this.onTap,
    this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        match.isVictory ? Colors.green : Colors.red;
    final hasLocation = match.latitude != null && match.longitude != null;
    final hasWeather = match.temperature != null && match.weatherDescription != null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: Card(
        elevation: isDark ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo with overlays
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  image: DecorationImage(
                    image: _getImageProvider(match.picture),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Victory/Loss badge (top-left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: match.isVictory ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          match.isVictory ? Icons.emoji_events : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    // Weather info (top-right) if available
                    if (hasWeather)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getWeatherIcon(match.weatherDescription),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${match.temperature?.toStringAsFixed(1)}°',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Date label (bottom-left)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(match.date),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    // Map/Location icon (bottom-right) if location exists
                    if (hasLocation)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _launchMap(context, match.latitude!, match.longitude!),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    // Delete button if provided (positioned lower to avoid weather overlap)
                    if (onDelete != null)
                      Positioned(
                        top: hasWeather ? 50 : 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Notes section if available
            if (match.notes != null && match.notes!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.03)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  match.notes!,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return FileImage(File(imagePath));
  }

  IconData _getWeatherIcon(String? weatherDescription) {
    if (weatherDescription == null) return Icons.cloud_queue;

    final desc = weatherDescription.toLowerCase();

    if (desc.contains('clear') || desc.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloud')) {
      return Icons.wb_cloudy;
    } else if (desc.contains('rain')) {
      return Icons.cloud_queue;
    } else if (desc.contains('thunderstorm') || desc.contains('storm')) {
      return Icons.flash_on;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return Icons.cloud;
    } else if (desc.contains('wind')) {
      return Icons.air;
    }

    return Icons.cloud_queue;
  }

  Future<void> _launchMap(BuildContext context, double latitude, double longitude) async {
    try {
      final geoUrl = Uri.parse('geo:$latitude,$longitude');
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
        return;
      }

      final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire la mappa')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'apertura della mappa: $e')),
      );
    }
  }
}
