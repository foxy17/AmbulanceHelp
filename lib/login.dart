import 'dart:convert';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  FlutterTts flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.example.flutter_onboarding',
      'Campus Ambassador',
      'Application Status',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }


  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
    try {
      await FirebaseAuth.instance.signInAnonymously();
      FirebaseUser user=await FirebaseAuth.instance.currentUser();

    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
  void registerNotification() {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');

//    Firestore.instance.collection('vehicle').document(widget.user.uid).setData({'pushToken': token});
    }).catchError((err) {

    });
  }
  @override
  Widget build(BuildContext context) {
    registerNotification();
    configLocalNotification();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image.asset('assets/splash.png',height: MediaQuery.of(context).size.height,),
          Center(
            child: Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)
                        ),
                      ),
                      color: Colors.deepOrange,
                      child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[Icon(Icons.accessibility_new),Text('I am User',style: TextStyle(color: Colors.white,fontSize: 17),)],),
                      onPressed: _signInAnonymously,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: new BoxDecoration(

                        borderRadius: new BorderRadius.all(Radius.circular(20.0)),),
                    width: MediaQuery.of(context).size.width*0.5,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)
                        ),
                      ),
                      color: Colors.deepOrange,

                      child:Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[Icon(Icons.directions_car),Text('I am Ambulance',style: TextStyle(color: Colors.white,fontSize: 17),)],),
                      onPressed: (){Navigator.pushNamed(context, "ambulance");},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

