import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('How to use', style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.start),
            ),
            Text('This is an elaborate description in extreme detail of what this application is supposed to be used for and how exactly one goes about using it. Basically it is an app that should give the user a visual impression of where their time goes each day. This may help the user rationalise their time usage and cut out time-wasters from their daily routines. Needless to say, the benefit is only as good as the effort put up into using this app properly. Luckily, the app is designed to be as easy to use as possible and require as little time as possible. So let\'s take a look at how to use it using an example.',
                style: Theme.of(context).textTheme.bodyText2),
          ]
      ),
    );
  }
}
