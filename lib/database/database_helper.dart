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

  /// Fetch user profile data from Supabase
  Future<void> fetchUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _profile = response;
      notifyListeners();
      _error = null;
    }  catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _setLoading(false);
    }
  }



  /// Fetch user attendance data from Supabase
  Future<void> fetchUserAttendance() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response = await supabase
          .from('attendance')
          .select()
          .eq('profile_id', userId);
      _attendance = response;
      notifyListeners();
      _error = null;
    }  catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _setLoading(false);
    }
  }


//Fetch the number of days worked in a given month
  Future<void> getDaysWorkedInMonth(String userId, DateTime monthDate) async {
    final supabase = Supabase.instance.client;

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
          final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(date).toLocal());
          attendanceDates.add(formattedDate);
        }
      }

      _getDaysWorkedInMonth = attendanceDates.length;
      notifyListeners();
    } catch (e) {
        print('Error: $e');

    }
  }








  Future<void> fetchUserAttendanceByDate(String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final response = await supabase
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
        final insertResponse = await supabase.from('attendance').insert({
          'profile_id': userId,
          'date': date,
          'totalBreakTime': 0,
        }).select().single();

        print('inserted data $insertResponse');
        _todayAttendance = insertResponse;
        notifyListeners();
      }
      _error = null;
    }  catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _setLoading(false);
    }
  }



  /// Update a specific field for the current user attendance
  Future<void> updateUserAttendanceField(String fieldKey, dynamic newValue) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;


    try {
      final response = await supabase
          .from('attendance')
          .update({fieldKey: newValue})
          .eq('id', userId);


      await fetchUserAttendance();
      notifyListeners();

      if (response.error != null) {
        _error = "Failed to update $fieldKey: ${response.error!.message}";
      } else {
        _error = null;
        // Refresh profile after successful update
        await fetchUserAttendance();
      }
    } catch (e) {
      _error = "Failed to update field: $e";
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

      if (response.error != null) {
        _error = "Failed to update $fieldKey: ${response.error!.message}";
      } else {
        _error = null;
        // Refresh profile after successful update
        await fetchUserProfile();
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


}
