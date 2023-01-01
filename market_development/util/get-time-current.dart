import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../../../../api.dart';

//lấy về bản ghi
httpGetCurrentTime(context) async {
  // print("aam ${securityModel.authorization!}");
  Map<String, String> headers = {
    'content-type': 'application/json,',
    'Access-Control-Allow-Origin': '*',
    "Access-Control-Allow-Methods": "GET, HEAD",
    "Access-Control-Allow-Headers": "Access-Control-Allow-Origin, Accept"
  };

  var response = await Dio().get(
    'http://worldtimeapi.org/api/timezone/Asia/BangKok',
  );
  print("aa" + response.toString());
  return response;
}

Future<dynamic> getCurrentTime(context) async {
  try {
    var response = await httpGetCurrentTime(context);
    return response.data;
  } catch (e) {
    return null;
  }
}
