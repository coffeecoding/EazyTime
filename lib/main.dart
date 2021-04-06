import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_eazytime/help_page.dart';
import 'package:flutter_eazytime/styles.dart';
import 'styles.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

void main() {
  runApp(EazyTime());
}

class EazyTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyTimetracker',
      theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: PrimaryTextStyle(Colors.black),
            bodyText2: NormalTextStyle(Colors.black),
            caption: ButtonTextStyle(Colors.black),
            headline1: SmallTextStyle(Colors.black),
            headline2: SecondaryTextStyle(Colors.black),
            headline3: SmallSpacedTextStyle(Colors.black),
            headline4: LegendTextStyle(Colors.black),
            headline5: NormalTextStyleBold(Colors.black)
          ),
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          secondaryHeaderColor: Colors.black,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          accentColor: Colors.blue,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.grey.withOpacity(0.2)),
      darkTheme: ThemeData(
          textTheme: TextTheme(
            bodyText1: PrimaryTextStyle(Colors.white),
            bodyText2: NormalTextStyle(Colors.white),
            caption: ButtonTextStyle(Colors.white),
            headline1: SmallTextStyle(Colors.white),
            headline2: SecondaryTextStyle(Colors.white),
            headline3: SmallSpacedTextStyle(Colors.white),
            headline4: LegendTextStyle(Colors.white),
            headline5: NormalTextStyleBold(Colors.white)
          ),
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          secondaryHeaderColor: Colors.white,
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          accentColor: Colors.blue,
          accentIconTheme: IconThemeData(color: Colors.yellow),
          dividerColor: Colors.grey.withOpacity(0.33)),
      themeMode: ThemeMode.system,
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

enum DisplayedPage { home, history, allTimeStats, help, about, preferences }

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState() : currentPage = DisplayedPage.home;

  DisplayedPage currentPage;

  @override
  Widget build(BuildContext context) {
    Widget? _body;
    String _title = 'Today';
    switch (currentPage) {
      case DisplayedPage.home:
        {
          _title = 'Today';
          _body = HomePage();
          break;
        }
      case DisplayedPage.history:
        {
          _title = 'History';
          _body = HistoryPage();
          break;
        }
      case DisplayedPage.allTimeStats:
        {
          _title = 'Statistics';
          _body = StatisticsPage();
          break;
        }
      case DisplayedPage.help:
        {
          _title = 'Help Page';
          _body = HelpPage();
          break;
        }
      case DisplayedPage.about:
        {
          _title = 'About EasyTimetracker';
          break;
        }
      case DisplayedPage.preferences:
        {
          _title = 'Preferences';
          _body = SettingsPage();
          break;
        }
    }
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              title: Text(_title, style: Theme.of(context).textTheme.headline5),
            ),
            drawer: Drawer(
              elevation: 5.0,
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                          Theme.of(context).dividerColor.withOpacity(0.1),
                          Theme.of(context).backgroundColor.withOpacity(0),
                        ],
                            stops: [
                          0.0,
                          1.0
                        ])),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Image.asset('assets/logo_strong.png',
                              height: 80, width: 120, fit: BoxFit.fitHeight),
                        ),
                        Text('EasyTimetracker',
                            style: Theme.of(context).textTheme.caption),
                        Text('Get ahold of your Time!',
                            style: Theme.of(context).textTheme.headline4),
                      ],
                    ),
                  ),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.home ? 0.7 : 0),
                      leading: Icon(currentPage == DisplayedPage.home
                          ? Icons.pie_chart
                          : Icons.pie_chart_outline_sharp),
                      onTap: () {
                        currentPage = DisplayedPage.home;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Today',
                              style: currentPage == DisplayedPage.home
                              ? Theme.of(context).textTheme.headline5
                              : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.history ? 0.7 : 0),
                      leading: Icon(currentPage == DisplayedPage.history
                          ? Icons.bar_chart
                          : Icons.bar_chart_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.history;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('History',
                              style: currentPage == DisplayedPage.history
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.allTimeStats ? 0.7 : 0),
                      leading: Icon(currentPage == DisplayedPage.allTimeStats
                          ? Icons.analytics
                          : Icons.analytics_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.allTimeStats;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Statistics',
                              style: currentPage == DisplayedPage.allTimeStats
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                          currentPage == DisplayedPage.preferences ? 0.7 : 0),
                      leading: Icon(currentPage == DisplayedPage.preferences
                          ? Icons.settings
                          : Icons.settings_outlined),
                      onTap: () {
                        currentPage = DisplayedPage.preferences;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Preferences',
                              style: currentPage == DisplayedPage.preferences
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      tileColor: Theme.of(context).accentColor.withOpacity(
                        currentPage == DisplayedPage.help ? 0.7 : 0),
                      leading: Icon(currentPage == DisplayedPage.help
                          ? Icons.help
                          : Icons.help_outline),
                      onTap: () {
                        currentPage = DisplayedPage.help;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Help',
                              style: currentPage == DisplayedPage.help
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                  ListTile(
                      leading: Icon(currentPage == DisplayedPage.about
                          ? Icons.info
                          : Icons.info_outline),
                      onTap: () {
                        Navigator.pop(context);
                        showAboutDialog(
                          context: context,
                          applicationName: 'EasyTimetracker',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(Icons.art_track),
                          applicationLegalese: 'Made by YousufCodes 2021\n'
                            'www.yousufcodes.com'
                        );
                      },
                      title: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('About',
                              style: currentPage == DisplayedPage.about
                                  ? Theme.of(context).textTheme.headline5
                                  : Theme.of(context).textTheme.bodyText2))),
                  Divider(height: 1.0),
                ],
              ),
            ),
            body: _body));
  }
}

