import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sehatinapp/bloc/like/like_event.dart';
import 'package:sehatinapp/screen/page/riwayat_mood.dart';
import 'package:sehatinapp/screen/splash_screen.dart';
import 'package:sehatinapp/screen/login_screen.dart';
import 'package:sehatinapp/screen/register_screen.dart';
import 'package:sehatinapp/screen/page/homePage.dart';
import 'package:sehatinapp/screen/page/editProfilePage.dart';
import 'package:sehatinapp/screen/page/isi_mood.dart';
import 'package:sehatinapp/screen/page/mood_kalender.dart';
import 'package:sehatinapp/bloc/like/like_bloc.dart';
import 'package:sehatinapp/bloc/loginn/login_bloc.dart';
import 'package:sehatinapp/bloc/logout/logout_bloc.dart';
import 'package:sehatinapp/bloc/register/register_bloc.dart';
import 'package:sehatinapp/cubit/user_cubit.dart';
import 'package:sehatinapp/bloc/mood/mood_bloc.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/datasource/like_repo.dart';
import 'package:sehatinapp/data/datasource/mood_repo.dart';
import 'package:sehatinapp/screen/page/activity_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await initializeDateFormatting('id_ID', null);

  final authRepository = AuthRepository();
  final baseUrl = 'https://sehatin.site';
  final moodRepository = MoodRepository(authRepository: authRepository, baseUrl: baseUrl);
  final likeRepository = LikeRepository(authRepository: authRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<MoodRepository>.value(value: moodRepository),
        Provider<LikeRepository>.value(value: likeRepository),

        ChangeNotifierProvider(create: (_) => ActivityData()),

        BlocProvider<LoginBloc>(create: (_) => LoginBloc(authRepository: authRepository)),
        BlocProvider<LogoutBloc>(create: (_) => LogoutBloc(authRepository: authRepository)),
        BlocProvider<RegisterBloc>(create: (_) => RegisterBloc(authRepository: authRepository)),
        BlocProvider<UserCubit>(create: (_) => UserCubit()..loadUserData()),
        BlocProvider<LikeBloc>(create: (_) => LikeBloc(likeRepository: likeRepository)..add(LoadLikedArticlesEvent())),
        BlocProvider<MoodBloc>(create: (_) => MoodBloc(repository: moodRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sehatin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/edit-profile': (context) => const EditProfilePage(),

        '/isi-mood': (context) => IsiMoodPage(
              moodRepository: Provider.of<MoodRepository>(context, listen: false),
            ),

        '/mood-calendar': (context) => MoodCalendarPage(),

        '/riwayatMoodpage': (context) => RiwayatMoodPage(),
      },
    );
  }
}
