import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/user/firebase_cloud_storage.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key, required this.userEmail});
  final String userEmail;

  @override
  State<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  late final FirebaseCloudStorage _userInfoService;

  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    _userInfoService = FirebaseCloudStorage();
    _stream = _userInfoService.fetchReceiptsByEmail(widget.userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: [${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No bills found'));
              }

              final receipts = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: receipts.length,
                itemBuilder: (context, index) {
                  final receipt = receipts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading:
                          const Icon(Icons.receipt_long, color: Colors.blue),
                      title: Text(
                        receipt['type'] ?? 'Bill',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Paid at: ' +
                            (receipt['paid_at'] != null
                                ? (receipt['paid_at'] is Timestamp
                                    ? DateFormat('MMMM d, yyyy - jm').format(
                                        (receipt['paid_at'] as Timestamp)
                                            .toDate())
                                    : receipt['paid_at'].toString())
                                : 'N/A'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        'GHS ${receipt['amount'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
