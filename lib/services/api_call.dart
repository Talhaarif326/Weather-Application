import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  ApiCall talha = ApiCall();
  await talha.apiCall();
  print('Done');
}

class ApiCall {
  final String apiKey = 'c88be2fef6c73b774cc2520804b351a';
  final double lat = 34.5075;
  final double lon = 71.8986;
  Map<String, dynamic> result = {};

  Future<void> apiCall() async {
    final Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=34.5075&lon=71.8986&appid=c88be2fef6c73b774bcc2520804b351a',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {

      result = {'Name': data["name"]};
      print(result["Name"]);
    }
  }
}
