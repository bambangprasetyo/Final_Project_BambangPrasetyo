import 'package:nfc_manager/nfc_manager.dart';

class NFCService {
  Future<bool> writeNfcTag(String data) async {
    try {
      if (!await NfcManager.instance.isAvailable()) return false;

      await NfcManager.instance.startSession(
        onDiscovered: (tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            NfcManager.instance.stopSession(
              errorMessage: 'Tag tidak bisa ditulis',
            );
            return;
          }
          final message = NdefMessage([NdefRecord.createText(data)]);
          await ndef.write(message);
          NfcManager.instance.stopSession();
        },
      );
      return true;
    } catch (e) {
      NfcManager.instance.stopSession(errorMessage: e.toString());
      return false;
    }
  }

  Future<String?> readNfcTag() async {
    try {
      if (!await NfcManager.instance.isAvailable()) return null;

      String? result;
      await NfcManager.instance.startSession(
        onDiscovered: (tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            NfcManager.instance.stopSession(errorMessage: 'Tag tidak terbaca');
            return;
          }
          final record = ndef.cachedMessage!.records.first;
          result =
              record.payload
                  .sublist(3)
                  .map((e) => String.fromCharCode(e))
                  .join();
          NfcManager.instance.stopSession();
        },
      );

      // Tunggu beberapa saat hingga sesi NFC selesai
      await Future.delayed(Duration(seconds: 5));
      return result;
    } catch (e) {
      NfcManager.instance.stopSession(errorMessage: e.toString());
      return null;
    }
  }
}
