String getTodayYYYYMMDD() {
  var dateTimeObj = DateTime.now();

  String year = dateTimeObj.year.toString();

  String month = dateTimeObj.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  String day = dateTimeObj.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  String yyyymmdd = year + month + day;
  return yyyymmdd;
}

DateTime createDateTimeObj(String yyyymmdd) {
  int yyyy = int.parse(yyyymmdd.substring(0, 4));
  int mm = int.parse(yyyymmdd.substring(4, 6));
  int dd = int.parse(yyyymmdd.substring(6, 8));

  DateTime dateTimeObj = DateTime(yyyy, mm, dd);
  return dateTimeObj;
}

String dateTimeToYYYYMMDD(DateTime dateTime) {
  String year = dateTime.year.toString();

  String month = dateTime.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  String day = dateTime.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  String yyyymmdd = year + month + day;
  return yyyymmdd;
}
