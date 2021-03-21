import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eazytime/activity.dart';
import 'package:flutter_eazytime/styles.dart';
import 'data_access.dart';
import 'data_access.dart';
import 'data_access.dart';
import 'styles.dart';
import 'styles.dart';
import 'styles.dart';

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
  Activity? cachedActivity; // used for modifying

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
                            Flexible(child: Container(
                              alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 8.0),
                                color: ColorSpec.myRed,
                              child: Text('Delete', style: NormalTextStyle()))),
                        secondaryBackground:
                            Flexible(child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 8.0),
                                color: ColorSpec.myGreen,
                                child: Text('Modify', style: NormalTextStyle()))),
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
    if (dir == DismissDirection.startToEnd) {
      Activity activityToDel = activities.elementAt(i);
      await DBClient.instance.deleteActivity(activityToDel);
      //activities.removeAt(i);
      activities = await DBClient.instance.getActiveActivities();
      setState(() { });
    } else if (dir == DismissDirection.endToStart) {
      // modify item
      cachedActivity = activities.removeAt(i);
      _textController.text = cachedActivity!.name;
      _textFocusNode.requestFocus();
    }
  }

  void _handleAdd(String text) async {
    if (text.isEmpty)
      return;
    if (activities.any((act) => act.name == text)) {
      alert(context, 'Activity \'$text\' already exists.');
      return;
    }

    // First check if activity with this name exists in the list
    bool existsActive = cachedActivity != null;
    int count = await DBClient.instance.getActiveActivityCount();
    int nextColor = ColorSpec.colorCircle[count % ColorSpec.colorCircle.length].value;

    // If it exists and isActive == 0, set isActive to 1 and update its color
    if (existsActive) {
      // Update activity with the new name and update the color
      cachedActivity!.name = text;
      cachedActivity!.color = nextColor;
      await DBClient.instance.updateActivity(cachedActivity!);
      Activity updatedActivity = await DBClient.instance.getActivityById(cachedActivity!.id!);
      activities.add(updatedActivity);
      cachedActivity = null;
    }
    // Else, it doesn't exist locally, check if its inactive, otherwise add new
    else {
      // Check if it exists in database and is inactive
      Activity? existingInactive = await DBClient.instance.existsActivityWithName(text);
      if (existingInactive != null) {
        existingInactive.isActive = 1;
        existingInactive.color = nextColor;
        await DBClient.instance.updateActivity(existingInactive);
        existingInactive = await DBClient.instance.getActivityByName(text);
        activities.add(existingInactive!);
      }
      // Else it doesn't even exist as inactive, so add a new one
      else {
        Activity newActivity = Activity(text, nextColor);
        int newId = await DBClient.instance.insertActivity(newActivity);
        newActivity = await DBClient.instance.getActivityById(newId);
        activities.add(newActivity);
      }
    }

    // Update TextInput
    _textController.clear();
    _isComposing = false;
    _textFocusNode.requestFocus();
    setState(() {});
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
