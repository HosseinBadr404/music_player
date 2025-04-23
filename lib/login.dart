import 'package:flutter/material.dart';
import 'SignupPage.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // بازگشت به صفحه قبل
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Login to your account",
                        style:
                        TextStyle(fontSize: 15, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        inputField(label: "Username", isPassword: false),
                        inputField(label: "Password", isPassword: true),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                          );
                        },
                        color: Color(0xff0095FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Don't have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                        child: Text(
                          " Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100),
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/background(1).png"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget inputField({required String label, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                obscureText: isPassword ? isPasswordObscure : false,
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Color.fromARGB(255, 90, 150, 180)),
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Color.fromARGB(255, 90, 185, 200)),
                  ),
                ),
              ),
            ),
            if (isPassword)
              IconButton(
                icon: Icon(isPasswordObscure
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() {
                    isPasswordObscure = !isPasswordObscure;
                  });
                },
              ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}