import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login/signin_screen.dart';
import 'package:flutter_application_1/screens/login/welcome_screen.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/screens/login/loading_page.dart';
import 'package:flutter_application_1/widgets/custom_home.dart';
import 'package:flutter_application_1/screens/users/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
   runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({
    @required this.token,
    Key? key,
}): super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: Loading(),
    );
  }
}
