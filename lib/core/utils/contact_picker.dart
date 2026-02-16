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

  static Future<List<Contact>> picks({bool allowMultiple = false}) async {
    if (!isSupported()) throw Exception('Contact Picker API tidak didukung di browser ini.');

    try {
      final nav = web.window.navigator as JSObject;
      final contactsApi = nav.getProperty('contacts'.toJS) as JSObject;

      final props = ['name', 'tel', 'email'].map((e) => e.toJS).toList().toJS;
      final options = {'multiple': allowMultiple}.jsify() as JSObject;

      final promise = contactsApi.callMethod('select'.toJS, props, options) as JSPromise;
      final JSArray result = await promise.toDart as JSArray;

      final List<JSAny?> dartList = result.toDart;
      final contacts = <Contact>[];

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
      throw 'Terjadi kesalahan pada proses import. Untuk pengalaman terbaik, silahkan gunakan browser Chrome.';
    }
  }
}

class Contact {
  const Contact({required this.name, required this.phone, this.email});

  final String name;
  final String phone;
  final String? email;
}
