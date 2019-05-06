import 'package:flutter/material.dart';

class SendPage extends StatefulWidget {

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {

  @override
  void initState() {
    print('sendpage initState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('sendpage build');
    return Center(
      child: Text('Send'),
    );
  }

  @override
  void deactivate() {
    print('sendpage deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('sendpage dispose');
    super.dispose();
  }
}
