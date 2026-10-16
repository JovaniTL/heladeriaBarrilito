import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pos_provider.dart';
import 'ui/screens/pos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeladeriaBarrilitoApp());
}

class HeladeriaBarrilitoApp extends StatelessWidget {
  const HeladeriaBarrilitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PosProvider())],
      child: MaterialApp(
        title: 'Heladería Barrilito',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F2C59),
            primary: const Color(0xFF0F2C59),
            secondary: const Color(0xFF00A8CC),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F2C59),
            foregroundColor: Colors.white,
          ),
        ),
        home: const PosScreen(),
      ),
    );
  }
}
