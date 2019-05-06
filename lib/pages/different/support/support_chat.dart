import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:logistics/helpers/load_more.dart';
import 'package:scoped_model/scoped_model.dart';

class SupportChatPage extends StatefulWidget {

  final MainModel model;

  SupportChatPage({Key key, @required this.model}) : super(key: key);

  @override
  _SupportChatPageState createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {

//  RefreshController _controller;
  final _sendingTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {

    print('support chat init');

//    _controller = RefreshController();

    widget.model.supportChatPageToOne();
    widget.model.getSupportChat(widget.model.supportData['id']).then((response){
      print('init getsupportchat');
//      _bloc.addUser(model);
      print(response);
    }).catchError((error){
      print('error is $error');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('here');

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){

        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('${model.supportData['title']}'),
            ),
//            body: model.supportData['type']
//                ? _buildBody(model: model)
//                : Form(
//              key: _formKey,
//              child: Column(
//                children: <Widget>[
//                  Expanded(child: _buildBody(model: model)),
//                  _buildInput()
//                ],
//              ),
//            )
          body: _buildBody(model: model),

        );
      },
    );
  }


  Widget _buildBody({MainModel model}){

//    print('length ${model.supportChatList.length}');

    return Container(
      child: LoadMore(
        isFinish: !model.supportChatIncompleteResults,
        onLoadMore: _fetch,
        delegate: DefaultLoadMoreDelegate(),
        textBuilder: DefaultLoadMoreTextBuilder.english,
        child: ListView.builder(
//          reverse: true,
          itemBuilder: (BuildContext context, int position){

//              Widget content;
//
//              // Todo isLoading! ProgressBar
//              if(model.supportChatList.length == 0){
//
//
//                content = Center(
//                  child: Text('blog not found'),
//                );
//              }
//
//              else if(model.supportChatList.length > 0){
//
//                content =
//              }

            return Container(
              margin: EdgeInsets.all(10),
              color: Colors.grey,
              child: ListTile(
                  title: Text(model.supportChatList[position].userShort.firstName),
                  subtitle: Text(model.supportChatList[position].content)
              ),
            );
          },
          itemCount: model.supportChatList.length,
        ),
      ),
    );
  }


//  Widget _buildBody({MainModel model}){
//
//    return SmartRefresher(
//
//      enableOverScroll: true,
//      // Todo update data by pull down
//      enablePullDown: false,
//      enablePullUp: true,
//      controller: _controller,
//      footerBuilder: _footerCreate,
//      reverse: true,
//      onRefresh: (bool up){
//        print('refreshsing');
//        return _onRefresh(up, model);
//      },
//      child: ListView.builder(
////          controller: _scrollController,
////                shrinkWrap: true,
//        itemBuilder: (BuildContext context, int position){
//
//          Widget content;
//
//          // Todo isLoading! ProgressBar
//          if(model.supportChatList.length == 0){
//
//
//            content = Center(
//              child: Text('blog not found'),
//            );
//          }
//
//          else if(model.supportChatList.length > 0){
//
//            content = Container(
//              margin: EdgeInsets.all(10),
//              color: Colors.grey,
//              child: ListTile(
//                  title: Text(model.supportChatList[position].userShort.firstName),
//                  subtitle: Text(model.supportChatList[position].content)
//              ),
//            );
//          }
//
//          return content;
//        },
//        itemCount: model.supportChatList.length,
//      ),
//    );
//  }


//  Widget _buildStreamBody(MainModel model){
//    return StreamBuilder(
//      stream: widget.channel.stream,
//      builder: (context, snapshot){
//        if(snapshot.hasData){
//          print('snapshotData ${snapshot.data}');
//        }
//        return _buildBody(model: model, snapshot: snapshot);
//      },
//    );
//  }


  Widget _buildInput(){
    return Container(
      margin: EdgeInsets.all(5),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'fdsdfdsfs',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(
                color: Colors.grey,
                width: 1
            )
          ),
          suffixIcon: GestureDetector(
            onTap: (){
              if(_sendingTextController.text.trim().isNotEmpty){
                _onAddMessage();
              }
            },
            child: Icon(Icons.send),
          ),

        ),
        keyboardType: TextInputType.multiline,
        controller: _sendingTextController,
      )
    );
  }


  void _onAddMessage(){

    print('sending message');

    if(_sendingTextController.text.trim().isNotEmpty){
      final Map<String, dynamic> data = {
        'action': 'addMessage',
        'supportId': widget.model.supportData['id'],
        'content': _sendingTextController.text,
        'tempId': _randomString(6),
      };
      print('data ${data.toString()}');
//      widget.channel.sink.add(data.toString());
    }
  }


  String _randomString(int length) {

    var rand = new Random();
    var codeUnits = new List.generate(length, (index){
          return rand.nextInt(33)+89;
        }
    );
    return new String.fromCharCodes(codeUnits);
  }


//  Widget _footerCreate(BuildContext context, int mode){
//
//    return ClassicIndicator(
//
//      releaseText: 'Тяните',
//      mode: mode,
//      refreshingText: '',
//      idleIcon: Container(),
//      idleText: (!widget.model.supportChatIncompleteResults) ? '' : 'Загрузить еще...',
//      completeIcon: Container(),
//      completeText: '',
//
//    );
//  }


  Future<bool> _fetch() async {
    print('fetchingdgsd');
    widget.model.increaseSupportChatPage();

    widget.model.getSupportChat(widget.model.supportData['id']).then((response){
      print('fetch blogist');
//      _controller.sendBack(false, RefreshStatus.idle);

    }).catchError((){
//      _controller.sendBack(false, RefreshStatus.failed);
    });
    return true;

  }



//  void _onRefresh(bool up, MainModel model){
//
//    print('refresh');
//    if(!model.supportChatIncompleteResults){
//      _controller.sendBack(false, RefreshStatus.idle);
//    }
//    if(!up && model.supportChatIncompleteResults){
//      _fetch(model);
//      print('offset ${_controller.scrollController.offset}');
//
//    }
//  }

  @override
  void dispose() {
    widget.model.removeSupportChat();
//    if(widget.channel != null){
//      widget.channel.sink.close();
//    }
    super.dispose();
  }
}
