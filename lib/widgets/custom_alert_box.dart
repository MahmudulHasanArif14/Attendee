import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../pages/admin_dashboard.dart';
import '../pages/dashboard.dart';

class CustomAlertBox {

  String userDesignation="";

  Future<bool> fetchUserDesignation(BuildContext context) async {
    await Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    ).fetchUserProfile();
    if (!context.mounted) return false;
    Map<String, dynamic>? profile =
        Provider.of<DatabaseHelperProvider>(context, listen: false).profile;

    if (profile != null || profile!.isNotEmpty) {
      final designation = profile['designation'].toString().trim();
      if (designation == "" || designation.isEmpty) {
        return false;
      }
      userDesignation=designation;
    }
    return true;
  }

  //Update Data to database
  Future<void> _updateField(
      BuildContext context,
      String key,
      String value,
      ) async {
    await Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    ).updateUserField(key, value);
    print("All Data UPDated");
  }


  Future<void> showCustomAnimatedAlert({
    required BuildContext context,
    required String title,
    required String label,
    User? user,
  }) async {
    bool res = await fetchUserDesignation(context);

    final List<String> designationList = [
      'Select Your Role',
      'Admin',
      'Customer Support Executive',
      'SuperAdmin',
    ];
    String? currSelectedItem = designationList.first;

    if (!context.mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      barrierLabel: "Custom Alert", // screen reader label reads
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final size = MediaQuery.of(context).size;
        final bool isSmallScreen = size.width < 400;


        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Color(0x4D000000)
                        : Color(0x66FFFFFF),
              ),
            ),

            // Center Dialog Box
            StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setState,
              ) {
                return Center(
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: size.width * 0.8,
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/thanks.png',
                              height: size.height * 0.2,
                              width: size.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 18,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFF4A4A4E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            !res
                                ? DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: currSelectedItem,
                                    items:
                                        designationList.map((designationItem) {
                                          return DropdownMenuItem<String>(
                                            value: designationItem,
                                            child: Text(
                                              designationItem,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: designationItem == 'Select Your Role' ? Colors.grey :Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        currSelectedItem = value;
                                        if(value!=null && value!="Select Your Role"){
                                          _updateField(context,'designation',value);
                                        }
                                      });
                                    },
                                  ),
                                )
                                : Text(""),
                            !res ? SizedBox(height: 10) : SizedBox(height: 0),
                            ElevatedButton(
                              onPressed: () {
                                //if User don't Select  Role can't back to home
                                if (!res &&
                                    (currSelectedItem == null ||
                                        currSelectedItem ==
                                            'Select Your Role')) {
                                  return;
                                }


                                if (context.mounted) {

                                  if(userDesignation!="" || userDesignation.isNotEmpty){

                                    if(userDesignation=="Admin"){

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AdminDashboard(user: user!),
                                        ),
                                            (route) =>
                                        false, // Removes all previous routes from navigation stack
                                      );

                                    }else{

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => HomePage(user: user!),
                                        ),
                                            (route) =>
                                        false, // Removes all previous routes from navigation stack
                                      );


                                    }


                                  }




                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:!res &&
                                    (currSelectedItem == null ||
                                        currSelectedItem ==
                                            'Select Your Role')?Theme.of(context).disabledColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Back to Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }
}
