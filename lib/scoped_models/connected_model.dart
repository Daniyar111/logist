import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logistics/models/blog.dart';
import 'package:logistics/models/calc.dart';
import 'package:logistics/models/profile.dart';
import 'package:logistics/models/support.dart';
import 'package:logistics/models/user.dart';
import 'package:logistics/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../models/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

mixin ConnectedModel on Model{

  CalcData _calcData;
  User _authenticatedUser;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSign = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  Profile _profile;
  bool _isUserChanged = false;

  final String baseUrl = 'https://t-express.progeek.io/api/';
  final String wsUrl = 'ws://192.168.0.103:8443';

}


mixin CalculatorModel on ConnectedModel{

  bool _isCalcLoading = false;

  bool get isCalcLoading{
    return _isCalcLoading;
  }

  CalcData get calcData{
    return _calcData;
  }

  void removeCalcData(){
    _calcData = null;
  }


  Future<Map<String, dynamic>> postCalculatorData(double weight, double length, double width, double height, String weightType, String volumeType) async {

    _isCalcLoading = true;
    notifyListeners();

    final Map<String, dynamic> calcData = {
      'weight': weight,
      'length': length,
      'width': width,
      'height': height,
      'weightType': weightType,
      'volumeType': volumeType
    };

    http.Response response = await http.post(
      '${baseUrl}calculator',
      headers:{
        'Content-Type': 'application/json'
      },
      body: json.encode(calcData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    _calcData = CalcData(
      status: responseData['status'],
      message: responseData['message'],
      value: responseData['data'] == null ? null : responseData['data']['value'],
      sign: responseData['data'] == null ? null : responseData['data']['sign']
    );
    print('response data $responseData');
    _isCalcLoading = false;


    notifyListeners();

    return responseData;
  }
}


mixin BlogModel on ConnectedModel{

  int _page = 1;
  int _commentPage = 1;
  List<BlogList> _blogList = [];
  bool _incompleteResults = true;
  bool _incompleteResultsComments = true;
  Blog _blog;
  int _blogId;
  List<Comment> _comments = [];
  bool _hasData = false;
  bool _isCommenting = false;

  bool _hasComment = false;


  bool get hasData{
    return _hasData;
  }

  bool get hasComment{
    return _hasComment;
  }


  bool get isCommenting{
    return _isCommenting;
  }

  Blog get blog{
    return _blog;
  }


  List<BlogList> get blogList {
    print(_blogList.length);
    return List.from(_blogList);
  }

  void removeBlogList(){
    _blogList.clear();
  }

  int get page{
    return _page;
  }

  void increasePage(){
    _page++;
  }

  void pageToOne(){
    _page = 1;
  }


  int get commentPage{
    return _commentPage;
  }

  void increaseCommentPage(){
    _commentPage++;
  }

  void commentPageToOne(){
    _commentPage = 1;
  }


  bool get incompleteResults{
    return _incompleteResults;
  }

  bool get incompleteResultsComments{
    return _incompleteResultsComments;
  }


  List<Comment> get comments{
    print(_comments.length);
    return List.from(_comments);
  }


  void selectBlogId(int blogId){
    _blogId = blogId;
  }

  int get blogId{
    return _blogId;
  }



  // Todo body: page = int, max = int (10 default);
  // Todo status, message, total_count, incomplete_results
  Future<Map<String, dynamic>> getBlogList() async {

//    _isLoading = true;
//    notifyListeners();

    final Map<String, dynamic> blogData = {
      'page': _page
    };


    http.Response response = await http.post(
      '${baseUrl}blog/feed',
      headers: {
        'Bearer': _authenticatedUser.token,
        'Content-Type': 'application/json'
      },
      body: json.encode(blogData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

    final List<BlogList> fetchedBlogList = [];

    if(responseData['status'] == 'success'){

      _incompleteResults = responseData['incomplete_results'];

      if(responseData['data'] == []){

        // Todo return empty list
        print('blogs null');
//        _isLoading = false;
//        notifyListeners();
      }



      else{
        print('oneeer');
        print('responsssssssssssss ${(responseData['data'] as List).length}');


        responseData['data'].forEach((data){
          final BlogList blogList = BlogList(
              id: data['id'],
              title: data['title'],
              context: data['context'],
              date: data['createdAt']['date'],
              imageNormalUrl: data['image'] != null ? data['image']['normal'] : null,
              isPinned: data['isPinned'],
              numberOfComments: data['number_of_comments']
          );
//          print('data $data');

          fetchedBlogList.add(blogList);
        });

        _blogList.addAll(fetchedBlogList);
      }
    }


//    _isLoading = false;
//    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message'], 'total_count': responseData['total_count'], 'incomplete_results': responseData['incomplete_results']};
  }


  Future<Map<String, dynamic>> getBlogDetails({int id}) async {

    _hasData = true;
//    _blog = null;
    notifyListeners();

    final Map<String, dynamic> blogData = {
      'id': id
    };


    http.Response response = await http.post(
        '${baseUrl}blog/get',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(blogData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');


    if(responseData['status'] == 'success'){

      if(responseData['data'].isEmpty){

        print('blog null');
        _hasData = false;
        notifyListeners();
      }

      else{
        print('oneeer');

        List<String> images = [];


        responseData['data'][0]['images'].forEach((image){
          String imageUrl = image['normal'];
          images.add(imageUrl);
        });
        final Blog blog = Blog(
          id: responseData['data'][0]['id'],
          title: responseData['data'][0]['title'],
          content: responseData['data'][0]['content'],
          date: responseData['data'][0]['createdAt']['date'],
          imagesNormalUrl: images,
          numberOfComments: responseData['data'][0]['number_of_comments']
        );
        print('rerwrwrwrw');

        _blog = blog;
      }
    }


    _hasData = false;
    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message']};
  }


  void clearComments(){
    _comments.clear();
  }


  // Todo add pagination
  Future<Map<String, dynamic>> getCommentList({int blogId, bool hasAdded = false}) async {

    if(hasAdded){
      _hasComment = true;
    }
    else{
      _hasData = true;
    }

    notifyListeners();



//    if(_comments.isNotEmpty){
//      _comments.clear();
//    }

    final Map<String, dynamic> commentData = {
      'blogId': blogId,
      'page': _commentPage
    };

    http.Response response = await http.post(
        '${baseUrl}blog/comment/list',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },

        body: json.encode(commentData)
    );



    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');


    final List<Comment> fetchedComments = [];

    if(responseData['status'] == 'success'){

      _incompleteResultsComments = responseData['incomplete_results'];

      if(responseData['data'].isEmpty){
        print('comment null');
        _hasData = false;
        notifyListeners();
      }

      else{
        print('oneecvxvxer');


        responseData['data'].forEach((commentData){

          final List<Comment> replies = [];

          (commentData['replies']).forEach((replyData){

            final UserShort userShort = UserShort(
              firstName: replyData['user']['firstName'],
              lastName: replyData['user']['lastName'],
              imageThumbUrl: replyData['user']['logo']['thumb']
            );

            final Comment reply = Comment(
              replies: [],
              id: replyData['id'],
              content: replyData['content'],
              canRemove: replyData['canRemove'],
              canReply: replyData['canReply'],
              date: replyData['createdAt']['date'],
              userShort: userShort
            );
            replies.add(reply);
          });

          final UserShort userShortComment = UserShort(
            firstName: commentData['user']['firstName'],
            lastName: commentData['user']['lastName'],
            imageThumbUrl: commentData['user']['logo']['thumb']
          );

          final Comment comment = Comment(
            id: commentData['id'],
            content: commentData['content'],
            canRemove: commentData['canRemove'],
            date: commentData['createdAt']['date'],
            canReply: commentData['canReply'],
            replies: replies,
            userShort: userShortComment
          );
//          print('data $data');

          fetchedComments.add(comment);
        });
        print(fetchedComments.length.toString());
        _comments.addAll(fetchedComments);
      }
    }


    if(hasAdded){
      _hasComment = false;
    }
    else{
      _hasData = false;
    }
    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message']};
  }


  void insertToComments(Comment comment){
    _comments.insert(0, comment);
    _blog.numberOfComments++;
    notifyListeners();
  }

  void insertToReplies(Comment comment, int id){
    _comments.forEach((com){
      if(id == com.id){
        print('insert');
        com.replies.insert(0, comment);
      }
    });
    _blog.numberOfComments++;
    notifyListeners();
  }

  void removeComment(int id){

    _comments.forEach((comment){
      if(id == comment.id){
        _comments.remove(comment);
        _blog.numberOfComments -= (comment.replies.length + 1);
      }
      else{
        comment.replies.removeWhere((reply){
          if(id == reply.id){
            _blog.numberOfComments--;
          }
        });
      }
    });
    notifyListeners();
  }


  Future<Map<String, dynamic>> addComment({int blogId, int replyId, String content}) async {

//    _isCommenting = true;
//    notifyListeners();

    final Map<String, dynamic> commentData = {
      'blogId': blogId,
      'replyId': replyId,
      'content': content
    };


    http.Response response = await http.post(
        '${baseUrl}blog/comment/add',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(commentData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

//    final List<Comment> fetchedComments = [];
//
//    if(responseData['status'] == 'success'){
//
//      if(responseData['data'].isEmpty){
//
//        print('comment null');
//        _hasData = false;
//        notifyListeners();
//      }
//
//      else{
//        print('oneecvxvxer');
//
//
//        responseData['data'].forEach((commentData){
//
//          final List<Comment> replies = [];
//
//          (commentData['replies']).forEach((replyData){
//
//            final UserShort userShort = UserShort(
//                id: replyData['user']['id'],
//                firstName: replyData['user']['firstName'],
//                lastName: replyData['user']['lastName'],
//                imageThumbUrl: replyData['user']['logo']['thumb']
//            );
//
//            final Comment reply = Comment(
//                id: replyData['id'],
//                content: replyData['content'],
//                canRemove: replyData['canRemove'],
//                canReply: replyData['canReply'],
//                date: replyData['createdAt']['date'],
//                userShort: userShort
//            );
//            replies.add(reply);
//          });
//
//          final UserShort userShortComment = UserShort(
//              id: commentData['user']['id'],
//              firstName: commentData['user']['firstName'],
//              lastName: commentData['user']['lastName'],
//              imageThumbUrl: commentData['user']['logo']['thumb']
//          );
//
//          final Comment comment = Comment(
//              id: commentData['id'],
//              content: commentData['content'],
//              canRemove: commentData['canRemove'],
//              date: commentData['createdAt']['date'],
//              canReply: commentData['canReply'],
//              replies: replies,
//              userShort: userShortComment
//          );
////          print('data $data');
//
//          fetchedComments.add(comment);
//        });
//        print(fetchedComments.length.toString());
//
//        _comments.addAll(fetchedComments);
//      }
//    }


//    _isCommenting = false;
//    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'id': responseData['data']['id'], 'message': responseData['message']};
  }



  Future<Map<String, dynamic>> deleteComment({int id}) async {

//    _isCommenting = true;
//    notifyListeners();


    final Map<String, dynamic> commentData = {
      'id': id,
    };


    http.Response response = await http.post(
        '${baseUrl}blog/comment/delete',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(commentData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

//    final List<Comment> fetchedComments = [];
//
//    if(responseData['status'] == 'success'){
//
//      if(responseData['data'].isEmpty){
//
//        print('comment null');
//        _hasData = false;
//        notifyListeners();
//      }
//
//      else{
//        print('oneecvxvxer');
//
//
//        responseData['data'].forEach((commentData){
//
//          final List<Comment> replies = [];
//
//          (commentData['replies']).forEach((replyData){
//
//            final UserShort userShort = UserShort(
//                id: replyData['user']['id'],
//                firstName: replyData['user']['firstName'],
//                lastName: replyData['user']['lastName'],
//                imageThumbUrl: replyData['user']['logo']['thumb']
//            );
//
//            final Comment reply = Comment(
//                id: replyData['id'],
//                content: replyData['content'],
//                canRemove: replyData['canRemove'],
//                canReply: replyData['canReply'],
//                date: replyData['createdAt']['date'],
//                userShort: userShort
//            );
//            replies.add(reply);
//          });
//
//          final UserShort userShortComment = UserShort(
//              id: commentData['user']['id'],
//              firstName: commentData['user']['firstName'],
//              lastName: commentData['user']['lastName'],
//              imageThumbUrl: commentData['user']['logo']['thumb']
//          );
//
//          final Comment comment = Comment(
//              id: commentData['id'],
//              content: commentData['content'],
//              canRemove: commentData['canRemove'],
//              date: commentData['createdAt']['date'],
//              canReply: commentData['canReply'],
//              replies: replies,
//              userShort: userShortComment
//          );
////          print('data $data');
//
//          fetchedComments.add(comment);
//        });
//        print(fetchedComments.length.toString());
//
//        _comments.addAll(fetchedComments);
//      }
//    }


//    _isCommenting = false;
//    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message']};
  }


}


mixin AuthModel on ConnectedModel{

  File _logoFile;

  bool _isUserDb = false;
  UserModel _userModel;

  List<File> _passportFile;

  PublishSubject<bool> _userSubject = PublishSubject();

  User get user{
    return _authenticatedUser;
  }

  UserModel get userModel{
    return _userModel;
  }

  PublishSubject<bool> get userSubject{
    return _userSubject;
  }


  Profile get profile{
    print('two');
    return _profile;
  }

  bool get isLoading{
    return _isLoading;
  }

  bool get isUserChanged{
    return _isUserChanged;
  }

  File get logoFile{
    return _logoFile;
  }


  Future<Map<String, dynamic>> socialAuthCheck(String uid, String type) async{

//    _isLoading = true;
//    notifyListeners();

    final Map<String, dynamic> authData ={
      'social_id': uid,
      'social_type': type
    };

    http.Response response;

    response = await http.post(
      '${baseUrl}auth/social/check',
      headers:{
        'Content-Type': 'application/json'
      },
      body: json.encode(authData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

//    _isLoading = false;
//    notifyListeners();

    return responseData;
  }


  Future<Map<String, dynamic>> socialAuthRegistration({String uid, String type, String email, String firstName, String lastName}) async {

//    _isLoading = true;
//    notifyListeners();
    print('social auth registration notify');

    final Map<String, dynamic> authData = {
      'social_id': uid,
      'social_type': type,
      'email': email,
      'first_name': firstName,
      'last_name': lastName
    };

    http.Response response;

    response = await http.post(
      '${baseUrl}auth/social/login',
      headers: {
        'Content-Type': 'application/json'
      },
      body: json.encode(authData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    print('responsesss data $responseData');


    if(responseData['status'] == 'success' || responseData['status'] == 'warning'){
      if(responseData['data']['access'] == 'granted'){

        _authenticatedUser = User(
          token: responseData['data']['token'],
        );

        _userSubject.add(true);

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('token', responseData['data']['token']);
        sharedPreferences.setString('how_log_in', responseData['data']['provider']);
      }
    }

//    _isLoading = false;
//    notifyListeners();

    print('social auth registration notify 2');

    return responseData;

  }


  Future<Map<String, dynamic>> socialAuthLogin({String uid, String type}) async {

//    _isLoading = true;
//    notifyListeners();
    print('social auth login notify');

    final Map<String, dynamic> authData = {
      'social_id': uid,
      'social_type': type
    };

    http.Response response;

    response = await http.post(
        '${baseUrl}auth/social/login',
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode(authData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

    if(responseData['status'] == 'success' || responseData['status'] == 'warning'){
      if(responseData['data']['access'] == 'granted'){

        _authenticatedUser = User(
          token: responseData['data']['token'],
        );

        _userSubject.add(true);

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('token', responseData['data']['token']);
        sharedPreferences.setString('how_log_in', responseData['data']['provider']);
      }
    }

    _isLoading = false;
    notifyListeners();
    print('social auth login notify 2');

    return responseData;
  }


  void autoAuthenticate() async {

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String token = sharedPreferences.getString('token');



    if(token != null){

      _authenticatedUser = User(token: token);
      _userSubject.add(true);
      notifyListeners();
    }
    else{
      _authenticatedUser = null;
      notifyListeners();
    }
  }


  Future<void> logout() async {

    print('logout');
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String howLogIn = sharedPreferences.getString('how_log_in');

    _authenticatedUser = null;
    _userSubject.add(false);

    if(howLogIn != null){
      if(howLogIn == 'google.com'){
        print('google logout');
        googleSignOut();
      }
      else if(howLogIn == 'facebook.com'){
        print('facebook logout');
        facebookLogOut();
      }
      else if(howLogIn == 'custom'){
        print('custom logout');
        sharedPreferences.remove('how_log_in');
//        notifyListeners();
      }
      sharedPreferences.remove('token');
      notifyListeners();
    }

  }


  Future<FirebaseUser> googleSignIn() async {

    GoogleSignInAccount googleSignInAccount = await _googleSign.signIn();
    GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

//    _isLoading = true;
//    notifyListeners();

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser user = await _firebaseAuth.signInWithCredential(credential);

    print('User name: ${user.displayName}');
//    _isLoading = false;
//    notifyListeners();
    return user;
  }


  void googleSignOut() async {
    print('Google signed out');
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('how_log_in');
    await FirebaseAuth.instance.signOut();
    await _googleSign.disconnect();
    await _googleSign.signOut();
//    notifyListeners();
  }



  Future<FirebaseUser> facebookLogIn() async {

//    _isLoading = true;
//    notifyListeners();

    Future<FirebaseUser> user;

    return await _facebookLogin.logInWithReadPermissions(['email', 'public_profile'])
        .then((FacebookLoginResult result){

      switch(result.status){
        case FacebookLoginStatus.loggedIn:
          final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          );
          user = FirebaseAuth.instance.signInWithCredential(credential);
          print('loggedin');
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('cancelled by user');
          user = null;
          break;
        case FacebookLoginStatus.error:
          print('facebook error');
          user = null;
          break;
      }

      return user;
    }).catchError((error){
      print(error);
    }).then((user){
//      _isLoading = false;
//      notifyListeners();
      return user;
    })
    .catchError((error){
//      _isLoading = false;
//      notifyListeners();
      print(error);
    });
  }


  void facebookLogOut() async {
    print('Facebook signed out');
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('how_log_in');
    await FirebaseAuth.instance.signOut();
    await _facebookLogin.logOut();
//    notifyListeners();
  }



  Future<Map<String, dynamic>> forgotPassword(String email) async {

//    _isLoading = true;
//    notifyListeners();

    final Map<String, dynamic> authData ={
      'email': email,
    };

    http.Response response;

    response = await http.post(
        '${baseUrl}auth/forgotPassword',
        headers:{
          'Content-Type': 'application/json'
        },
        body: json.encode(authData)
    );


    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

//    _isLoading = false;
    notifyListeners();

    return responseData;

  }


  Future<Map<String, dynamic>> authRegistration(String email, String firstName, String lastName) async {

//    _isLoading = true;
//    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName
    };

    http.Response response;

    response = await http.post(
        '${baseUrl}auth/registration',
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode(authData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('responsesss data $responseData');

    if(responseData['status'] == 'success' || responseData['status'] == 'warning'){
      if(responseData['data']['access'] == 'granted'){

        _authenticatedUser = User(
          token: responseData['data']['token'],
        );

        _userSubject.add(true);

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('token', responseData['data']['token']);
        sharedPreferences.setString('how_log_in', responseData['data']['provider']);
      }
    }


//    _isLoading = false;
    notifyListeners();

    return responseData;
  }



  Future<Map<String, dynamic>> authLogin(String emailOrLogin, String password) async {

//    _isLoading = true;
//    notifyListeners();

    final Map<String, dynamic> authData = {
      'email_or_login': emailOrLogin,
      'password': password
    };

    http.Response response;

    response = await http.post(
        '${baseUrl}auth/login',
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode(authData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');


    if(responseData['status'] == 'success' || responseData['status'] == 'warning'){
      if(responseData['data']['access'] == 'granted'){

        _authenticatedUser = User(
          token: responseData['data']['token'],
        );

        print('here fa login');

        _userSubject.add(true);

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('token', responseData['data']['token']);
        sharedPreferences.setString('how_log_in', responseData['data']['provider']);
      }
    }

//    _isLoading = false;
    notifyListeners();
    print('here noti login');

    return responseData;
  }


  Future<UserModel> getUserProfile() async {

    _isLoading = true;
    print('first notified');
    notifyListeners();

    http.Response response = await http.get(
      '${baseUrl}user/get',
      headers: {
        'Bearer': _authenticatedUser.token
      }
    );

    final Map<String, dynamic> userData = json.decode(response.body);
    print('response data $userData');

//      if(userData['status'] == 'error'){
//        // Todo: если токен устарел надо его выкинуть на WelcomePage и предупредить что токен не валидный
//      }

    if(userData['data'] == null){

      print('here false');
      _isLoading = false;
      notifyListeners();
    }

    print('oneeer');

    Profile profileData = Profile(
      firstName: userData['data']['first_name'],
      lastName: userData['data']['last_name'],
      gender: userData['data']['gender'],
      username: userData['data']['username'],
      email: userData['data']['email'],
      isEmailVerified: userData['data']['is_email_verified'],
      birthDate: (userData['data']['birth_date'] != null ? (userData['data']['birth_date']['date'] as String).split(' ')[0] : null),
      phone: userData['data']['phone'],
      //isActivated -> is Profile verified by admin: passport data
      isActivated: userData['data']['is_activated'],
      imageData: ImageData(
        thumb: userData['data']['logo']['thumb'],
        normal: userData['data']['logo']['normal'],
        original: userData['data']['logo']['original']
      )
    );


//
//    UserModel userModel = UserModel(
//      firstName: profileData.firstName,
//      lastName: profileData.lastName,
//      gender: profileData.gender,
//      username: profileData.username,
//      email: profileData.email,
//      isEmailVerified: profileData.isEmailVerified,
//      birthdate: profileData.birthDate,
//      phone: profileData.phone,
//      isActivated: profileData.isActivated,
//    );
//
//    print('usermodel ${userModel.toJson()}');
//    // here to save



    print('oneewewewe');
    _profile = profileData;
    print('one');
    print(profile);

    _isUserChanged = false;
    _isLoading = false;
    print('second notified');
    notifyListeners();

    return userModel;
  }

//
//  Future<Null> getUserModelFromDB() async {
//    print('herererere');
//    await DBProvider.db.getUser().then((UserModel userModel){
//      _userModel = userModel;
//    }).catchError((error){
//      print('error $error');
//    });
//    notifyListeners();
//  }




  Future<Map<String, dynamic>> updateUserProfile({String firstName, String lastName, String userName, String gender, String birthDate, String phone, String email, String newPassword, String confirmPassword}) async{

//    _isLoading = true;
//    notifyListeners();


    final Map<String, dynamic> updatedData = {
        "first_name": firstName,
        "last_name": lastName,
        "gender": gender,
        "birth_date": birthDate,
        'phone_number': phone,
        'username': userName,
        'email': email,
        "password": newPassword,
        "password_confirmation": confirmPassword,
    };

    http.Response response = await http.post(
        "${baseUrl}user/set",
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(updatedData)
    );
    print('reposneeew ${response.body}');

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

    _isUserChanged = true;
//    _isLoading = false;
    notifyListeners();

    return responseData;
  }

  Future<Null> imageSelectorGallery() async{
    _logoFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if(_logoFile != null){
      print('gallery path: ${_logoFile.path}');
      notifyListeners();
    }
  }


  Future<Null> imageSelectorCamera() async{
    _logoFile = await ImagePicker.pickImage(
        source: ImageSource.camera
    );
    if(_logoFile != null){
      print('camera: ${_logoFile.path}');
      notifyListeners();
    }

  }


  Future<Map<String, dynamic>> uploadLogo(File imageFile) async {

    final stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    final length = await imageFile.length();

    Map<String, String> headers = {'Bearer': _authenticatedUser.token,};

    final uri = Uri.parse('${baseUrl}user/setLogo');

    final request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    final multipartFile = new http.MultipartFile('logo', stream, length, filename: basename(imageFile.path));

    request.files.add(multipartFile);

    final response = await request.send();
    print(response.statusCode);

    // listen for response
    Map<String, dynamic> responseData;

    response.stream.transform(utf8.decoder).listen((value) {
        responseData = json.decode(value);
        print('logo data $responseData');
    });

    // Todo return responseData after waiting

    return {'status': responseData['status'], 'message': responseData['message']};
  }


//  Future<Map<String, dynamic>> testCheck(String uid, String type) async{
//
//    final Map<String, String> authData ={
//      'social_id': uid,
//      'social_type': type
//    };
//
//    http.MultipartRequest request;
//
//    request = http.MultipartRequest(
//        'POST',
//        Uri.parse('${baseUrl}auth/social/check')
//    )..fields.addAll(authData);
//
//    return request.send().then((streamedResponse){
//      return http.Response.fromStream(streamedResponse);
//    }).then((response){
//      return response.body;
//    }).then((body){
//      json.decode(body);
//      print("body is ${json.decode(body)}");
//    })
//    .catchError((error){
//      return {'message': 'Error'};
//    });
//
//  }

}


mixin SupportModel on ConnectedModel{

  bool _isSupportLoading = false;
  int _activeSupportPage = 1;
  int _closedSupportPage = 1;
  int _supportChatPage = 1;
  List<SupportList> _activeSupportList = [];
  List<SupportList> _closedSupportList = [];
  List<SupportChat> _supportChatList = [];
  bool _activeSupportIncompleteResults = true;
  bool _closedSupportIncompleteResults = true;
  bool _supportChatIncompleteResults = true;
  final Map<String, dynamic> _supportData = {
    'id': null,
    'title': null,
    'type': null
  };

  bool get isSupportLoading{
    return _isSupportLoading;
  }


  List<SupportList> get activeSupportList {
    print(_activeSupportList.length);
    return List.from(_activeSupportList);
  }

  List<SupportList> get closedSupportList {
    print(_closedSupportList.length);
    return List.from(_closedSupportList);
  }

  List<SupportChat> get supportChatList {
    print(_closedSupportList.length);
    return List.from(_supportChatList);
  }

  void removeClosedSupportList(){
    _closedSupportList.clear();
  }

  void removeActiveSupportList(){
    _activeSupportList.clear();
  }

  void removeSupportChat(){
    _supportChatList.clear();
  }


  int get activeSupportPage{
    return _activeSupportPage;
  }

  int get closedSupportPage{
    return _closedSupportPage;
  }

  int get supportChatPage{
    return _supportChatPage;
  }

  void increaseActiveSupportPage(){
    _activeSupportPage++;
  }

  void increaseClosedSupportPagePage(){
    _closedSupportPage++;
  }

  void increaseSupportChatPage(){
    _supportChatPage++;
  }

  void activeSupportPageToOne(){
    _activeSupportPage = 1;
  }

  void closedSupportPageToOne(){
    _closedSupportPage = 1;
  }

  void supportChatPageToOne(){
    _supportChatPage = 1;
  }


  bool get activeSupportIncompleteResults{
    return _activeSupportIncompleteResults;
  }

  bool get closedSupportIncompleteResults{
    return _closedSupportIncompleteResults;
  }

  bool get supportChatIncompleteResults{
    return _supportChatIncompleteResults;
  }


  String get webSocketUrl{
    return '$wsUrl?token=${_authenticatedUser.token}';
  }

  void selectSupportId(int id, String title, bool type){
    _supportData['id'] = id;
    _supportData['title'] = title;
    _supportData['type'] = type;
  }

  Map<String, dynamic> get supportData{
    return _supportData;
  }


  // Todo body: page = int, max = int (10 default);
  // Todo type: null = mixed, 1 = opened, 2 = closed;
  Future<Map<String, dynamic>> getSupportList(int supportType) async {

//    _isLoading = true;
//    notifyListeners();


    final Map<String, dynamic> supportData = {
      'page': supportType == 1 ? _activeSupportPage : _closedSupportPage,
      'type': supportType
    };


    http.Response response = await http.post(
        '${baseUrl}support/paginate',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(supportData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

    final List<SupportList> fetchedSupportList = [];

    if(responseData['status'] == 'success'){

      _supportIncompleteResults(supportType, responseData);

      if(responseData['data'] == []){

        // Todo return empty list
        print('support null');
//        _isLoading = false;
//        notifyListeners();
      }



      else{
        print('oneeer');
        print('responsssssssssssss ${(responseData['data'] as List).length}');


        responseData['data'].forEach((data){

          final UserShort userShort = UserShort(
              firstName: data['user']['firstName'],
              lastName: data['user']['lastName'],
              imageThumbUrl: data['user']['logo']['thumb']
          );

          final SupportList supportList = SupportList(
              id: data['id'],
              title: data['title'],
              isClosed: data['isClosed'],
              date: data['createdAt']['date'],
              userShort: userShort,
          );
//          print('data $data');

          fetchedSupportList.add(supportList);
        });

        supportType == 1 ? _activeSupportList.addAll(fetchedSupportList) : _closedSupportList.addAll(fetchedSupportList);
      }
    }


//    _isLoading = false;
//    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message'], 'total_count': responseData['total_count'], 'incomplete_results': responseData['incomplete_results']};
  }


  Future<Map<String, dynamic>> getSupportChat(int supportId) async {

//    _isLoading = true;
//    notifyListeners();


    final Map<String, dynamic> supportData = {
      'supportId': supportId,
      'page': _supportChatPage,
      'max': 10
    };


    http.Response response = await http.post(
        '${baseUrl}support/chat/paginate',
        headers: {
          'Bearer': _authenticatedUser.token,
          'Content-Type': 'application/json'
        },
        body: json.encode(supportData)
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print('response data $responseData');

    final List<SupportChat> fetchedSupportChat = [];

    if(responseData['status'] == 'success'){

      _supportChatIncompleteResults = responseData['incomplete_results'];

      if(responseData['data'] == []){

        // Todo return empty list
        print('support null');
//        _isLoading = false;
//        notifyListeners();
      }


      else{
        print('oneeer');
        print('responsssssssssssss ${(responseData['data'] as List).length}');


        responseData['data'].forEach((data){

          final UserShort userShort = UserShort(
              firstName: data['user']['firstName'],
              lastName: data['user']['lastName'],
              imageThumbUrl: data['user']['logo']['thumb']
          );

          final SupportChat supportChat = SupportChat(
            id: data['id'],
            isOperator: data['isOperator'],
            isMe: data['isMe'],
            content: data['content'],
            date: data['createdAt']['date'],
            userShort: userShort,
          );
//          print('data $data');

          fetchedSupportChat.add(supportChat);
        });

        _supportChatList.addAll(fetchedSupportChat);
      }
    }


//    _isLoading = false;
//    print('second notified');
    notifyListeners();

    return {'status': responseData['status'], 'message': responseData['message'], 'total_count': responseData['total_count'], 'incomplete_results': responseData['incomplete_results']};
  }


  void _supportIncompleteResults(int type, Map<String, dynamic> responseData){
    if(type == 1){
      _activeSupportIncompleteResults = responseData['incomplete_results'];
    }
    else if(type == 2){
      _closedSupportIncompleteResults = responseData['incomplete_results'];
    }
  }
}