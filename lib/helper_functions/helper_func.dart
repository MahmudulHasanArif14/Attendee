import 'package:attendee/auth/supabase_auth.dart';
import 'package:attendee/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database_helper.dart';
import '../geolocation/location_helper.dart';
import '../provider/attendance_provider.dart';
import '../services/notification_service.dart';

class HelperFunction {
  static const double allowedDistance = 100;
  final supabase = Supabase.instance.client;
  int breakCount = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  ///CheckIn Functionality
  Future<void> handleCheckIn(BuildContext context) async {
    if (!context.mounted) return;

    ///Fetch Current User location lat and longitude
    final dbProvider = Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    );
    final profile = dbProvider.profile;
    final officelatitude = profile?["latitude"]; //office latitude
    final officelongitude = profile?["longitude"]; //office longitude
    final User currUser = OauthHelper.currentUser(); // curr user
    final today = DateTime.now().toUtc();
    print(
      "officelatitude $officelatitude and officelongitude $officelongitude",
    );

    final startTime = profile?["start_time"];
    final endTime = profile?["end_time"];

    if (startTime == null &&
        endTime == null &&
        officelatitude == null &&
        officelongitude == null) {
      CustomSnackbar.show(
        context: context,
        label: "To Access this Feature Please Complete Your Profile",
      );
      return;
    }

    if (startTime == null && endTime == null) {
      CustomSnackbar.show(
        context: context,
        label: "To Access this Feature Please Complete Your Profile",
      );
      return;
    }
    if (officelatitude == null && officelongitude == null) {
      CustomSnackbar.show(
        context: context,
        label: "To Access this Feature Please Complete Your Profile",
      );
      return;
    }

    try {
      if (officelatitude != null && officelongitude != null) {
        final position = await LocationHelper().getCurrentPosition(context);
        if (position != null) {
          double distance = LocationHelper.distanceBetween(
            officelatitude,
            officelongitude,
            position.latitude,
            position.longitude,
          );

          print("your current location is $position");

          ///Check the user is within the office radius or not
          if (distance > allowedDistance) {
            if (context.mounted) {
              CustomSnackbar.show(
                context: context,
                label: "You are not inside office!",
              );
            }
            print("from office your distance is $distance");
            return;
          }
        }
      }

      ///Check the userPrevious CheckIn time so only after 16hour he/she can checkIn again
      final lastRecord =
          await supabase
              .from('attendance')
              .select()
              .eq('profile_id', currUser.id)
              .not('check_in_time', 'is', null)
              .order('date', ascending: false)
              .order('check_in_time', ascending: false)
              .limit(1)
              .maybeSingle();

      if (lastRecord != null) {
        if (lastRecord['check_in_time'] != null) {
          DateTime lastCheckIn = DateTime.parse(lastRecord['check_in_time']);
          final hoursSinceLastCheckIn =
              DateTime.now().difference(lastCheckIn).inHours;

          if (hoursSinceLastCheckIn < 15) {
            if (context.mounted) {
              CustomSnackbar.show(
                context: context,
                label:
                    "You can only check-in after 16 hours from your last check-in!",
              );
            }
            print("You are too early to office ! time not yet");
            return;
          }
        } else {
          print("Last check-in time is NULL, skipping 16-hour check.");
        }
      }

      final todayDateString = DateFormat('yyyy-MM-dd').format(today);
      final timeNow = DateFormat('hh:mm a').format(today.toLocal());


      final rowCheckedIn = await supabase
          .from('attendance')
          .select('check_in_time')
          .eq('profile_id', currUser.id)
          .not('check_in_time', 'is', null);

      final hasCheckedInToday = rowCheckedIn.any((record) {
        final checkInTime = record['check_in_time'];
        if (checkInTime == null) {
          return false;
        }
        final checkInDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(checkInTime).toUtc());
        return checkInDate == todayDateString;
      });

