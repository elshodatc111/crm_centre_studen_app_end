import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart'; // ← GetStorage import qilindi
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PaymartPage extends StatefulWidget {
  const PaymartPage({super.key});

  @override
  State<PaymartPage> createState() => _PaymartPageState();
}

class _PaymartPageState extends State<PaymartPage> {
  List<dynamic> _payments = [];
  bool _isLoading = true;
  final GetStorage _storage = GetStorage(); // ← Storage ochildi
  late String _token; // ← token endi initState ichida olinadi

  @override
  void initState() {
    super.initState();
    _token = _storage.read('token') ?? '';
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    if (_token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token topilmadi. Iltimos, login qiling.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('https://crm-center.atko.tech/api/user/paymart'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _payments = data['paymart'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${response.statusCode}')),
      );
    }
  }

  String formatAmount(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    final formatter = NumberFormat('#,###', 'uz');
    return '${formatter.format(amount)} so\'m';
  }

  String formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To‘lovlar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
          ? const Center(child: Text("To‘lovlar topilmadi"))
          : ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final pay = _payments[index];
          final amount = formatAmount(pay['amount']);
          final type = pay['paymart_type'] ?? 'Nomaʼlum';
          final created = formatDateTime(pay['created_at']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                amount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("To'lov turi: $type\nTo'lov vaqti: $created",style: TextStyle(fontWeight: FontWeight.w500),),
              leading: const Icon(Icons.attach_money, color: Colors.green),
              tileColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
