import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/models/paymentdurationmodel.dart';
import 'package:kologsoft/screens/payment_duration_reg.dart';
import 'package:provider/provider.dart';

import '../providers/Datafeed.dart';

class PaymentDurationView extends StatefulWidget {
  const PaymentDurationView({super.key});

  @override
  State<PaymentDurationView> createState() => _PaymentDurationViewState();
}

class _PaymentDurationViewState extends State<PaymentDurationView> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> _getPaymentDuration() async {
    QuerySnapshot snapshot = await db.collection('paymentdurationreg').get();
    return snapshot.docs;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text("REGISTERED PAYMENT DURATIONS"),
        backgroundColor: const Color(0xFF1B263B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _getPaymentDuration(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No payment duration found.",
                    style: TextStyle(color: Colors.white70, fontSize: 16)));
          }

          final docs = snapshot.data!;


          final payments = docs
              .map((doc) => PaymentDurationModel.fromJson(
            doc.data() as Map<String, dynamic>,
          ))
              .toList();

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: 700
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: payments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final payment = payments[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF182232),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.store, color: Colors.blue),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.paymentname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Duration: ${payment.duration}",
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // IconButton(
                        //   icon: const Icon(Icons.arrow_forward_ios,
                        //       color: Colors.white54, size: 18),
                        //   onPressed: () {},
                        // ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentDurationReg(payment: payment),
                                  ),
                                ).then((_) => setState(() {})); // refresh after edit
                              },
                              child: const Icon(Icons.edit, color: Colors.orange),
                            ),

                            SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Branch"),
                                    content: Text("Delete ${payment.paymentname}?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  final datafeed = Provider.of<Datafeed>(context, listen: false);
                                  await datafeed.deletePaymentDuration(payment.id);

                                  setState(() {});
                                }
                              },
                              child: const Icon(Icons.delete_forever, color: Colors.red),
                            ),

                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          );

        },
      ),
    );
  }
}
