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
            listTileTheme: Theme.of(context).listTileTheme.copyWith(
                  minVerticalPadding: 8,
                  subtitleTextStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Nunito'),
                  leadingAndTrailingTextStyle: Theme.of(context)
                          .listTileTheme
                          .leadingAndTrailingTextStyle
                          ?.copyWith(fontSize: 16) ??
                      TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontSize ??
                              14,
                          fontFamily: 'Nunito'),
                ),
            useMaterial3: true,
            fontFamily: 'Nunito'),
        home: const TabsPage());
  }
}
