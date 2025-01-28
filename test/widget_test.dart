import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expanse_tracker/main.dart';
import 'package:expanse_tracker/pages/profile_page.dart';

void main() {
  testWidgets('Main app launches with correct initial route',
      (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(const MaterialApp(home: MyApp()));

    // Tunggu animasi transisi atau splash screen selesai
    await tester.pumpAndSettle();

    // Periksa apakah halaman login muncul
    expect(find.text("Login"), findsOneWidget);
  });

  testWidgets('Main app navigates to HomePage when logged in',
      (WidgetTester tester) async {
    // Jalankan aplikasi langsung ke HomePage
    await tester.pumpWidget(const MaterialApp(home: MyApp()));

    // Tunggu hingga tampilan stabil
    await tester.pumpAndSettle();

    // Pastikan halaman Home muncul
    expect(find.text("Welcome back,"), findsOneWidget);
  });

  testWidgets('Profile page displays user information',
      (WidgetTester tester) async {
    // Jalankan halaman Profile secara langsung
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    // Pastikan informasi user muncul
    expect(find.text("User"), findsOneWidget);
    expect(find.text("user@example.com"), findsOneWidget);

    // Pastikan tombol Edit Profile ada
    expect(find.text("Edit Profile"), findsOneWidget);

    // Pastikan tombol Logout ada
    expect(find.text("Logout"), findsOneWidget);
  });
}
