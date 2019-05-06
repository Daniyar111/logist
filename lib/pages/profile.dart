import 'package:flutter/material.dart';
import 'package:logistics/helpers/custom_envelope.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistics/models/user_model.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/blog_card.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {

  final MainModel model;

  ProfilePage(this.model);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  RefreshController _controller;

//  bool _rebuildOnChange = true;
//
//  callBack(_isRebuild){
//    setState(() {
//      _rebuildOnChange = _isRebuild;
//    });
//  }

//  ScrollController _scrollController;
//
//  _scrollListener(){
//
//    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange && widget.model.incompleteResults) {
//      widget.model.increasePage();
//      widget.model.getBlogList().then((response){
////      _bloc.addUser(model);
////        _scrollController.jumpTo(widget.model.offset);
//        print(response);
//      }).catchError((error){
//        print('error is $error');
//      });
//    }
//  }

  void _fetch(MainModel model){
    print('fetchingdgsd');
    model.increasePage();

    model.getBlogList().then((response){
      print('fetch blogist');
      _controller.sendBack(false, RefreshStatus.idle);

    }).catchError((){
      _controller.sendBack(false, RefreshStatus.failed);
    });
  }

  void _onRefresh(bool up, MainModel model){

    print('refresh');
    if(!model.incompleteResults){
      _controller.sendBack(false, RefreshStatus.idle);
    }
    if(!up && model.incompleteResults){
      _fetch(model);
      print('offset ${_controller.scrollController.offset}');

    }
  }


  @override
  void initState() {

    print('profile initState');

    _controller = RefreshController();
//    _scrollController = ScrollController();
//    _scrollController.addListener(_scrollListener);
//    _controller.scrollTo(20);

    widget.model.pageToOne();
    widget.model.getBlogList().then((response){
      print('init getbloglist');
//      _bloc.addUser(model);
      print(response);
    }).catchError((error){
      print('error is $error');
    });
//    if(mounted && widget.model.isBlogToOffset) {
//      Future.delayed(const Duration(), () {
//        _controller.scrollTo(widget.model.offset);
////        _controller.animateTo(widget.model.offset, curve: Curves.linear, duration: Duration (milliseconds: 500));
//      });
//    }

    super.initState();
  }

  Widget _footerCreate(BuildContext context, int mode){

    return ClassicIndicator(

      releaseText: 'Тяните',
      mode: mode,
      refreshingText: '',
      idleIcon: Container(),
      idleText: (!widget.model.incompleteResults) ? '' : 'Загрузить еще...',
      completeIcon: Container(),
      completeText: '',

    );
  }

  @override
  Widget build(BuildContext context) {
    print('profile build');
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;

//    print(_rebuildOnChange);
    Widget envelopeCard = Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Card(
              margin: EdgeInsets.only(top: 15, left: padding, right: padding),
              elevation: 3,
              child: Container(
                height: 200,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, left: padding, right: padding),
              height: 7,
              width: targetWidth,
              child: Image.asset('assets/envelope_small.png', repeat: ImageRepeat.repeatX,),
            )
          ],
        ),
        SizedBox(height: 10,),
      ],
    );


    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){

//        model.getUserModelFromDB();

        return Scaffold(
          appBar: AppBar(

//            title: Center(
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    model.isLoading ? Text('', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)) : Text('${model.profile.firstName} ${model.profile.lastName}', style: TextStyle(color: Colors.white,  fontSize: 18, fontWeight: FontWeight.w500),),
//                    Text('Баланс \$0', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),),
//                  ],
//                )
//            ),
            title: model.isLoading ? Text('') : Text('${model.profile.firstName} ${model.profile.lastName}'),
            elevation: 0,
            centerTitle: true,
          ),
          body: Stack(

            children: <Widget>[
              Container(
                height: 100,
                color: Theme.of(context).primaryColor,
              ),
              SmartRefresher(
//          enableOverScroll: true,
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
                    if(position == 0){
                      return envelopeCard;
                    }

                    else{

                      Widget content;

                      if(model.blogList.length == 0 && !model.isLoading){

                        content = Center(
                          child: Text('blog not found'),
                        );
                      }

                      else if(model.blogList.length > 0 && !model.isLoading){

                        content = BlogCard(model.blogList[position - 1], padding, /*callBack*/);
                      }

                      return content;
                    }
                  },
                  itemCount: model.blogList.length + 1,
                ),
              )
            ],
          ),
        );
      },
    );
  }


  @override
  void deactivate() {
    print('profile deactivate');
//    widget.model.saveScrollPosition(_controller.scrollController.offset);
//    widget.model.blogToOffset(true);\


    super.deactivate();
  }


  @override
  void dispose() {
    print('profile dispose');

//    _controller.dispose();

//    print('offffff ${_controller.scrollController.offset}');
//    _scrollController.dispose();

    super.dispose();
  }

}
