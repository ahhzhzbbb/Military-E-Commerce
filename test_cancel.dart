import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resLogin = await http.post(
    Uri.parse('http://128.199.87.51:8001/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': '0866479111', 'password': 'password'})
  );
  final token = jsonDecode(resLogin.body)['data']['token'];
  
  // Try with reason
  final resCancel = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'id': '260', 'reason': 'test reason'})
  );
  print('Cancel with reason: ${resCancel.body}');
  
  // Try order_id but with reason
  final resCancel2 = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'order_id': '260', 'reason': 'test reason'})
  );
  print('Cancel order_id with reason: ${resCancel2.body}');
}
