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
        theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
        home: const PosScreen(),
      ),
    );
  }
}
