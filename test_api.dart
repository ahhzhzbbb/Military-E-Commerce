import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.post(
    Uri.parse('http://128.199.87.51:8001/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'testuser123',
      'password': 'password123',
      'phone': '0987654321',
      'device_id': 'test'
    })
  );
  print('Signup: ${res.body}');

  final resLogin = await http.post(
    Uri.parse('http://128.199.87.51:8001/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'phone': '0987654321',
      'password': 'password123',
      'device_id': 'test'
    })
  );
  print('Login: ${resLogin.body}');
  
  final token = jsonDecode(resLogin.body)['data']['access_token'];
  
  final resProv = await http.get(
    Uri.parse('http://128.199.87.51:8001/order/provinces'),
    headers: {'Authorization': 'Bearer $token'}
  );
  print('Provinces: ${resProv.body}');

  final resWard = await http.get(
    Uri.parse('http://128.199.87.51:8001/order/wards?province_id=1'),
    headers: {'Authorization': 'Bearer $token'}
  );
  print('Wards for Prov 1: ${resWard.body}');
}
