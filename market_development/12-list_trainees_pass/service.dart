import 'dart:convert';

import '../../../../api.dart';
import '../../../forms/market_development/utils/funciton.dart';

Future<int> httpPostDiari(userId, statusUserId, statusUserIdAfter, content, context) async {
  try {
    var response = await httpPostDiariStatus(userId, statusUserId, statusUserIdAfter, content, context);
    var body = jsonDecode(response['body']);
    if (isNumber(body.toString())) {
      return body;
    }
  } catch (e) {
    print("Lỗi $e");
  }
  return -1;
}
