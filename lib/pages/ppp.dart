import 'package:flutter/material.dart';

class PppPage extends StatefulWidget {
  @override
  _PppPageState createState() => _PppPageState();
}

class _PppPageState extends State<PppPage> {

  @override
  void initState() {
    print('ppp initState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('ppp build');
    return Center(
      child: Text('Ppp'),
    );
  }

  @override
  void deactivate() {
    print('ppp deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('ppp dispose');
    super.dispose();
  }
}
