import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class CheckDialog extends StatelessWidget {

  final String response;
  final String message;
  final String navigate;

  CheckDialog({Key key, @required this.response, @required this.message, @required this.navigate})
      :super(key:key);



  @override
  Widget build(BuildContext context) {
    print('BUILDDAS');
    return SimpleDialog(
      children: <Widget>[

        Container(
          width: 150,
          height: 150,
          child: response == 'success'
              ? FlareActor(
            'assets/check.flr',
            animation: 'Untitled',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          )
              : FlareActor(
            'assets/error.flr',
//            'assets/warning.flr',
            animation: 'Error',
//            animation: 'Warn',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          ),

        ),
        Container(child: Text(message, style: TextStyle(fontSize: 18, color: Colors.black),), alignment: Alignment.center, margin: EdgeInsets.only(bottom: 10),),


        // Todo: makeButton -> x (close) to top-right corner
        Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: ButtonTheme(
            child: RaisedButton(
              child: Text('Ok'),
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              onPressed: () {
//                Navigator.of(context).pop()
                if(navigate == 'main'){
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                }
                else if(navigate == 'pop'){
                  Navigator.of(context).pop();
                }
              }
            ),
          ),
        )

      ],
    );
  }
}
