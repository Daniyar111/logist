import 'package:flutter/material.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';

class ClosedSupportTab extends StatefulWidget {

  final MainModel model;

  ClosedSupportTab({Key key, this.model}) : super(key: key);

  @override
  _ClosedSupportTabState createState() => _ClosedSupportTabState();
}

class _ClosedSupportTabState extends State<ClosedSupportTab> with AutomaticKeepAliveClientMixin<ClosedSupportTab> {

  RefreshController _controller;

  @override
  void initState() {

    _controller = RefreshController();



    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;


    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){

        return Scaffold(
          body: SmartRefresher(
            enableOverScroll: true,
            // Todo update data by pull down
            enablePullDown: false,
            enablePullUp: true,
            controller: _controller,
            onRefresh: (bool up){
              print('refreshsing');
              return _onRefresh(up, model);
            },
            footerBuilder: _footerCreate,
            footerConfig: RefreshConfig(
                visibleRange: 10
            ),
            child: ListView.builder(
//          controller: _scrollController,
              itemBuilder: (BuildContext context, int position){

                Widget content;

                // Todo isLoading! ProgressBar
                if(model.closedSupportList.length == 0){


                  content = Center(
                    child: Text('blog not found'),
                  );
                }

                else if(model.closedSupportList.length > 0){

                  content = ListTile(
                    onTap: (){
                      model.selectSupportId(model.closedSupportList[position].id, model.closedSupportList[position].title, model.closedSupportList[position].isClosed);
                      Navigator.of(context, rootNavigator: true).pushNamed('/support_chat');
                    },
                    title: Text(model.closedSupportList[position].title),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Закрыто'),
                        Text(model.closedSupportList[position].date)
                      ],
                    ),
                  );
                }

                return content;
              },
              itemCount: model.closedSupportList.length,
            ),
          )
        );
      },
    );
  }


  Widget _footerCreate(BuildContext context, int mode){

    return ClassicIndicator(

      releaseText: 'Тяните',
      mode: mode,
      refreshingText: '',
      idleIcon: Container(),
      idleText: (!widget.model.closedSupportIncompleteResults) ? '' : 'Загрузить еще...',
      completeIcon: Container(),
      completeText: '',

    );
  }


  void _fetch(MainModel model){
    print('fetchingdgsd');
    model.increaseClosedSupportPagePage();

    model.getSupportList(2).then((response){
      print('fetch blogist');
      _controller.sendBack(false, RefreshStatus.idle);

    }).catchError((){
      _controller.sendBack(false, RefreshStatus.failed);
    });
  }

  void _onRefresh(bool up, MainModel model){

    print('refresh');
    if(!model.closedSupportIncompleteResults){
      _controller.sendBack(false, RefreshStatus.idle);
    }
    if(!up && model.closedSupportIncompleteResults){
      _fetch(model);
      print('offset ${_controller.scrollController.offset}');

    }
  }

  @override
  void dispose() {


    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

