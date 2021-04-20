import 'package:flutter/material.dart';

import '../routes.dart';

class InstrumentLayout extends StatelessWidget {
  final String _tag;
  final Widget _widget;

  const InstrumentLayout(this._tag, this._widget);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Hero(
        tag: _tag,
        child: Stack(
          children: <Widget>[
            _widget,
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
                          builder: (context) =>
                              Row(children: [InstrumentLayout(_tag, _widget)])),
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
