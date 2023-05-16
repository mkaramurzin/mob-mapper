import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Dot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Image Dot'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (TapUpDetails details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                  print('Point added: ${details.localPosition}');
                },
                child: Image.network(
                  'assets/maps/ungoro.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ..._points.map(
              (Offset offset) => Positioned(
                left: offset.dx,
                top: offset.dy,
                child: IconButton(
                  icon: Icon(Icons.circle, color: Colors.red),
                  onPressed: () {
                    print('Clicked on point: $offset');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
