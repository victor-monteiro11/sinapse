import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/Materia.dart';
import 'models/SessaoMateria.dart';

class PieChartPage extends StatefulWidget {
  @override
  _PieChartPageState createState() => _PieChartPageState();
}

class _PieChartPageState extends State<PieChartPage> {
  Column? coluna;
  List<PieChartSectionData>? _sections;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Função para carregar os dados do gráfico e lista de matérias
  Future<void> _loadData() async {
    var sessoes = await SessaoMateria.getSessoesMateria();
    var materias = await Materia.getMaterias();

    List<SessaoMateria> todaySessoes = await SessaoMateria.getSessoesByDate(sessoes, DateTime.now());
    List<SessaoMateria> workSessoes = await SessaoMateria.getSessoesByIdle(todaySessoes, false);
    Map<Materia, List<SessaoMateria>> groupedSessoes = await SessaoMateria.groupSessoesByMateria(workSessoes, materias);
    Map<Materia, Duration> timePerMateria = await SessaoMateria.getSessoesSumTime(groupedSessoes);
    Map<Materia, Duration> orderedTimePerMateria = await SessaoMateria.orderByDecreasing(timePerMateria);

    // Somatória do tempo total das sessões
    final totalDuration = orderedTimePerMateria.values.fold(
      Duration.zero,
          (sum, duration) => sum + duration,
    );

    // Função
    var secoes = orderedTimePerMateria.entries.map((entry) {
      final materia = entry.key;
      final duration = entry.value;

      // Calculate the percentage
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

      // Função que irá preencher a coluna com labels
      var colunaFuncVar = Column(
        children: orderedTimePerMateria.entries.map((entry) {
          final materia = entry.key;
          final duration = entry.value;

          // Calculate the percentage of the total time spent on this Materia
          final double percentage = (duration.inSeconds / totalDuration.inSeconds) * 100;

          return Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: materia.cor, // Background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: Row(
              children: [
                const SizedBox(width: 8.0), // Space between icon and text
                Expanded(
                  child: Text(
                    materia.nome,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Text(
                  formatDuration(duration), // Convert the duration to a human-readable format
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 8.0), // Space between time and percentage
                Text(
                  '${percentage.toStringAsFixed(1)}%', // Display the percentage
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
      setState(() {
        coluna = colunaFuncVar;
      });

  }

  // Helper function to format Duration as a human-readable string (e.g., "3h 15m")
  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
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
            SingleChildScrollView(
              child: coluna,
            )
          ],
        ),
        ),
    );
  }
}
