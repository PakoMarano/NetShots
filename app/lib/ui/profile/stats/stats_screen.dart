import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'stats_viewmodel.dart';

class StatsScreen extends StatelessWidget {
  final String userId;

  const StatsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatsViewModel>(
      create: (ctx) {
        final repo = Provider.of<ProfileRepository>(ctx, listen: false);
        final vm = StatsViewModel(repo);
        vm.fetchMatchResults(userId);
        return vm;
      },
      child: Consumer<StatsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Statistiche')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Andamento punteggio cumulativo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '(+10 vittoria / -5 sconfitta)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildBody(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(StatsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.cumulativeScores.isEmpty) {
      return const Center(child: Text('Nessuna partita registrata al momento'));
    }

    if (viewModel.cumulativeScores.length == 1) {
      return const Center(child: Text('Serve almeno una seconda partita per visualizzare il grafico'));
    }

    final currentScore = viewModel.cumulativeScores.last;
    final minScore = viewModel.cumulativeScores.reduce((a, b) => a < b ? a : b);
    final maxScore = viewModel.cumulativeScores.reduce((a, b) => a > b ? a : b);

    return Expanded(
      child: Column(
        children: [
          // Current score display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreInfo('Punteggio Attuale', currentScore, Colors.blueAccent),
                _buildScoreInfo('Massimo', maxScore, Colors.green),
                _buildScoreInfo('Minimo', minScore, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Graph
          Expanded(
            child: Row(
              children: [
                // Y-axis labels
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildYAxisLabels(minScore, maxScore),
                  ),
                ),
                const SizedBox(width: 8),
                // Graph
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          _handleGraphTap(
                            details.localPosition,
                            Size(constraints.maxWidth, constraints.maxHeight),
                            viewModel.cumulativeScores,
                            viewModel.matchResults,
                            context,
                          );
                        },
                        child: CustomPaint(
                          painter: ScoreGraphPainter(viewModel.cumulativeScores),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis label
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Partita ${viewModel.cumulativeScores.length}', 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildYAxisLabels(int minScore, int maxScore) {
    final range = maxScore - minScore;
    final step = range == 0 ? 1 : (range / 4).ceil();
    
    return List.generate(5, (index) {
      final value = maxScore - (step * index);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  void _handleGraphTap(
    Offset tapPosition,
    Size graphSize,
    List<int> scores,
    List<bool> matchResults,
    BuildContext context,
  ) {
    if (scores.isEmpty) return;

    final double width = graphSize.width;
    final double height = graphSize.height;

    final int maxScore = scores.reduce((a, b) => a > b ? a : b);
    final int minScore = scores.reduce((a, b) => a < b ? a : b);
    final double range = (maxScore - minScore).abs() < 1 ? 1 : (maxScore - minScore).toDouble();

    double xStep = scores.length == 1 ? 0 : width / (scores.length - 1);

    // Find nearest point
    int? nearestIndex;
    double minDistance = 20; // Touch tolerance

    for (int i = 0; i < scores.length; i++) {
      final double x = i * xStep;
      final double normalized = (maxScore - scores[i]) / range;
      final double y = normalized * height;
      final Offset pointPos = Offset(x, y);

      final double distance = (tapPosition - pointPos).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != null) {
      _showMatchDetails(context, nearestIndex, scores, matchResults);
    }
  }

  void _showMatchDetails(
    BuildContext context,
    int matchIndex,
    List<int> scores,
    List<bool> matchResults,
  ) {
    final isVictory = matchResults[matchIndex];
    final score = scores[matchIndex];
    final previousScore = matchIndex > 0 ? scores[matchIndex - 1] : 0;
    final pointsEarned = score - previousScore;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Partita ${matchIndex + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isVictory ? Icons.check_circle : Icons.cancel,
                    color: isVictory ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isVictory ? 'Vittoria' : 'Sconfitta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isVictory ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Punti guadagnati: ${pointsEarned > 0 ? '+' : ''}$pointsEarned',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Punteggio totale: $score',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }
}

class ScoreGraphPainter extends CustomPainter {
  final List<int> scores;

  ScoreGraphPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    final int maxScore = scores.reduce((a, b) => a > b ? a : b);
    final int minScore = scores.reduce((a, b) => a < b ? a : b);
    final double range = (maxScore - minScore).abs() < 1 ? 1 : (maxScore - minScore).toDouble();

    double xStep = scores.length == 1 ? 0 : width / (scores.length - 1);

    final Path linePath = Path();
    final Path fillPath = Path();

    Offset pointFor(int index) {
      final double x = index * xStep;
      final double normalized = (maxScore - scores[index]) / range;
      final double y = normalized * height;
      return Offset(x, y);
    }

    final firstPoint = pointFor(0);
    linePath.moveTo(firstPoint.dx, firstPoint.dy);
    fillPath.moveTo(firstPoint.dx, height);
    fillPath.lineTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < scores.length; i++) {
      final p = pointFor(i);
      linePath.lineTo(p.dx, p.dy);
      fillPath.lineTo(p.dx, p.dy);
    }

    fillPath.lineTo((scores.length - 1) * xStep, height);
    fillPath.close();

    final Paint gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blueAccent.withValues(alpha: 0.35),
          Colors.blueAccent.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    final Paint linePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Paint axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i < 5; i++) {
      final double y = (height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw baseline at zero if within range
    if (minScore <= 0 && maxScore >= 0) {
      final double zeroY = ((maxScore - 0) / range) * height;
      final Paint zeroPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, zeroY), Offset(width, zeroY), zeroPaint);
    }

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw points
    final Paint dotPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    for (int i = 0; i < scores.length; i++) {
      final p = pointFor(i);
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScoreGraphPainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}