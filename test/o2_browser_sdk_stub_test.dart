@TestOn('!browser')
library;

import 'package:test/test.dart';

import 'package:openobserve_flutter_rum_web/openobserve_flutter_rum_web.dart';

void main() {
  test('createO2BrowserSdk returns null outside the browser', () {
    expect(createO2BrowserSdk(), isNull);
  });
}
