import 'package:flutter/material.dart';

import '../routes.dart';

class ExpendableIntrument extends StatelessWidget {
  final String _tag;
  final LayoutBuilder _lb;

  const ExpendableIntrument(this._tag, this._lb);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Hero(
        tag: _tag,
        child: Stack(
          children: <Widget>[
            _lb,
            Material(
              child: IconButton(
                icon: Icon(Icons.expand),
                tooltip: 'Expand',
                onPressed: () {
                  if (ModalRoute.of(context)?.settings?.name ==
                      Routes.cockpit) {
                    Navigator.pushNamed(context, Routes.paintedGauge);
                  } else {
                    Navigator.pushNamed(context, Routes.cockpit);
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
