import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(EazyTime());
}

class EazyTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.purple, backgroundColor: Colors.white),
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
  List<CustomText> _activities = <CustomText>[];
  TextEditingController _textController = TextEditingController();
  int _selectedActivityIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(height: 100, child: buildTimeRow(context)),
          ]),
          Center(
            child: LimitedBox(
              maxHeight: 200,
              maxWidth: 200,
              child: buildActivityList(context),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextButton(
                    child: Text('Manage Activities'),
                    onPressed: () => {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Add Activity'),
                                  content: TextFormField(
                                      controller: _textController),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Add'),
                                      onPressed: () {
                                        if (_textController.text.isNotEmpty) {
                                          _activities.add(
                                              CustomText(_textController.text));
                                          setState(() {});
                                          _textController.text = "";
                                        }
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              })
                        }),
              ),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Info'),
                            content: Text('List has ' +
                                _activities.length.toString() +
                                ' entries!'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'))
                            ],
                          );
                        });
                  },
                  child: Text('Switch')),
            ],
          ),
          Expanded(child: Placeholder()),
        ],
      ),
    );
  }

  Widget buildTimeRow(BuildContext context) {
    return Row(
      children: [
        CustomText(_hour.toString().padLeft(2, '0')),
        CustomText(':'),
        CustomText(_minute.toString().padLeft(2, '0')),
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
    );
  }

  Widget buildActivityList(BuildContext context) {
    return Stack(children: [
      ListWheelScrollView(
        key: UniqueKey(),
        // Without this line it doesn't update!!!
        onSelectedItemChanged: (index) => updateSelectedActivity(index),
        diameterRatio: 1.5,
        children: _activities,
        itemExtent: 48,
        magnification: 1.2,
        useMagnifier: true,
      ),
      IgnorePointer(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.0),
                  ],
                  stops: [
                    0.0,
                    0.45
                  ])),
        ),
      ),
      IgnorePointer(
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black,
                  ],
                  stops: [
                    0.55,
                    1
                  ])),
        ),
      ),
    ]);
  }

  void updateSelectedActivity(int index) {
    _selectedActivityIndex = index;
    //_activities[index].color = Colors.amber;
    //setState(() {});
  }
}

class CustomText extends Text {
  CustomText(this.data, [this.color = Colors.white]) : super(data);
  final String data;
  Color color;

  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: TextStyle(color: color, decoration: TextDecoration.none));
  }
}
