import 'package:campus_connect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('department and category filters work independently', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.tap(find.text('Super admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview super admin screens'));
    await tester.tap(find.text('Preview super admin screens'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View all'));
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('super_category')));
    await tester.tap(find.byKey(const Key('super_category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('super_department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medical Department').last);
    await tester.pumpAndSettle();
    expect(find.text('Extend library hours during exams'), findsOneWidget);
    expect(find.text('Study room lights are broken'), findsNothing);
    await tester.tap(find.byKey(const Key('super_department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS Department').last);
    await tester.pumpAndSettle();
    expect(find.text('Study room lights are broken'), findsOneWidget);
    expect(find.text('Extend library hours during exams'), findsNothing);
  });
  testWidgets('super admin preview fits a phone screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.tap(find.text('Super admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview super admin screens'));
    await tester.tap(find.text('Preview super admin screens'));
    await tester.pumpAndSettle();
    expect(find.text('Campus overview'), findsOneWidget);
    await tester.tap(find.text('Complaints').last);
    await tester.pumpAndSettle();
    expect(find.text('All complaints'), findsOneWidget);
  });
  testWidgets('super admin can filter complaints without a search box', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.tap(find.text('Super admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview super admin screens'));
    await tester.tap(find.text('Preview super admin screens'));
    await tester.pumpAndSettle();
    expect(find.text('Campus overview'), findsOneWidget);
    expect(find.text('Complaints by department'), findsOneWidget);
    await tester.ensureVisible(find.text('View all'));
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('super_search')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('super_status')));
    await tester.tap(find.byKey(const Key('super_status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolved').last);
    await tester.pumpAndSettle();
    expect(find.text('Extend library hours during exams'), findsOneWidget);
    expect(find.text('Study room lights are broken'), findsNothing);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Study room lights are broken'), findsOneWidget);
  });
  testWidgets('student home keeps complaint entries on the complaints page', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    expect(find.text('Make campus better.'), findsOneWidget);
    await tester.ensureVisible(find.text('Preview student screens'));
    await tester.tap(find.text('Preview student screens'));
    await tester.pumpAndSettle();
    expect(find.text('Student dashboard'), findsOneWidget);
    expect(find.text('Recent complaints'), findsNothing);
    expect(find.text('Wi-Fi keeps disconnecting in Lab 2'), findsNothing);
    await tester.tap(find.text('Complaints').last);
    await tester.pumpAndSettle();
    expect(find.text('My complaints'), findsOneWidget);
    expect(find.text('Wi-Fi keeps disconnecting in Lab 2'), findsOneWidget);
  });

  testWidgets('category selection shows its routed department', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.ensureVisible(find.text('Preview student screens'));
    await tester.tap(find.text('Preview student screens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New complaint').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Library'));
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('complaint_department')));
    await tester.tap(find.byKey(const Key('complaint_department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medical Department').last);
    await tester.pumpAndSettle();
    expect(find.text('Routed to Medical Department · Library'), findsOneWidget);
    await tester.tap(find.byKey(const Key('complaint_department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS Department').last);
    await tester.pumpAndSettle();
    expect(find.text('Routed to CS Department · Library'), findsOneWidget);
  });

  testWidgets('student can preview a submitted complaint', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.ensureVisible(find.text('Preview student screens'));
    await tester.tap(find.text('Preview student screens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New complaint').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cafeteria'));
    await tester.ensureVisible(find.byKey(const Key('complaint_department')));
    await tester.tap(find.byKey(const Key('complaint_department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS Department').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cafeteria'));
    await tester.tap(find.text('Cafeteria'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('complaint_title')),
      'Cold food',
    );
    await tester.enterText(
      find.byKey(const Key('complaint_details')),
      'Lunch was served cold today.',
    );
    await tester.ensureVisible(find.text('Submit complaint'));
    await tester.tap(find.text('Submit complaint'));
    await tester.pumpAndSettle();
    expect(find.text('Cold food'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('department admin opens only the selected department', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.tap(find.text('Department admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview department admin screens'));
    await tester.tap(find.text('Preview department admin screens'));
    await tester.pumpAndSettle();
    expect(find.text('Department dashboard'), findsOneWidget);
    expect(find.text('CS Department'), findsWidgets);
    expect(find.text('Medical Department'), findsNothing);
  });

  testWidgets('department admin can save a status and remark in preview', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusConnectApp(preview: true));
    await tester.tap(find.text('Department admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview department admin screens'));
    await tester.tap(find.text('Preview department admin screens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View complaints').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study room lights are broken'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('admin_status')));
    await tester.tap(find.byKey(const Key('admin_status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In progress').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('admin_remark')),
      'Electrician notified.',
    );
    await tester.ensureVisible(find.text('Save update'));
    await tester.tap(find.text('Save update'));
    await tester.pumpAndSettle();
    expect(find.text('Electrician notified.'), findsWidgets);
    expect(find.text('In progress'), findsWidgets);
  });
}
