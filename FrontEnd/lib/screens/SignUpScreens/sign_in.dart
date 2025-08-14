import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/auth/auth.service.dart';
import 'package:flutter_amortiza/controllers/user_controller.dart';
import 'package:flutter_amortiza/models/user_model.dart';
import 'package:flutter_amortiza/screens/SignUpScreens/sign_up.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';
import 'package:flutter_amortiza/screens/home_screen/home_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //Instance of DIO
  final Dio dio = GetIt.instance<Dio>();

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign in function that stores the tokens
  Future<void> _signIn() async {
    if (emailController == "" || passwordController.text == "") {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Preencha todos os campos',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
    }
    try {
      final tokensresponse = await dio.post('auth/signin', data: {
        "email": emailController.text,
        "password": passwordController.text,
      });

      if (tokensresponse.statusCode == 200) {
        //get the tokens from the request
        final accessToken = tokensresponse.data['access_token'];
        final refreshToken = tokensresponse.data['refresh_token'];

        //make a request to the /users/me
        try {
          final userResponse = await dio.get('users/me',
              options: Options(headers: {
                //passing the access token
                'Authorization': 'Bearer $accessToken',
              }));
          if (userResponse.statusCode == 200) {
            print('User data: ${userResponse.data}');
            final user = User.fromJson(userResponse.data);
            Provider.of<UserController>(context, listen: false).setUser(user);
            
          } else {
            print('Request failed with status: ${userResponse.statusCode}');
            return;
          }
        } catch (e) {
          showTopSnackBar(
            Overlay.of(context),
            AwesomeSnackbarContent(
              title: 'Ops!',
              message: 'Erro 2',
              contentType: ContentType.failure,
            ),
            displayDuration: Duration(seconds: 3),
          );
          return;
        }

        //store the tokens securly
        await AuthService.instance.storeTokens(accessToken, refreshToken);
        //go to the home screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        showTopSnackBar(
          Overlay.of(context),
          AwesomeSnackbarContent(
            title: 'Ops!',
            message: 'Email ou Password incorretos',
            contentType: ContentType.failure,
          ),
          displayDuration: Duration(seconds: 3),
        );
        return;
      }
    } catch (e) {
      print(e);
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'ultimo erro',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return;
    }
  }

  //disposing the controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Title and Subtitle
              const Text(
                "Sign Into Your Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002E8B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome Back.\nYou’ve been missed!",
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF002E8B),
                ),
              ),
              const SizedBox(height: 30),
              // Image
              Center(
                child: Image.asset(
                  'assets/sign-in.png', // Login Image
                  height: 283,
                ),
              ),
              const SizedBox(height: 30),
              // Email Field
              CustomTextField(
                controller: emailController,
                name: "Email",
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password Field
              CustomTextField(
                controller: passwordController,
                name: "Password",
                obscureText: true,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 30),
              // Login Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002E8B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                  child: const Text(
                "or",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002E8B)),
              )),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002E8B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
