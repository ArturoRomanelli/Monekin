import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            dividerTheme: const DividerThemeData(space: 0),
            colorSchemeSeed: const Color.fromARGB(255, 15, 51, 117),
            useMaterial3: true,
            fontFamily: 'Nunito'),
        home: const TabsPage());
  }
}