      if (hasCheckedInToday) {
        if (context.mounted) {
          CustomSnackbar.show(
            context: context,
            label: "You’ve already checked in today!",
          );

          print("already office");
        }
        return;
      } else {
        ///Update data

        if (context.mounted) {
          final _ = Provider.of<DatabaseHelperProvider>(
            context,
            listen: false,
          ).updateAttendance(
            profileId: currUser.id,
            checkInTime: today,
            dateString: todayDateString,
          );
        }



        if (context.mounted) {
          final response =
              Provider.of<DatabaseHelperProvider>(
                context,
                listen: false,
              ).todayAttendance;
          Provider.of<AttendanceProvider>(
            context,
            listen: false,
          ).checkIn(response?['id'], today);

          Provider.of<AttendanceProvider>(
            context,
            listen: false,
          ).setCheckedIn(true);

          ///Sending notification to the user on success checkedIn
          NotificationServices().showManualNotification(
            title: "Attendance Alert 🚨",
            body: "You Checked in  office at $timeNow",
          );

          CustomSnackbar.show(
            context: context,
            title: "You're In! ✅",
            label: "Checked in successfully!",
            color: Color(0xE04CAF50),
            svgColor: Color(0xE0178327),
          );

          trackUser(context);

          print("Checked in success you are in  office");
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context: context, label: 'Error: ${e.toString()}');
        print(e.toString());
        print("Error here");
      }
    }
  }

  ///CheckOut Functionality

  Future<void> handleCheckOut(BuildContext context) async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    if (!provider.isCheckedIn) return;
    final User currUser = OauthHelper.currentUser();

    final today = DateTime.now().toUtc();
    final todayDate = DateFormat('yyyy-MM-dd').format(today);
    final timeNow = DateFormat('hh:mm a').format(today.toLocal());

    ///update checkout time to db
    if (context.mounted) {
      await Provider.of<DatabaseHelperProvider>(
        context,
        listen: false,
      ).updateCheckout(
        currUser.id,
        today,
        provider.totalBreakDuration,
        todayDate,
      );
    }

    bool isUpdate =
        context.mounted
            ? Provider.of<DatabaseHelperProvider>(
              context,
              listen: false,
            ).isUpdated
            : false;

    if (!isUpdate) {
      return;
    }

    NotificationServices().showManualNotification(
      title: "Attendance Alert 🚨",
      body: "You Checkout From office at $timeNow",
    );

    if (context.mounted) {
      Provider.of<AttendanceProvider>(context, listen: false).checkOut();
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).setCheckedIn(false);
    }

    if (context.mounted) {
      CustomSnackbar.show(
        context: context,
        title: "See you later! ✅",
        label: "Checked out successfully!",
        color: Color(0xE04CAF50),
        svgColor: Color(0xE0178327),
      );

      LocationHelper().stopTracking();

      print("checked out office");
    }
  }

  Future<void> trackUser(BuildContext context) async {
    ///Fetch Current User location lat and longitude
    final dbProvider = Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    );
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    final profile = dbProvider.profile;
    final officelatitude = profile?["latitude"];
    final officelongitude = profile?["longitude"];
    final User _ = OauthHelper.currentUser();
    DateTime? leftOfficeTime;
    Duration totalBreakTime = Duration.zero;
    bool isOutside = false;
    const double allowedRadius = 100;

    // Check location permission and start tracking if allowed
    bool locationPermissionGranted = await _isLocationPermissionAllowed(
      context,
    );
    if (!locationPermissionGranted) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          label: 'Location permission denied.',
        );
      }
      return;
    }

    ///start tracking of the user
    LocationHelper().startTracking(
      onData: (Position pos) async {
        ///Getting the user location stream
        if (officelatitude != null && officelongitude != null) {
          double distance = LocationHelper.distanceBetween(
            officelatitude,
            officelongitude,
            pos.latitude,
            pos.longitude,
          );

          if (provider.isCheckedIn) {
            if (distance > allowedRadius) {
              breakCount++;
              //Then User is outside the office
              if (!isOutside) {
                isOutside = true;
                leftOfficeTime = DateTime.now();
              } else {
                final minutesOutside =
                    DateTime.now().difference(leftOfficeTime!).inMinutes;
                if (minutesOutside >= 10) {
                  // Warn to check out
                  NotificationServices().showManualNotification(
                    title: "Attendance Alert 🚨",
                    body: "You're out of office! Please check out.",
                  );

                  if (context.mounted) {
                    CustomSnackbar.show(
                      context: context,
                      label: "You're out of office! Please check out.",
                    );
                  }
                }
              }
            } else {
              // User came back inside office before 10 min
              if (isOutside && leftOfficeTime != null) {
                Duration breakDuration = DateTime.now().difference(
                  leftOfficeTime!,
                );

                totalBreakTime += breakDuration;

                ///Updating the break time to the supabase db
                final today = DateTime.now().toUtc();
                final todayDate = DateFormat('yyyy-MM-dd').format(today);
                Map<String, dynamic>? todayData;
                if (context.mounted) {
                  await Provider.of<DatabaseHelperProvider>(
                    context,
                    listen: false,
                  ).fetchUserAttendanceByDate(todayDate);
                  if (context.mounted) {
                    todayData =
                        Provider.of<DatabaseHelperProvider>(
                          context,
                          listen: false,
                        ).todayAttendance;
                  }
                }

                int breakTime =
                    (todayData?["totalBreakTime"] ?? 0) +
                    totalBreakTime.inSeconds;
                int breakcnt = (todayData?["breakCount"] ?? 0) + breakCount;

                final supabase = Supabase.instance.client;
                User? currUser = OauthHelper.currentUser();

                if (todayData != null) {
                  // update breakCount
                  final response = await Provider.of<DatabaseHelperProvider>(
                    context,
                    listen: false,
                  ).updateBreakCount(
                    currUser.id,
                    breakcnt,
                    breakTime,
                    todayDate,
                  );

                  print("Data Updated with response");
                } else {
                  // insert
                  await supabase.from('attendance').insert({
                    'profile_id': currUser.id,
                    'date': todayDate,
                    'totalBreakTime': breakTime,
                    'breakCount': breakcnt,
                  });
                }

                print("Break Duration: ${breakDuration.inMinutes} min");
                print(
                  "Total Break Time Today: ${totalBreakTime.inMinutes} min",
                );

                // Reset
                leftOfficeTime = null;
                isOutside = false;
              }
            }
          }
        }
      },
    );
  }

  Future<bool> _isServiceEnable() async {
    ///Check location service isEnable or not
    if (!await Geolocator.isLocationServiceEnabled()) {
      Geolocator.openLocationSettings();
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _isLocationPermissionAllowed(BuildContext context) async {
    ///Check/request permission

    if (await _isServiceEnable()) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            CustomSnackbar.show(
              context: context,
              label: 'Can’t retrieve location—permission required.',
            );
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          CustomSnackbar.show(
            context: context,
            label: 'Location permanently denied',
            actionLabel: 'Settings',
            onAction: Geolocator.openAppSettings,
          );
        }
        return false;
      }

      return true;
    }
    return false;
  }
}
