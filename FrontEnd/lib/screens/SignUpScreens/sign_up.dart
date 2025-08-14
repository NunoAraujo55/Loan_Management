import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amortiza/screens/SignUpScreens/sign_in.dart';
import 'package:flutter_amortiza/screens/credit/widgets/input/input_field_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/gestures.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //dio instance
  final Dio dio = GetIt.instance<Dio>();

  //controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Sign up function
  Future<void> _signUp() async {
    if (emailController == "" ||
        passwordController.text == "" ||
        usernameController.text == "") {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Preencha todos os campos',
          contentType: ContentType.failure,
        ),
        displayDuration: Duration(seconds: 3),
      );
      return;
    }
    try {
      final response = await dio.post('auth/signup', data: {
        'email': emailController.text,
        'password': passwordController.text,
        "username": usernameController.text,
      });

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          AwesomeSnackbarContent(
            title: 'Ops!',
            message: 'Erro ao fazer o cadastro',
            contentType: ContentType.failure,
          ),
          displayDuration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        AwesomeSnackbarContent(
          title: 'Ops!',
          message: 'Erro ao fazer o cadastro',
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
    usernameController.dispose();
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
              // Título e subtítulo
              const Text(
                "Sign Up for Your Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002E8B),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: "Already have an account?",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF002E8B),
                  ),
                  children: [
                    TextSpan(
                      text: " Sign in!",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF002E8B),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/sign-in.png',
                  height: 263,
                ),
              ),

              const SizedBox(height: 30),
              CustomTextField(
                controller: usernameController,
                name: "Name",
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Campo para Email
              CustomTextField(
                controller: emailController,
                name: "Email",
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Campo para Senha
              CustomTextField(
                controller: passwordController,
                name: "Password",
                obscureText: true,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 30),
              // Botão de Cadastro
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signUp,
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
                            builder: (context) => SignInScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002E8B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
