import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String label,
    String? title,
    double height = 80,
    double padding = 16,
    double radius = 20,
  }) {
    final snackBar = SnackBar(
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            height: height,
            decoration: BoxDecoration(
              color: Color(0xFFC72C41), // Red Color
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Keeps column compact
                    children: [
                      if (title != null)
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      Spacer(),
                      Text(
                        label,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SVG Image Positioned at Bottom
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
              ),
              child: SvgPicture.asset(
                "assets/images/bubbles.svg",
                height: 48,
                width: 40,
                color: Colors.red.shade500,
              ),
            ),
          ),


          Positioned(
              top: -14,
              left: 0,
              child: InkWell(
                onTap: (){
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children:[
                    SvgPicture.asset("assets/images/back.svg",
                    height: 40,
                  ),

                    Positioned(
                      top:10,
                      child:SvgPicture.asset("assets/images/failure.svg",
                        height: 16,
                      )
                    ),

                  ]
                ),
              )
          ),



        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      duration: const Duration(seconds:3),
    );

    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
