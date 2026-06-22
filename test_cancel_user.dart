import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE5NywidXNlcm5hbWUiOiIwODY2NDc5MTExIiwicm9sZSI6InNvbGRpZXIiLCJpYXQiOjE3ODIxMjgzODAsImV4cCI6MTc4MjczMzE4MH0.za-f335DcK92eKAOgMyWW1qg2is5YmQm9b60Li8g4_Y';
  
  // Get orders to find a valid order to cancel
  final resOrders = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/get_list_purchases'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'index': 0, 'count': 50})
  );
  
  final resBody = jsonDecode(resOrders.body);
  final data = resBody['data'];
  List ordersData = [];
  if (data is List) ordersData = data;
  else if (data['purchases'] is List) ordersData = data['purchases'];
  else if (data['items'] is List) ordersData = data['items'];
  else if (data['list'] is List) ordersData = data['list'];
  else if (data['orders'] is List) ordersData = data['orders'];
  
  print('Total orders fetched: ${ordersData.length}');
  
  final validOrder = ordersData.firstWhere(
    (o) => o['status'] == 'pending' || o['status'] == 'confirmed', 
    orElse: () => ordersData.isNotEmpty ? ordersData.first : null
  );
  
  if (validOrder == null) {
    print('No orders found to test cancellation.');
    return;
  }
  
  final orderId = validOrder['id'] ?? validOrder['purchase_id'] ?? validOrder['order_id'];
  print('Testing cancel on order: $orderId (Current status: ${validOrder['status']})');

  // Try 1: Exact CancelOrderDto from api.json
  var res = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'id': orderId.toString(), 'reason': 'test reason 1'})
  );
  print('Try 1 (id, reason): ${res.body}');
  
  // Try 2: order_id
  res = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'order_id': orderId.toString(), 'reason': 'test reason 2'})
  );
  print('Try 2 (order_id, reason): ${res.body}');
  
  // Try 3: purchase_id
  res = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'purchase_id': orderId.toString(), 'reason': 'test reason 3'})
  );
  print('Try 3 (purchase_id, reason): ${res.body}');
  
  // Try 4: number instead of string for id
  res = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'id': int.tryParse(orderId.toString()) ?? orderId, 'reason': 'test reason 4'})
  );
  print('Try 4 (id as number, reason): ${res.body}');

  // Try 5: only id
  res = await http.post(
    Uri.parse('http://128.199.87.51:8001/order/cancel_order'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'id': orderId.toString()})
  );
  print('Try 5 (only id): ${res.body}');
}
