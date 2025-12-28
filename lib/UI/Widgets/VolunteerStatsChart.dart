import 'package:azimuth_vms/Helpers/AttendanceHelperFirebase.dart';
import 'package:azimuth_vms/Models/AttendanceRecord.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class VolunteerStatsChart extends StatefulWidget {
  final String userPhone;
  const VolunteerStatsChart({super.key, required this.userPhone});

  @override
  State<VolunteerStatsChart> createState() => _VolunteerStatsChartState();
}

class _VolunteerStatsChartState extends State<VolunteerStatsChart> {
  final AttendanceHelperFirebase _helper = AttendanceHelperFirebase();
  List<BarChartGroupData> _barGroups = [];
  List<String> _monthLabels = [];
  bool _isLoading = true;
  double _maxY = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final records = await _helper.GetAttendanceRecordsByVolunteer(widget.userPhone);
      _processData(records);
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processData(List<AttendanceRecord> records) {
    final now = DateTime.now();
    final Map<int, int> shiftsPerMonth = {};
    final List<String> labels = [];

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = monthDate.year * 100 + monthDate.month; // YYYYMM
      shiftsPerMonth[monthKey] = 0;
      labels.add(DateFormat('MMM').format(monthDate));
    }

    // Count unique shifts per month
    final Set<String> processedShifts = {};

    for (var record in records) {
      if (!record.present) continue;

      // Only count each shift once (even if multiple checks)
      final shiftKey = '${record.eventId}_${record.shiftId}';
      if (processedShifts.contains(shiftKey)) continue;

      try {
        final date = DateTime.parse(record.timestamp);
        final monthKey = date.year * 100 + date.month;

        if (shiftsPerMonth.containsKey(monthKey)) {
          shiftsPerMonth[monthKey] = (shiftsPerMonth[monthKey] ?? 0) + 1;
          processedShifts.add(shiftKey);
        }
      } catch (e) {
        print('Error parsing date: ${record.timestamp}');
      }
    }

    // Create bar groups
    final List<BarChartGroupData> groups = [];
    int index = 0;
    double maxVal = 0;

    shiftsPerMonth.forEach((key, count) {
      if (count > maxVal) maxVal = count.toDouble();
      groups.add(_makeGroupData(index, count.toDouble()));
      index++;
    });

    if (mounted) {
      setState(() {
        _barGroups = groups;
        _monthLabels = labels;
        _maxY = (maxVal > 5 ? maxVal : 5) * 1.2; // Add some headroom
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.activityOverview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.shiftsCompletedLast6Months, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(rod.toY.round().toString(), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= _monthLabels.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(
                            _monthLabels[value.toInt()],
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12));
                      },
                      interval: _maxY > 10 ? 5 : 1,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY > 10 ? 5 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: _maxY, color: Colors.grey.withOpacity(0.1)),
        ),
      ],
    );
  }
}
