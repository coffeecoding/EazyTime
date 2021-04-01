import 'package:flutter/material.dart';
import 'storage_manager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool _showStartTime = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    _showStartTime = await StorageManager.readData(SMKey.showStartTimes.toString());
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          SwitchListTile(
              controlAffinity: ListTileControlAffinity.trailing,
              title: Text('Show start times in pie chart', style:
              Theme.of(context).textTheme.bodyText2),
              value: _showStartTime,
              activeColor: Theme.of(context).accentColor,
              onChanged: (newVal) {
                _showStartTime = newVal;
                StorageManager.saveData(SMKey.showStartTimes.toString(),
                    newVal);
                setState(() {
                });
              }),
          Divider(height: 1.0),
        ]
    );
  }
}