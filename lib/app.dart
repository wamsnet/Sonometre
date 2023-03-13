// https://github.com/syncfusion/flutter-examples/blob/master/lib/samples/chart/dynamic_updates/live_update/real_time_line_chart.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

class NoiseApp extends StatefulWidget {
  const NoiseApp({Key? key}) : super(key: key);

  @override
  NoiseAppState createState() => NoiseAppState();
}

class NoiseAppState extends State<NoiseApp> {
  bool _isRecording = false;
  // ignore: cancel_subscriptions
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  double? maxDB;
  double? meanDB;
  List<_ChartData> chartData = <_ChartData>[];
  // ChartSeriesController? _chartSeriesController;
  late int previousMillis;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) _isRecording = true;
    });
    maxDB = noiseReading.maxDecibel;
    meanDB = noiseReading.meanDecibel;

    chartData.add(
      _ChartData(
        maxDB,
        meanDB,
        ((DateTime.now().millisecondsSinceEpoch - previousMillis) / 1000)
            .toDouble(),
      ),
    );
  }

  void onError(Object e) {
    _isRecording = false;
  }

  void start() async {
    previousMillis = DateTime.now().millisecondsSinceEpoch;
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (e) {}
  }

  void stop() async {
    try {
      _noiseSubscription!.cancel();
      _noiseSubscription = null;

      setState(() => _isRecording = false);
    } catch (e) {}
    previousMillis = 0;
    chartData.clear();
  }

  void copyValue(
    bool theme,
  ) {
    Clipboard.setData(
      ClipboardData(
          text: 'It\'s about ${maxDB!.toStringAsFixed(1)}dB loudness'),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
          content: Row(
            children: [
              Icon(
                Icons.check,
                size: 14,
                color: theme ? Colors.white70 : Colors.black,
              ),
              const SizedBox(width: 10),
              const Text('Copied')
            ],
          ),
        ),
      );
    });
  }

  openEnspm() async {
    const url = 'https://enspm.netlify.app/';
    try {
      // ignore: deprecated_member_use
      await launch(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not launch $url'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.light;
    if (chartData.length >= 25) {
      chartData.removeAt(0);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.green[600] : Colors.green.shade800,
        title: const Text('Sonomètre'),
        actions: [
          IconButton(
              tooltip: 'Sonomètre indépendant',
              icon: const Icon(Icons.code_outlined),
              onPressed: openEnspm),
          IconButton(
            tooltip: 'Copier sur le presse papier',
            icon: const Icon(Icons.copy),
            onPressed: maxDB != null ? () => copyValue(isDark) : null,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(_isRecording ? 'Arreter' : 'Démarrer'),
        onPressed: _isRecording ? stop : start,
        icon: !_isRecording ? const Icon(Icons.circle) : null,
        backgroundColor: _isRecording ? Colors.red : Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                maxDB != null
                    ? maxDB!.toStringAsFixed(2)
                    : 'Appuyer sur démarrer',
                style: GoogleFonts.exo2(fontSize: 28),
              ),
            ),
          ),
          Text(
            meanDB != null
                ? 'Moyenne: ${meanDB!.toStringAsFixed(2)}'
                : 'En attente de données',
            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
          ),
          Expanded(
            child: SfCartesianChart(
              series: <LineSeries<_ChartData, double>>[
                LineSeries<_ChartData, double>(
                    dataSource: chartData,
                    xAxisName: 'Time',
                    yAxisName: 'dB',
                    name: 'dB values over time',
                    xValueMapper: (_ChartData value, _) => value.frames,
                    yValueMapper: (_ChartData value, _) => value.maxDB,
                    animationDuration: 0),
              ],
            ),
          ),
          const SizedBox(
            height: 68,
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final double? maxDB;
  final double? meanDB;
  final double frames;

  _ChartData(this.maxDB, this.meanDB, this.frames);
}
