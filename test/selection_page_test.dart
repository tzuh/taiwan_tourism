import 'package:flutter_test/flutter_test.dart';
import 'package:taiwantourism/main.dart';

void main() {
  testWidgets('City names test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('桃園市'), findsOneWidget);
    expect(find.text('新竹市'), findsOneWidget);
    expect(find.text('新竹縣'), findsOneWidget);
    expect(find.text('苗栗縣'), findsOneWidget);
    expect(find.text('臺中市'), findsOneWidget);
    expect(find.text('彰化縣'), findsOneWidget);
    expect(find.text('雲林縣'), findsOneWidget);
    expect(find.text('嘉義市'), findsOneWidget);
    expect(find.text('嘉義縣'), findsOneWidget);
    expect(find.text('臺南市'), findsOneWidget);
    expect(find.text('高雄市'), findsOneWidget);
    expect(find.text('基隆市'), findsOneWidget);
    expect(find.text('臺北市'), findsOneWidget);
    expect(find.text('新北市'), findsOneWidget);
    expect(find.text('宜蘭縣'), findsOneWidget);
    expect(find.text('花蓮縣'), findsOneWidget);
    expect(find.text('南投縣'), findsOneWidget);
    expect(find.text('臺東縣'), findsOneWidget);
    expect(find.text('屏東縣'), findsOneWidget);
    expect(find.text('連江縣'), findsOneWidget);
    expect(find.text('金門縣'), findsOneWidget);
    expect(find.text('澎湖縣'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
