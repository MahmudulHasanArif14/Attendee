import 'package:attendee/pages/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/auth_helper.dart';
import '../widgets/custom_form_textfield.dart';
import '../widgets/custom_text.dart';

class LoginPage extends StatefulWidget {
  final String? errorMessage;
  const LoginPage({super.key, this.errorMessage});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthHelper _authHelper = AuthHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form Key
  bool _obscureText = true;
  bool isEmailValid = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    emailTextController.addListener(validateEmail);
  }

  @override
  void dispose() {
    emailTextController.removeListener(validateEmail);
    emailTextController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _loginUser() {
    String email = emailTextController.text.trim();
    String password = passwordController.text.trim();

    _authHelper.logIn(context, email, password);
  }



  // Email Validator
  void validateEmail() {
    final email = emailTextController.text;
    final bool isValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
    setState(() {
      isEmailValid = isValid;
    });
  }





  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
      ),

      body: GestureDetector(
        //Change the focus from the keyboard
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  /*Logo*/
                  SizedBox(
                    width: screenHeight * 0.14,
                    height: screenHeight * 0.1,
                    child: Image.asset('assets/images/logo.png'),
                  ),

                  CustomText(text: 'Welcome back 👋'),


                  Row(
                    children: const [
                      CustomText(text: 'to '),
                      CustomText(text: 'Attendee', color: Color(0xFF3085FE)),
                    ],
                  ),

                  CustomText(
                    text: 'Hello there, login to continue',
                    fontSize: 12,
                    color: Color(0xFFACAFB5),
                  ),

                  const SizedBox(height: 15),


                  // /*Phone Number */
                  // IntlPhoneField(
                  //   flagsButtonPadding:EdgeInsets.symmetric(horizontal: 10),
                  //   controller: phonetextcontroller,
                  //   keyboardType: TextInputType.number,
                  //   dropdownTextStyle: TextStyle(
                  //     color: Colors.grey,
                  //     height: 1.5,
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  //   dropdownIconPosition:IconPosition.trailing,
                  //
                  //   decoration: InputDecoration(
                  //     labelText: 'Phone Number',
                  //     labelStyle: TextStyle(color: Colors.grey.shade600),
                  //     suffixIcon: Icon(
                  //       isEmailValid ? Icons.check_circle : Icons.local_phone_outlined,
                  //       color: isEmailValid ? Colors.green : Colors.grey,
                  //     ),
                  //
                  //     hintText: "Enter Your Number",
                  //     hintStyle: const TextStyle(
                  //       color: Colors.grey,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //
                  //
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: const BorderSide(color: Color(0x9B3386FE)),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(
                  //         color:
                  //         Theme.of(context).brightness == Brightness.dark
                  //             ? const Color(0x2A3386FE)
                  //             : const Color(0x9B3386FE),
                  //         width:
                  //         Theme.of(context).brightness == Brightness.dark
                  //             ? 2
                  //             : 1,
                  //       ),
                  //     ),
                  //
                  //
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(
                  //         color:Colors.redAccent.shade100,
                  //         width: 1,
                  //       ),
                  //     ),
                  //
                  //     focusedErrorBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(
                  //         color:Colors.red.shade400,
                  //         width: 1,
                  //       ),
                  //     ),
                  //
                  //
                  //
                  //
                  //   ),
                  //
                  //
                  //   languageCode: 'en',
                  //   initialCountryCode: 'BD',
                  //
                  //
                  //   validator: (phone) {
                  //     if (phone == null || phone.number.isEmpty) {
                  //       return 'Please enter a phone number';
                  //     }
                  //     return null;
                  //   },
                  //
                  //
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _isSubmitted = false;
                  //       _formKey.currentState!.validate();
                  //     });
                  //   },
                  //
                  //
                  //
                  //
                  //
                  // ),


                   // Email Field


                  // Email Text Field
                  CustomFormTextField(
                    textController: emailTextController,
                    textKeyboardType: TextInputType.emailAddress,
                    labelText: 'Email Address',
                    suffixIcon: Icon(
                      isEmailValid ? Icons.check_circle : Icons.email_outlined,
                      color: isEmailValid ? Colors.green : Colors.grey,
                    ),
                    hintText: "example@email.com",
                    validator: (value) {
                      if (!_isSubmitted) return null;
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      if(!isEmailValid){
                        return 'Enter A Valid Email';
                      }

                      return null;
                    },

                    onChanged: (value) {
                      setState(() {
                        _isSubmitted = false;
                        _formKey.currentState!.validate();

                      });
                    },

                  ),


                  const SizedBox(height: 20),


                  // Password Text Field
                  CustomFormTextField(
                      textController: passwordController,
                      obscureText: _obscureText,
                      labelText: 'Password',
                      suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),

                    validator: (value) {
                      if (!_isSubmitted) return null;
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Password';
                      }
                      return null;
                    },

                    onChanged: (value) {
                      setState(() {
                        _isSubmitted = false;
                        _formKey.currentState!.validate();
                      });
                    },
                  ),


                  const SizedBox(height: 10),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        //Code goes here
                      },
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.black,
                      ),
                      child: const Text(
                        'Forgot Password ?',
                        style: TextStyle(color: Color(0xFF3085FE)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSubmitted = true;
                        });

                        // Add login logic here
                        if (_formKey.currentState!.validate()) {
                          // Perform login
                          _loginUser();

                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3085FE),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: Text('Login', style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "Or continue with" Section
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double lineWidth = constraints.maxWidth * 0.2;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: lineWidth,
                              color: const Color(0xFF5B5C5C),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Or continue with social account',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5B5C5C),
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              width: lineWidth,
                              color: const Color(0xFF5B5C5C),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // print("Google login");

                        AuthHelper().loginWithGoogle(context);

                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Google',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                              color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Didn't have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFACAFB5),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFF3085FE), // Blue color
                              fontSize: 14,
                              fontWeight:FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} //end of state