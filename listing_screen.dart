import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ListingScreen extends StatefulWidget {
  @override
  _ListingScreenState createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final titleCtrl = TextEditingController();
  final feeCtrl = TextEditingController(text: '20');

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Listing')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Listing Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: feeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fee (Coins)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final fee = int.tryParse(feeCtrl.text) ?? 0;
                final ok = await state.submitListing(fee, titleCtrl.text);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Listing created!' : 'Not enough coins'),
                ));
              },
              child: Text('Submit Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
