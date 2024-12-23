import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:concept_nhv/main.dart';
// import 'package:path/path.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const App());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  var dio = Dio(BaseOptions(
    validateStatus: (status) {
      // code 404 is expected in the following test
      return status != null && status < 500;
    },
    receiveTimeout: const Duration(seconds: 3),
  ));
  // recent comic mid, as of 20241223
  var testmid = '3166275';
  group('test image subdomain status with mid $testmid', () {
    var subdomain1 = ['t1', 't2', 't3', 't4', 't'];
    var subdomain2 = ['i1', 'i2', 'i3', 'i4', 'i'];

    for (var d in subdomain1) {
      var testdomain = "$d.nhentai.net";
      var testurl = "https://$d.nhentai.net/galleries/$testmid/thumb.webp";

      // test dns and http request
      test('test thumbnail subdomain $d', () {
        debugPrint('test $testurl');
        expectLater(InternetAddress.lookup(testdomain), completion(isNotEmpty));
        expectLater(
          dio.get(testurl),
          completion(
            predicate((Response response) {
              debugPrint('response code: ${response.statusCode}');
              return response.statusCode == 200;
            }),
          ),
        );
      });
    }

    for (var d in subdomain2) {
      var testdomain = "$d.nhentai.net";
      var testurl = "https://$d.nhentai.net/galleries/$testmid/1.webp";

      // test dns and http request
      test('test inner page subdomain $d', () {
        debugPrint('test $testurl');
        expectLater(InternetAddress.lookup(testdomain), completion(isNotEmpty));
        expectLater(
          dio.get(testurl),
          completion(
            predicate((Response response) => response.statusCode == 200),
          ),
        );
      });
    }
  });
}
