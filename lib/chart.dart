import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/Materia.dart';
import 'models/SessaoMateria.dart';

class PieChartPage extends StatefulWidget {
  @override
  _PieChartPageState createState() => _PieChartPageState();
}

class _PieChartPageState extends State<PieChartPage> {
  List<PieChartSectionData>? _sections;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var sessoes = await SessaoMateria.getSessoesMateria();
    var materias = await Materia.getMaterias();

    var todaySessoes = await SessaoMateria.getSessoesByDate(sessoes, DateTime.now());
    var workSessoes = await SessaoMateria.getSessoesByIdle(todaySessoes, false);
    var groupedSessoes = await SessaoMateria.groupSessoesByMateria(workSessoes, materias);

    Map<Materia, Duration> timePerMateria = await SessaoMateria.getSessoesSumTime(groupedSessoes);

    var secoes = timePerMateria.entries.map((entry) {
      final materia = entry.key;
      final duration = entry.value;

      // Calculate the percentage
      final totalDuration = timePerMateria.values.fold(
        Duration.zero,
            (sum, duration) => sum + duration,
      );
      final double percentage = duration.inSeconds / totalDuration.inSeconds * 100;

      return PieChartSectionData(
        color: materia.cor,  // Replace with your desired color
        value: percentage,
        title: percentage > 12 ? '${(percentage).toStringAsFixed(1)}%' : '',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();

    setState(() {
      _sections = secoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pie Chart Example'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 80),
            Container(
              height: 150.0,
              width: 120.0,
              child: _sections == null
                  ? CircularProgressIndicator() // Show a loading indicator while data is loading
                  : PieChart(
                PieChartData(
                  sections: _sections!,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 80),
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey, // Background color
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          child: Row(
            children: [
              const SizedBox(width: 8.0), // Space between icon and text
              Expanded(
                child: Text(
                  'label',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Text(
                'time',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(width: 8.0), // Space between time and percentage
              Text(
                'percentage',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        )


          ],
        ),
        ),
    );
  }
}
