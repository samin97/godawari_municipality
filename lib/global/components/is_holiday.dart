import 'package:intl/intl.dart';

isHoliday(){
  bool holiday;
  var weekday = DateFormat('EEEE').format(DateTime.now());
  if(weekday == "Saturday"){
    holiday = true;
    return holiday;
  }else{
    //check if holiday for other reasons;
    holiday = false;
    return holiday;
  }
}