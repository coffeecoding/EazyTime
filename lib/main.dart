import 'package:flutter/material.dart';

void main() {
  runApp(EazyTime());
}

class EazyTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        key: Key('Test'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _hour = 12;
  int _minute = 34;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              height: 100,
              child: Row(
                children: [
                  TimeElement(_hour.toString().padLeft(2, '0')),
                  TimeElement(':'),
                  TimeElement(_minute.toString().padLeft(2, '0')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextButton(
                        child: Text('Select'),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          _hour = picked!.hour;
                          _minute = picked.minute;
                          setState(() {});
                        }),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          TimeOfDay time = TimeOfDay.now();
                          _hour = time.hour;
                          _minute = time.minute;
                        });
                      },
                      child: Text('Now'))
                ],
              ),
            ),
          ]),
          Expanded(child: Placeholder(fallbackHeight: 20, fallbackWidth: 50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextButton(onPressed: () => {}, child: Text('+ Add Activity')),
              ),
              ElevatedButton(onPressed: () => {}, child: Text('Switch')),
            ],
          ),
          Placeholder(),
        ],
      ),
    );
  }
}

class TimeElement extends Text {
  TimeElement(String data) : super(data);

  @override
  Widget build(BuildContext context) {
    return Text(data!,
        style: TextStyle(color: Colors.white, decoration: TextDecoration.none));
  }
}
