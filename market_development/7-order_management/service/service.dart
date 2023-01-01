import 'dart:convert';

import '../../../../../api.dart';

Future<bool> updateStatusOrder(var requestBody, int id, context) async {
  try {
    var response = await httpPut(Uri.parse('/api/donhang/put/${id}'), requestBody, context); //Tra ve id
    if (jsonDecode(response['body']) == true) {
      return true;
    } else {
      return false;
    }
  } catch (_) {
    print("Fail!");
  }
  return false;
}
