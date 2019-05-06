import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:logistics/models/blog.dart';
import 'package:logistics/models/user.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/blog_details_carousel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;



class BlogDetailsPage extends StatefulWidget {

  final MainModel model;

  BlogDetailsPage(this.model);

  @override
  _BlogDetailsPageState createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _addCommentTextController = TextEditingController();
//  final _addReplyTextController = TextEditingController();

//  final _replyFocusNode = FocusNode();
  final _commentFocusNode = FocusNode();

  int _commentId;
  bool _isCommenting = false;

  @override
  void initState() {

    widget.model.commentPageToOne();

    widget.model.getBlogDetails(id: widget.model.blogId).then((response){
//      _bloc.addUser(model);
      widget.model.getCommentList(blogId: widget.model.blogId).then((response){

      }).catchError((error){
        print('error is $error');
      });
    }).catchError((error){
      print('error is $error');
    });

//    _commentFocusNode.addListener((){
//      print('listem');
//      if(_commentId != null){
//        print('node ${_commentId.toString()}');
//        FocusScope.of(context).requestFocus(_replyFocusNode);
//      }
//    });
//
    _commentFocusNode.addListener((){
      print('replsdafsda');
      if(!_commentFocusNode.hasFocus && _addCommentTextController.text.isEmpty){
        if (!this.mounted) return;
        setState(() {
          _isCommenting = false;
          _commentId = null;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print('blog detaisl build');

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return Scaffold(

          appBar: AppBar(
            title: model.hasData ? Container() : Text(model.blog.title),
            centerTitle: true,
          ),
          body: model.hasData ? Center(child: CircularProgressIndicator(),) : GestureDetector(
            onTap: (){
              Future.delayed(Duration(milliseconds: 100)).then((_) {
                FocusScope.of(context).requestFocus(FocusNode());
              });
            },
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      model.hasData ? Container() : (model.blog.imagesNormalUrl.isEmpty ? Container() : BlogDetailsCarousel(model.blog.imagesNormalUrl)),
                      Form(
                        key: _formKey,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: padding - 10, vertical: 7),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Html(
                                  useRichText: true,
                                  defaultTextStyle: TextStyle(fontSize: 17, color: Colors.black),
                                  data: model.blog.content,
                                  onLinkTap: (url){
                                    print("Opening $url...");
                                    _launchURL(url);
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(_parseDate(model.blog.date), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                child: Text('Комментарии  ${model.blog.numberOfComments}', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
//                                decoration: BoxDecoration(
//                                  border: Border(
//                                    bottom: BorderSide(color: Colors.grey, width: 1)
//                                  )
//                                ),
                                child: FlatButton(
                                  onPressed: (){
                                    Future.delayed(Duration(milliseconds: 100)).then((_) {
                                      FocusScope.of(context).requestFocus(_commentFocusNode);
                                    });

                                    setState(() {
                                      _isCommenting = true;
                                    });
                                  },
                                  child: Text('Добавить комментарий', style: TextStyle(fontSize: 18,),),
                                ),
                              ),
                              Column(
                                children: _commentWidgets(model.comments, model),
                              ),
                              !model.incompleteResultsComments
                                ? Container()
                                : model.hasComment
                                  ? Center(child: CircularProgressIndicator(),)
                                  : RaisedButton(
                                      key: GlobalKey(),
                                      onPressed: (){
                                        _fetchComments(model);
                                      },
                                      child: Text('bute'),
                                    )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                !_isCommenting ? Container() : _buildAddCommentTextField(model),
              ],
            ),
          ),
        );
      },
    );
  }


  void _fetchComments(MainModel model){
    print('fetchingdgsd');

    if(model.incompleteResultsComments){
      model.increaseCommentPage();

      model.getCommentList(blogId: widget.model.blogId, hasAdded: true).then((response){
        print('fetch blogist');

      }).catchError((){
      });
    }
  }


  String _parseDate(String date){

    timeago.setLocaleMessages('ru', timeago.RuMessages());
    DateTime parsedDate = DateTime.parse(date);

    return timeago.format(parsedDate, locale: 'ru');
  }


  

  void _commentsModalBottomSheet(context){

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.music_note),
                    title: Text('Music'),
                    onTap: () => {}
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Video'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        }
    );
  }

  List<Widget> _commentWidgets(List<Comment> comments, MainModel model){

    List<Widget> widgets = [];

    if(comments.isEmpty){
      widgets.add(Container());
      return widgets;
    }

    else{
      comments.forEach((Comment comment){

        List<Widget> replyWidgets = [];

//        if(comment.id == _commentId){
//          replyWidgets.add(_buildAddReplyTextField(model));
//        }

        if(comment.replies.isNotEmpty){

          comment.replies.forEach((reply){
//            replyWidgets.add(Container(child: Text('${reply.id}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.content}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.date}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.canRemove}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.canReply}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.userShort.id}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.userShort.firstName}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.userShort.lastName}'), margin: EdgeInsets.only(left: 20),));
//            replyWidgets.add(Container(child: Text('${reply.userShort.imageThumbUrl}'), margin: EdgeInsets.only(left: 20),));
            replyWidgets.add(_buildComment(model, reply, true));
          });
        }

//        widgets.add(Text('${comment.id}'));
//        widgets.add(Text('${comment.content}'));
//        widgets.add(Text('${comment.date}'));
//        widgets.add(Text('${comment.canRemove}'));
//        widgets.add(Text('${comment.canReply}'));
//        widgets.add(Text('${comment.userShort.id}'));
//        widgets.add(Text('${comment.userShort.firstName}'));
//        widgets.add(Text('${comment.userShort.lastName}'));
//        widgets.add(Text('${comment.userShort.imageThumbUrl}'));
        widgets.add(_buildComment(model, comment, false));
        widgets.addAll(replyWidgets);

      });


      return widgets;
    }
  }


  Widget _buildAddCommentTextField(MainModel model){

    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: TextFormField(
        focusNode: _commentFocusNode,
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Оставьте комментарий',
          filled: true,
          fillColor: Colors.white,
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
              if(_addCommentTextController.text.trim().isNotEmpty){
                _onAddComment(model: model, blogId: model.blog.id, replyId: _commentId, content: _addCommentTextController.text, isReplying: _commentId == null ? false : true);
              }

            },
            child: Icon(Icons.send),
          ),

        ),
        keyboardType: TextInputType.multiline,
        controller: _addCommentTextController,

      ),
    );
  }



  // Todo add reply text field
