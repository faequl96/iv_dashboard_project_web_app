import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

@JS()
extension type ContactInfo(JSObject _) implements JSObject {
  @JS('name')
  external JSArray<JSString>? get name;
  @JS('tel')
  external JSArray<JSString>? get tel;
  @JS('email')
  external JSArray<JSString>? get email;
}

class ContactPicker {
  static bool isSupported() => web.window.navigator.hasProperty('contacts'.toJS).toDart;

  static Future<List<Contact>> picks({bool allowMultiple = false, required void Function(String value) onPrint}) async {
    onPrint('test_1');
    if (!isSupported()) throw Exception('Contact Picker API tidak didukung di browser ini.');

    try {
      onPrint('test_2');
      final nav = web.window.navigator as JSObject;
      onPrint('test_3');
      final contactsApi = nav.getProperty('contacts'.toJS) as JSObject;
      onPrint('test_4');

      final props = ['name', 'tel', 'email'].map((e) => e.toJS).toList().toJS;
      onPrint('test_5');
      final options = {'multiple': allowMultiple}.jsify() as JSObject;
      onPrint('test_6');

      final promise = contactsApi.callMethod('select'.toJS, props, options) as JSPromise;
      onPrint('test_7');
      final JSArray result = await promise.toDart as JSArray;
      onPrint('test_8');

      final List<JSAny?> dartList = result.toDart;
      onPrint('test_9: ${dartList.length}');
      List<Contact> contacts = [];

      for (var item in dartList) {
        if (item != null) {
          final contactJS = item as ContactInfo;

          final name = (contactJS.name != null && contactJS.name!.toDart.isNotEmpty)
              ? contactJS.name!.toDart.first.toDart
              : 'Tanpa Nama';

          final phone = (contactJS.tel != null && contactJS.tel!.toDart.isNotEmpty)
              ? contactJS.tel!.toDart.first.toDart
              : 'No Number';

          String? email;
          if (contactJS.email != null && contactJS.email!.toDart.isNotEmpty) {
            email = contactJS.email!.toDart.first.toDart;
          }

          contacts.add(Contact(name: name, phone: phone, email: email));
        }
      }

      return contacts;
    } catch (e) {
      onPrint('test_10');
      print('User membatalkan atau terjadi error: $e');
      return [];
    }
  }
}

class Contact {
  const Contact({required this.name, required this.phone, this.email});

  final String name;
  final String phone;
  final String? email;
}
