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
            appBar: AppBar(title: const Text('Stats')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Andamento punteggio cumulativo (+10 vittoria / -5 sconfitta)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

    return SizedBox(
      height: 280,
      width: double.infinity,
      child: CustomPaint(
        painter: ScoreGraphPainter(viewModel.cumulativeScores),
      ),
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

    // Draw baseline at zero if within range
    if (minScore <= 0 && maxScore >= 0) {
      final double zeroY = ((maxScore - 0) / range) * height;
      canvas.drawLine(Offset(0, zeroY), Offset(width, zeroY), axisPaint);
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