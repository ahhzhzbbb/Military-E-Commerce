import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resLogin = await http.post(
    Uri.parse('http://128.199.87.51:8001/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': '0866479111', 'password': 'password'})
  );
  final token = jsonDecode(resLogin.body)['data']['token'];
  
  final resOrders = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/get_list_purchases'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'index': 0, 'count': 10})
  );
  
  final resBody = jsonDecode(resOrders.body);
  final data = resBody['data'];
  List ordersData = [];
  if (data is List) ordersData = data;
  else if (data['purchases'] is List) ordersData = data['purchases'];
  else if (data['items'] is List) ordersData = data['items'];
  else if (data['list'] is List) ordersData = data['list'];
  else if (data['orders'] is List) ordersData = data['orders'];
  
  if (ordersData.isEmpty) {
    print('No orders found');
    return;
  }
  
  final orderId = ordersData.first['id'];
  print('Trying to cancel order: $orderId');

  final resCancel = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'id': orderId.toString(), 'reason': 'test reason'})
  );
  print('Cancel with id: ${resCancel.body}');
  
  final resCancel2 = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'purchase_id': orderId.toString(), 'reason': 'test reason'})
  );
  print('Cancel with purchase_id: ${resCancel2.body}');
}
