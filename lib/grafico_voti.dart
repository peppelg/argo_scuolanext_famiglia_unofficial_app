import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final int id;
  final Color color;
  final BoxShape shape;
  final String text;
  final double size;
  final Color textColor;
  final Function onTap;

  const Indicator({
    Key key,
    this.id,
    this.onTap,
    this.shape,
    this.color,
    this.text,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(id),
      child: Row(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: shape,
              color: color,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          )
        ],
      )
    );
  }
}

class ChartVoti extends StatefulWidget {
  
  var data;

  ChartVoti(this.data);

  @override
  State<StatefulWidget> createState() {
    return _ChartVotiState(data);
  }
}

class _ChartVotiState extends State<ChartVoti> {

  var data;
  int selectedLabel = -1;

  static const int MONTH_OFFSET = 6;

  _ChartVotiState(this.data);

  var months = [
    "Gen", "Feb", "Mar", "Apr", "Mag", "Giu",
    "Lug", "Ago", "Set", "Ott", "Nov", "Dic"
  ];

  String getLabelFromMonth(double _month) {
    int month = _month.toInt();

    if (month < 0 || month >= 12)
      throw new ArgumentError("Mese non valido");

    return months[month];
  }

  @override
  Widget build(BuildContext context) {

    var indicators = <Indicator>[];
    var lineeGrafico = <LineChartBarData>[];
    
    int minY = 10, maxY = 0;

    int count = 0;
    data.forEach((key, element) {


      // Avendo un offset (per permettere di visualizzare l'anno scolastico
      // da Settembre fino ad Agosto), si invertono i punti per avere le linee
      // che vanno da sinistra verso destra (senza tornare indietro)
      var puntiPre = <FlSpot>[];
      var puntiPost = <FlSpot>[];
      for (var voto in element['voti']) {
        var x = (voto['month'].toInt() + MONTH_OFFSET) % 12;
        var punto = FlSpot(x.toDouble(), voto['value']);
        minY = min<double>(minY.toDouble(), voto['value']).toInt();
        maxY = max<double>(maxY.toDouble(), voto['value']).toInt();

        ( (x >= MONTH_OFFSET)
            ? puntiPost
            : puntiPre
        ).add(punto);
      }
      var punti = puntiPre + puntiPost;
      // var punti = element['voti'].map((voto) => FlSpot(voto['value'], voto['month']));

      var colore = new Color(element['colore']);

      indicators.add(Indicator(
            id: count,
            onTap: (id) {
              print("id => " + id.toString());
              setState(() {
                selectedLabel = selectedLabel == id ? -1 : id;
              });
            },
            shape: selectedLabel == count ? BoxShape.rectangle : BoxShape.circle,
            color: colore,
            text: element['label'],
            size: selectedLabel == count ? 18 : 16,
            textColor: Theme.of(context).textTheme.bodyText2.color.withAlpha(selectedLabel == count ? 200 : 100)
          )
      );

      if (selectedLabel == -1 || selectedLabel == count)
        lineeGrafico.add(LineChartBarData(
            colors: [colore],
            isCurved: true,
            curveSmoothness: 0.1,
            barWidth: 3,
            spots: punti
        ));

      count++;
    });

    var bordoGrafico = new BorderSide(color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.4));

    var graficoMediaGenerale = LineChart( 
      LineChartData(
        maxY: min(10, maxY.toDouble() + 1),
        minY: max(0, minY.toDouble()),
        titlesData: new FlTitlesData(
          topTitles: new SideTitles(showTitles: false),
          rightTitles: new SideTitles(showTitles: false),
          leftTitles: new SideTitles(rotateAngle: 0, showTitles: true),
          bottomTitles: new SideTitles(reservedSize: 0, showTitles: true, getTitles: (e) => getLabelFromMonth((e - MONTH_OFFSET) % 12))
        ),
        lineBarsData: lineeGrafico,
        gridData: new FlGridData(checkToShowVerticalLine: (_) => false),
        borderData: new FlBorderData(
          border: new Border(
            bottom: bordoGrafico,
            top: bordoGrafico,
            left: bordoGrafico,
            right: bordoGrafico
          )
        ),
        extraLinesData: new ExtraLinesData(
          horizontalLines: [
            new HorizontalLine(
              y: 6,
              color: Colors.green,
              label: HorizontalLineLabel(labelResolver: (_) => 'Sufficienza', show: true)
            )
          ]
        )
      ),
      swapAnimationCurve: Curves.linear,
      swapAnimationDuration: Duration(milliseconds: 500),
    );

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.95 * 0.8,
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 30),
                    child: graficoMediaGenerale
                  )
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: indicators
                )
              ]
            )
      )
    );
  }

}