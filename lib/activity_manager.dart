import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_eazytime/styles.dart';

class ActivityManager extends StatefulWidget {
  ActivityManager(this.activities);

  final List<String> activities;

  @override
  _ActivityManagerState createState() => _ActivityManagerState(activities);
}

class _ActivityManagerState extends State<ActivityManager> {
  _ActivityManagerState(this.activities);

  final List<String> activities;
  final _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Manage Activities', style: NormalTextStyle())),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  itemBuilder: (_, int i) => i.isEven
                    ? Dismissible(
                        key: UniqueKey(),
                        background: Flexible(
                          child: Container(color: ColorSpec.myRed)
                        ),
                        onDismissed: (dir) => (activities.removeAt(i)),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 40,
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(activities[i ~/ 2], style: NormalTextStyle(Colors.black))))
                    : Divider(),
                  itemCount: activities.length * 2
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                child: IconTheme(
                  data: IconThemeData(color: Theme.of(context).accentColor),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(children: [
                      Flexible(
                        child: Material(
                          child: TextField(
                            onChanged: (String text) {
                              setState(() {
                                _isComposing = text.length > 0;
                              });
                            },
                            onSubmitted: _isComposing ? _handleAdd : null,
                            controller: _textController,
                            maxLines: 1,
                            focusNode: _textFocusNode,
                            decoration: InputDecoration.collapsed(hintText: 'Enter activity')),
                        ),
                      ),
                      Material(
                        child: IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: _isComposing
                            ? () => _handleAdd(_textController.text)
                            : null,
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAdd(String text) {
    if (text.isEmpty)
      return;
    _textController.clear();
    _isComposing = false;
    activities.add(text);
    _textFocusNode.requestFocus();
    setState(() {
    });
  }
}

class ActivityEntry extends StatelessWidget {
  ActivityEntry(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(name, style: NormalTextStyle(Colors.black));
  }
}