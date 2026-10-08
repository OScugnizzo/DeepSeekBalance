import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/balance_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'theme/app_theme.dart';

class DeepSeekBalanceApp extends StatelessWidget {
  const DeepSeekBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BalanceProvider>(
          create: (_) => BalanceProvider(
            apiService: ApiService(),
            storageService: SecureStorageService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'DeepSeek Balance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
