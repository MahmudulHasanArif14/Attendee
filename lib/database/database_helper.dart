import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelperProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;
  late int _getDaysWorkedInMonth = 0;
  int get workedDaysCount => _getDaysWorkedInMonth;
  List<Map<String, dynamic>>? _attendance;
  List<Map<String, dynamic>>? get attendance => _attendance;

  Map<String, dynamic>? _todayAttendance;
  Map<String, dynamic>? get todayAttendance => _todayAttendance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Fetch user profile all data from Supabase
  Future<void> fetchUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();
      _profile = response;
      notifyListeners();
      _error = null;
    } catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch user all attendance data of curruser from Supabase
  Future<void> fetchUserAttendance() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response = await supabase
          .from('attendance')
          .select()
          .eq('profile_id', userId).order('check_in_time', ascending: true);
      print('Attendance query response: $response');



      _attendance = [];

      for (var record in response) {

        try{
          print("attendance got $_attendance");
          if (record['check_in_time'] != null) {
            final checkIn = DateTime.parse(record['check_in_time']).toLocal();
            bool isChecked=record['status']??false;
            _attendance?.add({
              "icon": Icons.login,
              "title": "Check In",
              "date": DateFormat('EEEE,d MMMM,yyyy').format(checkIn),
              "time": DateFormat('hh:mm a').format(checkIn),
              "status": isChecked? "On Time" : "Late Check-In",
            });
          }


          if (record['check_out_time'] != null) {
            final checkOut = DateTime.parse(record['check_out_time']).toLocal();
            _attendance?.add({
              "icon": Icons.logout,
              "title": "Check Out",
              "date": DateFormat('EEEE,d MMMM,yyyy').format(checkOut),
              "time": DateFormat('hh:mm a').format(checkOut),
              "status": "Checked Out",
            });
          }

          if(record['totalBreakTime']!=null){
            //Duration Getting from Second
            String formatDuration(int totalSeconds) {
              final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
              final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
              final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
              return '$hours:$minutes:$seconds';
            }
            final dateStr =record['date'];
            final breakTimeSec=record['totalBreakTime'] ?? 0;

            DateTime date;
            try {
              date = dateStr != null
                  ? DateTime.parse(dateStr).toLocal()
                  : DateTime.now();
            } catch (e) {
              date = DateTime.now();
            }



            final breakTime=formatDuration(breakTimeSec);
            _attendance?.add({
              "icon": Icons.lunch_dining,
              "title": "Total Break Time",
              "date": DateFormat('EEEE,d MMMM,yyyy').format(date),
              "time": breakTime,
              "status": record['check_out_time'] != null ? "Checked Out": "Not Checked Out Yet",
            });


          }
          print('Processed attendance list: $_attendance');
          notifyListeners();

        }
        catch(e){
          print("attendance fetching error got ${e.toString()}");
        }

        notifyListeners();
      }
      _error = null;
    } catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _setLoading(false);
    }
  }

  ///Update checkIN and out status

  Future<void> updateStatus(
    bool value,
    String profileId,
    String dateString,
  ) async {
    try {
      final _ = await supabase
          .from('attendance')
          .update({'status': value})
          .eq('profile_id', profileId)
          .eq('date', dateString);

      await fetchUserAttendanceByDate(dateString);
      await fetchUserAttendance();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  //Fetch the number of days worked in a given month
  Future<void> getDaysWorkedInMonth(String userId, DateTime monthDate) async {
    final startDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);

    try {
      final response = await supabase
          .from('attendance')
          .select('date')
          .eq('profile_id', userId)
          .gte('date', startDayOfMonth.toIso8601String())
          .lte('date', endDayOfMonth.toIso8601String());

      final attendanceDates = <String>{};

      for (var record in response) {
        final date = record['date'];
        if (date != null) {
          final formattedDate = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.parse(date).toLocal());
          attendanceDates.add(formattedDate);
        }
      }

      _getDaysWorkedInMonth = attendanceDates.length;
      notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
  }

  ///updateAttendance
  Future<void> updateAttendance({
    required String profileId,
    required DateTime checkInTime,
    required String dateString,
  }) async {
    try {
      final _ = await supabase
          .from('attendance')
          .update({
            'check_in_time': checkInTime.toIso8601String(),
            'profile_id': profileId,
            'date': dateString,
          })
          .eq('profile_id', profileId)
          .eq('date', dateString);

      await fetchUserAttendanceByDate(dateString);
      await fetchUserAttendance();
      notifyListeners();
    } catch (e) {
      // Handle error here if you want
      print('Error updating attendance: $e');
      return;
    }
  }

  bool _isUpdated = false;
  bool get isUpdated => _isUpdated;

  ///Update CheckOut
  Future<void> updateCheckout(
    String profileId,
    DateTime today,
    Duration totalBreakDuration,
    String todayDate,
  ) async {
    try {
      final response = await supabase
          .from('attendance')
          .update({
            'check_out_time': today.toIso8601String(),
            'totalBreakTime': totalBreakDuration.inSeconds,
          })
          .eq('profile_id', profileId)
          .eq('date', todayDate);

      _isUpdated = true;
      print("Checked OUT DONE");
      print(response);
      await fetchUserAttendanceByDate(todayDate);
      await fetchUserAttendance();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  ///update breakCount

  Future<void> updateBreakCount(
    String profileId,
    int breakCount,
    int totalBreakDuration,
    String todayDate,
  ) async {
    try {
      final response = await supabase
          .from('attendance')
          .update({
            'breakCount': breakCount,
            'totalBreakTime': totalBreakDuration,
          })
          .eq('profile_id', profileId)
          .eq('date', todayDate);

      await fetchUserAttendanceByDate(todayDate);
      await fetchUserAttendance();
      notifyListeners();
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  Future<void> insertBreakCount(
    String profileId,
    int breakCount,
    int totalBreakDuration,
    String todayDate,
  ) async {
    try {
      final response = await supabase.from('attendance').insert({
        'profile_id': profileId,
        'date': todayDate,
        'totalBreakTime': totalBreakDuration,
        'breakCount': breakCount,
      });

      await fetchUserAttendanceByDate(todayDate);
      await fetchUserAttendance();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return;
    }
  }

  Future<void> fetchUserAttendanceByDate(String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response =
          await supabase
              .from('attendance')
              .select()
              .eq('profile_id', userId)
              .eq('date', date)
              .maybeSingle();
      if (response != null) {
        _todayAttendance = response;
        notifyListeners();
        print('updated $_todayAttendance["totalBreakTime"]');
      } else {
        final insertResponse =
            await supabase
                .from('attendance')
                .insert({
                  'profile_id': userId,
                  'date': date,
                  'totalBreakTime': 0,
                })
                .select()
                .single();

        print('inserted data $insertResponse');
        _todayAttendance = insertResponse;
        notifyListeners();
      }
      _error = null;
    } catch (e) {
      _error = "Failed to fetch attendance: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Update a specific field for the current user
  Future<void> updateUserField(String fieldKey, dynamic newValue) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .update({fieldKey: newValue})
          .eq('id', userId);

      await fetchUserProfile();
      notifyListeners();

      if (response == null) {
        _error = "Failed to update $fieldKey: ${response.error!.message}";
      } else {
        _error = null;
      }
    } catch (e) {
      _error = "Failed to update field: $e";
    }
  }

  /// Handle loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  void clearData() {
    _profile = null;
    _attendance = null;
    _todayAttendance = null;
    _error = null;
    _getDaysWorkedInMonth = 0;
    _isLoading = false;
    _isUpdated = false;
    notifyListeners();
  }





}
