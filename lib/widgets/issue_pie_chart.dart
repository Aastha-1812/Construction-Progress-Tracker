import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IssuePieChart extends StatelessWidget {
  final Map<String, int> data;

  const IssuePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No issues submitted yet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFF6A3DE8),
      Colors.blueAccent,
      Colors.green,
      Colors.orange,
      Colors.redAccent,
    ];

    final radius = 50.0;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 35,
              sectionsSpace: 2,
              sections: _buildSections(data, total, colors, radius),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: data.entries.map((entry) {
            int index = data.keys.toList().indexOf(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: colors[index % colors.length],
                ),
                const SizedBox(width: 6),
                Text(entry.key, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        )
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
      Map<String, int> data,
      int total,
      List<Color> colors,
      double radius,
      ) {
    int index = 0;

    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;

      final section = PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        radius: radius,
        title: "${percentage.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );

      index++;
      return section;
    }).toList();
  }
}
