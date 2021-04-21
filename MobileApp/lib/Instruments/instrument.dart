import 'package:flutter/material.dart';

import '../routes.dart';

class InstrumentLayout extends StatelessWidget {
  final String tag;
  final Widget child;

  const InstrumentLayout({this.tag, this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Hero(
        tag: tag,
        child: Stack(
          children: <Widget>[
            child,
            Material(
              child: IconButton(
                icon: Icon(Icons.expand),
                tooltip: 'Expand',
                onPressed: () {
                  if (ModalRoute.of(context)?.settings?.name ==
                      Routes.cockpit) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Row(children: [
                                InstrumentLayout(tag: tag, child: child)
                              ])),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