//  Widget _buildAddReplyTextField(MainModel model){
//
//    return Row(
//      children: <Widget>[
//        Expanded(
//          child: TextFormField(
////            focusNode: _replyFocusNode,
//            autofocus: true,
//            decoration: InputDecoration(
//              labelText: 'Оставьте комментарий',
//              filled: true,
//              fillColor: Colors.transparent,
//              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
//              border: OutlineInputBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(5)),
//                  borderSide: BorderSide(
//                      color: Colors.grey,
//                      width: 1
//                  )
//              ),
//              suffixIcon: GestureDetector(
//                onTap: (){
//                  if(_addReplyTextController.text.trim().isNotEmpty){
//                    _onAddComment(model: model, blogId: model.blog.id, replyId: _commentId, content: _addCommentTextController.text, isReplying: true);
//                  }
//                },
//                child: Icon(Icons.send),
//              ),
//
//            ),
//            keyboardType: TextInputType.multiline,
//            controller: _addReplyTextController,
//          ),
//        ),
//        GestureDetector(
//          onTap: (){
//            setState(() {
//              _commentId = null;
//            });
//          },
//          child: Icon(Icons.close),
//        )
//      ],
//    );
//
//  }


  void _onAddComment({MainModel model, int blogId, int replyId, String content, bool isReplying}) async{

    _formKey.currentState.save();

    await model.addComment(blogId: blogId, replyId: replyId, content: content).then((response){
      print('response comment $response}');
      if(response['status'] == 'success'){

        Future.delayed(Duration(milliseconds: 100)).then((_) {
          FocusScope.of(context).requestFocus(FocusNode());
        });

//        model.increaseComment();

        final Comment comment = Comment(
          id: response['id'],
          content: _addCommentTextController.text,
          userShort: UserShort(firstName: model.profile.firstName, lastName: model.profile.lastName, imageThumbUrl: model.profile.imageData.thumb),
          date: DateTime.now().toString(),
          canReply: !isReplying,
          replies: [],
          canRemove: true,
        );
        _addCommentTextController.text = '';

        if(!isReplying){
          model.insertToComments(comment);
        }
        else{
          model.insertToReplies(comment, replyId);
        }
        print('comments ${model.comments}');
        if (!this.mounted) return;
        setState(() {
          _isCommenting = false;
          _commentId = null;
        });

      }
      else{

      }
    }).catchError((error){
      print(error);
    });
  }


  Widget _buildComment(MainModel model, Comment comment, bool isReplied){

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isReplied ? SizedBox(width: 15,) : Container(),
          Expanded(
            flex: 1,
            child: Container(
//              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(7),
              child: CircleAvatar(
                radius: 23.5,
                backgroundImage: NetworkImage(comment.userShort.imageThumbUrl),
                backgroundColor: Colors.transparent,
              ),
            ),
//            child: Container(
//              margin: EdgeInsets.all(7),
//              child: Image.network(comment.userShort.imageThumbUrl, ),
//            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('${comment.userShort.firstName} ${comment.userShort.lastName}'),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(comment.content),
                ),

                SizedBox(height: 7,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_parseDate(comment.date)),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Future.delayed(Duration(milliseconds: 100)).then((_) {
                              FocusScope.of(context).requestFocus(_commentFocusNode);
                            });

                            setState(() {
                              _isCommenting = true;
                              _commentId = comment.id;
                            });
//                            if(_commentFocusNode.hasFocus){
//                              FocusScope.of(context).requestFocus(_replyFocusNode);
//                            }
                          },
                          child: comment.canReply
                              ? Container(
                                  margin: EdgeInsets.all(3),
                                  child: Icon(Icons.reply),
                                )
                              : Container(),
                        ),
                        GestureDetector(
                          onTap: (){
                            model.deleteComment(id: comment.id).then((response){
                              if(response['status'] == 'success'){
//                                model.decreaseComment();
                                model.removeComment(comment.id);
                              }
                              else{

                              }
                            }).catchError((error){
                              print(error);
                            });
                          },
                          child: comment.canRemove
                              ? Container(
                                  margin: EdgeInsets.all(3),
                                  child: Icon(Icons.close),
                                )
                              : Container(),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  void dispose() {
    _commentFocusNode.dispose();
//    _replyFocusNode.dispose();
    widget.model.clearComments();

    super.dispose();
  }
}
