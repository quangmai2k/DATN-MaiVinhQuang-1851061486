import '../../../../model/market_development/user.dart';

checkDataWithUser(User? user, dynamic data, value) {
  if (user != null) {
    if (data != null) {
      return data;
    }
  }
  return value;
}

checkDataValue(dynamic data) {
  try {
    if (data != null) {
      return data;
    }
  } catch (e) {}

  return "Không có dữ liệu";
}
