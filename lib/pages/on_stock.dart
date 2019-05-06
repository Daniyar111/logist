import 'package:flutter/material.dart';

class OnStockPage extends StatefulWidget {
  @override
  _OnStockPageState createState() => _OnStockPageState();
}

class _OnStockPageState extends State<OnStockPage> {

  @override
  void initState() {
    print('onstock initState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('onstock build');
    return Center(
      child: Text('On Stock'),
    );
  }

  @override
  void deactivate() {
    print('onstock deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('onstock dispose');
    super.dispose();
  }
}
