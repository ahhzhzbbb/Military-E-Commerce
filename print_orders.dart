import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE5NywidXNlcm5hbWUiOiIwODY2NDc5MTExIiwicm9sZSI6InNvbGRpZXIiLCJpYXQiOjE3ODIxMjgzODAsImV4cCI6MTc4MjczMzE4MH0.za-f335DcK92eKAOgMyWW1qg2is5YmQm9b60Li8g4_Y';
  final resOrders = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/get_list_purchases'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'index': 0, 'count': 50})
  );
  print(resOrders.body);
}
