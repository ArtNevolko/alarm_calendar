import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/alarm/alarm_bloc.dart';
import 'bloc/premium/premium_bloc.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/screens/home/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init(); // уже есть ensurePermissions внутри
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AlarmBloc()..add(LoadAlarmsEvent())),
        BlocProvider(create: (context) => PremiumBloc()),
        BlocProvider(create: (context) => LocalizationBloc()),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localizationState) {
          return MaterialApp(
            navigatorKey: NotificationService.instance.navigatorKey,
            title: AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
