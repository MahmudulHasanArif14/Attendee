  import 'package:attendee/widgets/custom_form_textfield.dart';
  import 'package:attendee/widgets/custom_snackbar.dart';
  import 'package:flutter/material.dart';
  import 'package:intl_phone_field/intl_phone_field.dart';

  import '../auth/supabase_auth.dart';
import '../widgets/custom_text.dart';
  import 'legal_page.dart';
import 'login_page.dart';

  class RegistrationPage extends StatefulWidget {
    final String? errorMessage;
    const RegistrationPage({super.key, this.errorMessage});
    @override
    State<RegistrationPage> createState() => _RegistrationPageState();
  }

  class _RegistrationPageState extends State<RegistrationPage> {
    final TextEditingController fullName = TextEditingController();
    final TextEditingController emailTextController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    String? fullPhoneNumber;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form Key


    // Status Variables
    bool _isSubmitted = false;
    bool _obscureText = true;
    bool isEmailValid = false;
    bool validPass = false;
    bool isChecked = false;

    @override
    void initState() {
      super.initState();
      emailTextController.addListener(validateEmail);
      passwordController.addListener(isSamePass);
      confirmPasswordController.addListener(isSamePass);
    }

    @override
    void dispose() {
      emailTextController.removeListener(validateEmail);
      passwordController.removeListener(isSamePass);
      confirmPasswordController.removeListener(isSamePass);
      emailTextController.dispose();
      passwordController.dispose();
      fullName.dispose();
      confirmPasswordController.dispose();
      super.dispose();
    }

    void validateEmail() {
      final email = emailTextController.text;
      final bool isValid = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email);
      setState(() {
        isEmailValid = isValid;
      });
    }

    void isSamePass() {
      final pass = passwordController.text.toString().trim();
      final confirmPass = confirmPasswordController.text.toString().trim();
      setState(() {
        validPass =
            pass.isNotEmpty && confirmPass.isNotEmpty && pass == confirmPass;
      });
    }

    final OauthHelper _authHelper = OauthHelper();

    void _registerUser() async {
      String email = emailTextController.text.trim();
      String password = passwordController.text.trim();
      String name=fullName.text.toString().trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        await _authHelper.signUp(email: email, password: password, context: context, name: name,fullPhoneNumber: fullPhoneNumber);
      }
      else{
        CustomSnackbar.show(
            context: context,
            label: "Email And Password Can't be Null"
        );
      }



    }


    @override
    Widget build(BuildContext context) {
      final double screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: GestureDetector(
          //Change the focus from the keyboard
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(
                parent: NeverScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      screenHeight -
                      (MediaQuery.of(context).padding.top + kToolbarHeight),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      /*Logo*/
                      SizedBox(
                        width: screenHeight * 0.14,
                        height: screenHeight * 0.1,
                        child: Image.asset('assets/images/logo.png'),
                      ),

                      CustomText(text: 'Register Account'),

                      Row(
                        children: const [
                          CustomText(text: 'to '),
                          CustomText(text: 'Attendee', color: Color(0xFF3085FE)),
                        ],
                      ),

                      CustomText(
                        text: 'Hello there, register to continue',
                        fontSize: 12,
                        color: Color(0xFFACAFB5),
                      ),

                      const SizedBox(height: 10),

                      // Full Name Field
                      CustomFormTextField(
                        textController: fullName,
                        textKeyboardType: TextInputType.name,
                        labelText: 'Full Name',
                        hintText: "Enter Your Name",
                        validator: (value) {
                          if (!_isSubmitted) return null;
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Name';
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

                      // Email Text Field
                      CustomFormTextField(
                        textController: emailTextController,
                        textKeyboardType: TextInputType.emailAddress,
                        labelText: 'Email Address',
                        suffixIcon: Icon(
                          isEmailValid
                              ? Icons.check_circle
                              : Icons.email_outlined,
                          color: isEmailValid ? Colors.green : Colors.grey,
                        ),
                        hintText: "example@email.com",
                        validator: (value) {
                          if (!_isSubmitted) return null;
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          if (!isEmailValid) {
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

                      const SizedBox(height: 10),

                      /*Phone Number */
                      IntlPhoneField(
                        flagsButtonPadding: EdgeInsets.symmetric(horizontal: 10),
                        keyboardType: TextInputType.number,
                        dropdownTextStyle: TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        dropdownIconPosition: IconPosition.trailing,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          suffixIcon: Icon(
                            Icons.local_phone_outlined,
                            color: Colors.grey,
                          ),

                          hintText: "Enter Your Number",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0x9B3386FE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0x2A3386FE)
                                      : const Color(0x9B3386FE),
                              width:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? 2
                                      : 1,
                            ),
                          ),

                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent.shade100,
                              width: 1,
                            ),
                          ),

                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.red.shade400,
                              width: 1,
                            ),
                          ),
                        ),

                        languageCode: 'en',
                        initialCountryCode: 'BD',

                        validator: (phone) {
                          if (!_isSubmitted) return null;
                          if (phone == null || phone.number.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },

                        onChanged: (value) {
                          setState(() {
                            _isSubmitted = false;
                            _formKey.currentState!.validate();
                          });
                        },

                        onSaved: (phone) {
                          fullPhoneNumber = phone?.completeNumber;
                        },

                      ),

                      const SizedBox(height: 10),

                      // Password Field
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

                        suffix:
                            (validPass)
                                ? Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                )
                                : null,
                        validator: (value) {
                          if (!_isSubmitted) return null;
                          if (value == null || value.isEmpty) {
                            return "Password Can't be Empty! ";
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

                      // Confirm_Password Field
                      CustomFormTextField(
                        textController: confirmPasswordController,
                        obscureText: _obscureText,
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),

                        suffix:
                            (validPass)
                                ? Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                )
                                : null,

                        validator: (value) {
                          if (!_isSubmitted) return null;
                          if (value == null || value.isEmpty) {
                            return "Password Can't be Empty! ";
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


                      Align(
                        widthFactor: double.infinity,
                        alignment: Alignment.center,
                        child:Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox with text
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;

                                  if (isChecked) {

                                    CustomSnackbar.show(
                                      context: context,
                                      title: "Policy Acknowledgment",
                                      label: "Terms & Conditions accepted successfully",
                                      color: Color(0xE04CAF50),
                                      svgColor: Color(0xE0178327),
                                    );


                                  }

                                });
                              },

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: BorderSide(
                                color: const Color(0xFF3085FE),
                                width: 1.5,
                              ),
                            ),
                            TextButton(
                              onPressed: () {


                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LegalScreen(
                                    ),
                                  ),
                                );
                              },
                              child: Expanded(
                                child: Text(
                                  "I Agree to the Terms & Conditions",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xBB3085FE),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ),


                      SizedBox(height: 10),

                      // Registration Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isChecked
                                  ? () {
                                    setState(() {
                                      _isSubmitted = true;
                                    });

                                    // Add login logic here
                                    if (_formKey.currentState!.validate()) {
                                      // Perform login
                                      _registerUser();
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3085FE),
                            padding: const EdgeInsets.all(15),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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

                      const SizedBox(height: 15),

                      // Google Login Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // print("Google login");
                            _authHelper.loginWithGoogle(context);
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
                                      Theme.of(context).brightness ==
                                              Brightness.dark
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
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFACAFB5),
                              ),
                            ),
                            TextButton(
                              onPressed: () {


                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFF3085FE), // Blue color
                                  fontSize: 12,
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
        ),
      );
    }
  }
