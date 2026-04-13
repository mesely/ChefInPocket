import 'package:flutter_test/flutter_test.dart';

import 'package:chef_in_pocket_app/app.dart';

void main() {
  testWidgets('onboarding screen renders app title', (tester) async {
    await tester.pumpWidget(const ChefInPocketApp());

    expect(find.text('ChefInPocket'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
