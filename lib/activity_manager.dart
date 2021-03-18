import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eazytime/activity.dart';
import 'package:flutter_eazytime/styles.dart';
import 'data_access.dart';
import 'data_access.dart';
import 'data_access.dart';

class ActivityManager extends StatefulWidget {
  ActivityManager(this.activities);

  final List<Activity> activities;

  @override
  _ActivityManagerState createState() =>
      _ActivityManagerState(activities);
}

class _ActivityManagerState extends State<ActivityManager> {
  _ActivityManagerState(this.activities);

  final _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  List<Activity> activities;
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar:
            AppBar(title: Text('Manage Activities', style: NormalTextStyle())),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    itemBuilder: (_, int i) => Dismissible(
                        key: UniqueKey(),
                        background:
                            Flexible(child: Container(color: ColorSpec.myRed)),
                        onDismissed: (dir) => _handleDismissActivity(dir, i),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1.0))),
                            height: 50,
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(activities[i].name,
                                style: NormalTextStyle(
                                    Color(activities[i].color))))),
                    itemCount: activities.length),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor),
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
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Enter activity')),
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

  void _handleDismissActivity(DismissDirection dir, int i) async {
    Activity activityToDel = activities.elementAt(i);
    await DBClient.instance.deleteActivity(activityToDel);
    //activities.removeAt(i);
    activities = await DBClient.instance.getActiveActivities();
    setState(() {

    });
  }

  void _handleAdd(String text) async {
    if (text.isEmpty)
      return;
    else if (activities.any((act) => act.name == text)) {
      alert(context, 'Activity \'$text\' already exists.');
      return;
    }
    _textController.clear();
    _isComposing = false;
    int c = await DBClient.instance.getActiveActivityCount();
    Activity newActivity = Activity(
        text, ColorSpec.colorCircle[c % ColorSpec.colorCircle.length].value);
    int newId = await DBClient.instance.insertActivity(newActivity);
    if (newId > 0) {
      newActivity = await DBClient.instance.getActivityById(newId);
      activities.add(newActivity);
      _sortActivities();
    }
    _textFocusNode.requestFocus();
    setState(() {
    });
  }

  void _sortActivities() {
    activities.sort((a,b) => a.name.compareTo(b.name));
  }

  void alert(BuildContext context, String info) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: Text(info),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('K'))
            ],
          );
        });
  }
}
