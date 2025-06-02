// lib/screens/home_manager.dart
import 'package:flutter/material.dart';
import '../service/nfc_service.dart';

class HomeManager extends StatefulWidget {
  const HomeManager({super.key});

  @override
  State<HomeManager> createState() => _HomeManagerState();
}

class _HomeManagerState extends State<HomeManager> {
  final _nfcService = NFCService();
  final _assignmentController = TextEditingController();
  String _status = '';

  void _writeToNFC() async {
    final text = _assignmentController.text;
    if (text.isEmpty) return;

    final success = await _nfcService.writeNfcTag(text);
    setState(() => _status = success ? 'Write successful' : 'Write failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Write Assignment to NFC'),
            TextField(
              controller: _assignmentController,
              decoration: const InputDecoration(
                labelText: 'Assignment ID or Info',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _writeToNFC,
              child: const Text('Write NFC'),
            ),
            const SizedBox(height: 8),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
