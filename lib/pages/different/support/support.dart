import 'package:flutter/material.dart';
import 'package:logistics/pages/different/support/active.dart';
import 'package:logistics/pages/different/support/closed.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SupportPage extends StatefulWidget {

  final MainModel model;

  SupportPage(this.model);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  @override
  void initState() {

    widget.model.activeSupportPageToOne();
    widget.model.getSupportList(1).then((response){
      print('init getactivesupportList');
//      _bloc.addUser(model);
      print(response);
    }).catchError((error){
      print('error is $error');
    });

    widget.model.closedSupportPageToOne();
    widget.model.getSupportList(2).then((response){
      print('init getsupportList');
//      _bloc.addUser(model);
      print(response);
    }).catchError((error){
      print('error is $error');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: 'Активные',),
              Tab(text: 'Завершенные',),
            ],
            indicatorColor: Colors.white,
          ),
          title: Text('Поддержка пользователей'),
          centerTitle: true,
        ),
        body: TabBarView(
          children: <Widget>[
            ActiveSupportTab(model: widget.model, key: PageStorageKey<String>('active'),),
            ClosedSupportTab(model: widget.model, key: PageStorageKey<String>('closed'),)
          ],
        )
      ),
    );
  }

  @override
  void dispose() {

    widget.model.removeActiveSupportList();
    widget.model.removeClosedSupportList();
    super.dispose();
  }
}

