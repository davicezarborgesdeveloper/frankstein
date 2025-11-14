import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Color(0xFFEAEAEA),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: MonthlyVariationCard(),
          ),
        ),
      ),
    );
  }
}

// ------------------- CONFIG COMPARTILHADA -------------------

class _ChartConstants {
  static const double chartHeight = 220;

  static const double yAxisWidth = 40;

  static const double topPadding = 8;
  static const double bottomPadding = 32;
  static const double leftPadding = 8;
  static const double rightPadding = 8;

  static const double barWidth = 21;
  static const double barSpacing = 21;

  static const double topValue = 2.0;
  static const double bottomValue = -0.6;
  static const double step = 0.2;

  static const double zeroValue = 0.0;

  static int get gridLines => ((topValue - bottomValue) / step).round();
}

// ------------------- CARD -------------------

class MonthlyVariationCard extends StatelessWidget {
  const MonthlyVariationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final values = <double>[
      1.0,
      2.3,
      1.0,
      -0.7,
      0.9,
      -0.6,
      2.0,
      1.42,
      1.12,
      1.20,
      1.06,
      0.96,
    ];

    final labels = <String>[
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Variação mensal (%)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: _ChartConstants.chartHeight,
            width: double.infinity,
            child: Row(
              children: [
                // EIXO Y FIXO
                SizedBox(
                  width: _ChartConstants.yAxisWidth,
                  height: double.infinity,
                  child: const CustomPaint(painter: _YAxisPainter()),
                ),

                // GRÁFICO ROLÁVEL
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalBarsWidth =
                          values.length * _ChartConstants.barWidth +
                          (values.length - 1) * _ChartConstants.barSpacing;

                      final paintWidth = math.max(
                        constraints.maxWidth,
                        totalBarsWidth +
                            _ChartConstants.leftPadding +
                            _ChartConstants.rightPadding,
                      );

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: _ChartConstants.chartHeight,
                          width: paintWidth,
                          child: CustomPaint(
                            painter: _BarChartPainter(
                              values: values,
                              labels: labels,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- EIXO Y (FIXO) -------------------

class _YAxisPainter extends CustomPainter {
  const _YAxisPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight =
        size.height -
        _ChartConstants.topPadding -
        _ChartConstants.bottomPadding;
    final chartTop = _ChartConstants.topPadding;

    const textStyle = TextStyle(fontSize: 11, color: Colors.black87);

    for (int i = 0; i <= _ChartConstants.gridLines; i++) {
      final t = i / _ChartConstants.gridLines;
      final y = chartTop + chartHeight * t;

      double value = _ChartConstants.topValue - _ChartConstants.step * i;
      if (value.abs() < 0.0001) value = 0.0; // evitar -0.0
      final labelText = value.toStringAsFixed(1);

      final tp = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // alinhado à direita dessa área de 40px
      final dx = size.width - 4 - tp.width;
      final dy = y - tp.height / 2;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------- GRÁFICO (GRADE + BARRAS + MESES) -------------------

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _BarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth =
        size.width - _ChartConstants.leftPadding - _ChartConstants.rightPadding;
    final chartHeight =
        size.height -
        _ChartConstants.topPadding -
        _ChartConstants.bottomPadding;

    final chartLeft = _ChartConstants.leftPadding;
    final chartRight = chartLeft + chartWidth;
    final chartTop = _ChartConstants.topPadding;
    final chartBottom = chartTop + chartHeight;

    // fundo
    final bgPaint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final range = _ChartConstants.topValue - _ChartConstants.bottomValue;

    // posição da linha de zero (0.0)
    final zeroT =
        (_ChartConstants.topValue - _ChartConstants.zeroValue) / range;
    final zeroY = chartTop + chartHeight * zeroT;

    // ===== linhas horizontais =====
    final dashedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1;

    final zeroPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    for (int i = 0; i <= _ChartConstants.gridLines; i++) {
      final t = i / _ChartConstants.gridLines;
      final y = chartTop + chartHeight * t;

      double value = _ChartConstants.topValue - _ChartConstants.step * i;

      final isZeroLine = value.abs() < 0.0001;

      if (isZeroLine) {
        // linha contínua preta (0.0)
        canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), zeroPaint);
      } else {
        // linhas tracejadas cinza
        _drawDashedHorizontalLine(
          canvas,
          y,
          chartLeft,
          chartRight,
          dashedPaint,
        );
      }
    }

    // ===== barras (sempre partindo do zero) =====
    final barPaint = Paint()
      ..color = const Color(0xFF00AEEF)
      ..style = PaintingStyle.fill;

    final int n = values.length;
    final double totalBarsWidth =
        n * _ChartConstants.barWidth + (n - 1) * _ChartConstants.barSpacing;

    final double availableWidth = chartWidth;

    final double startX = totalBarsWidth >= availableWidth
        ? chartLeft
        : chartLeft + (availableWidth - totalBarsWidth) / 2;

    // área do gráfico que vai “cortar” as barras
    final chartRect = Rect.fromLTRB(
      chartLeft,
      chartTop,
      chartRight,
      chartBottom,
    );

    canvas.save();
    canvas.clipRect(chartRect); // <- aqui é o truque do topo/fundo reto

    for (int i = 0; i < n; i++) {
      final value = values[i];

      // altura proporcional ao valor em relação ao range total
      final barHeight =
          (value - _ChartConstants.zeroValue).abs() / range * chartHeight;

      final barLeft =
          startX + i * (_ChartConstants.barWidth + _ChartConstants.barSpacing);
      final barRight = barLeft + _ChartConstants.barWidth;

      late double barTop;
      late double barBottom;

      if (value >= _ChartConstants.zeroValue) {
        // barra pra cima
        barTop = zeroY - barHeight;
        barBottom = zeroY;
      } else {
        // barra pra baixo
        barTop = zeroY;
        barBottom = zeroY + barHeight;
      }

      // NÃO faz clamp em chartTop/chartBottom:
      // se passar do limite, deixa passar que o clipRect corta
      final barRect = Rect.fromLTRB(barLeft, barTop, barRight, barBottom);

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(6)),
        barPaint,
      );
    }

    canvas.restore(); // tira o clip: labels dos meses não são cortadas

    // ===== labels dos meses: logo abaixo da linha preta (0.0) =====
    final textStyle = TextStyle(fontSize: 12, color: Colors.grey.shade700);

    for (int i = 0; i < n; i++) {
      final label = labels[i];

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      final barLeft =
          startX + i * (_ChartConstants.barWidth + _ChartConstants.barSpacing);
      final groupCenter = barLeft + _ChartConstants.barWidth / 2;

      final dx = groupCenter - tp.width / 2;
      final dy = zeroY + 4;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawDashedHorizontalLine(
    Canvas canvas,
    double y,
    double xStart,
    double xEnd,
    Paint paint, {
    double dashWidth = 4,
    double dashSpace = 4,
  }) {
    double x = xStart;
    while (x < xEnd) {
      final x2 = math.min(x + dashWidth, xEnd);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        !listEquals(oldDelegate.labels, labels);
  }
}
