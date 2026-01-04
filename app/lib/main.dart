import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netshots/data/repositories/auth_repository.dart';
import 'package:netshots/data/repositories/feed_repository.dart';
import 'package:netshots/data/repositories/follow_repository.dart';
import 'package:netshots/data/repositories/image_storage_repository.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/search_repository.dart';
import 'package:netshots/data/services/auth/auth_service_firebase.dart';
import 'package:netshots/data/services/feed/feed_service_http.dart';
import 'package:netshots/data/services/follow/follow_service_http.dart';
import 'package:netshots/data/services/image_storage/image_storage_service_firebase.dart';
import 'package:netshots/data/services/match/match_service_http.dart';
import 'package:netshots/data/services/profile/profile_service_http.dart';
import 'package:netshots/data/services/search/search_service_http.dart';
import 'package:netshots/ui/auth/login/login_viewmodel.dart';
import 'package:netshots/ui/auth/logout/logout_viewmodel.dart';
import 'package:netshots/ui/auth/register/register_viewmodel.dart';
import 'package:netshots/ui/core/themes/theme.dart';
import 'package:netshots/ui/follow/follow_viewmodel.dart';
import 'package:netshots/ui/friends/friends_viewmodel.dart';
import 'package:netshots/ui/home/home_viewmodel.dart';
import 'package:netshots/ui/match/add_match_viewmodel.dart';
import 'package:netshots/ui/profile/create_profile/create_profile_screen.dart';
import 'package:netshots/ui/profile/create_profile/create_profile_viewmodel.dart';
import 'package:netshots/ui/profile/delete_profile/delete_profile_viewmodel.dart';
import 'package:netshots/ui/profile/profile_screen/profile_viewmodel.dart';
import 'package:netshots/ui/home/settings/settings_viewmodel.dart';
import 'package:netshots/ui/friends/user_search/user_search_viewmodel.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'ui/auth/login/login_screen.dart';
import 'ui/auth/register/register_screen.dart';
import 'ui/home/home_screen.dart';

const String kBackendBaseUrl = "https://pakomarano.pythonanywhere.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize repositories and services
  final authService = AuthServiceFirebase(FirebaseAuth.instance);
  final authRepository = AuthRepository(authService);
  final profileService = ProfileServiceHttp(FirebaseAuth.instance, baseUrl: kBackendBaseUrl);
  final profileRepository = ProfileRepository(profileService);
  final matchService = MatchServiceHttp(FirebaseAuth.instance, baseUrl: kBackendBaseUrl);
  final matchRepository = MatchRepository(matchService, profileService);
  final imageStorageService = ImageStorageServiceFirebase(FirebaseStorage.instance);
  final imageStorageRepository = ImageStorageRepository(imageStorageService);
  final searchService = SearchServiceHttp(FirebaseAuth.instance, baseUrl: kBackendBaseUrl);
  final searchRepository = SearchRepository(searchService);
  final followService = FollowServiceHttp(FirebaseAuth.instance, baseUrl: kBackendBaseUrl);
  final followRepository = FollowRepository(followService);
  final feedService = FeedServiceHttp(FirebaseAuth.instance, baseUrl: kBackendBaseUrl);
  final feedRepository = FeedRepository(feedService);

  runApp(MyApp(
    authRepository: authRepository, 
    profileRepository: profileRepository,
    imageStorageRepository: imageStorageRepository,
    matchRepository: matchRepository,
    searchRepository: searchRepository,
    followRepository: followRepository,
    feedRepository: feedRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final ImageStorageRepository imageStorageRepository;
  final MatchRepository matchRepository;
  final SearchRepository searchRepository;
  final FollowRepository followRepository;
  final FeedRepository feedRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.imageStorageRepository,
    required this.matchRepository,
    required this.searchRepository,
    required this.followRepository,
    required this.feedRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            // Repository providers 
            Provider<AuthRepository>.value(value: authRepository),
            Provider<ProfileRepository>.value(value: profileRepository),
            Provider<ImageStorageRepository>.value(value: imageStorageRepository),
            Provider<MatchRepository>.value(value: matchRepository),
            Provider<SearchRepository>.value(value: searchRepository),
            Provider<FollowRepository>.value(value: followRepository),
            Provider<FeedRepository>.value(value: feedRepository),
            // ViewModel providers
            ChangeNotifierProvider<HomeViewModel>(
              create: (_) => HomeViewModel(),
            ),
            ChangeNotifierProvider<LoginViewModel>(
              create: (_) => LoginViewModel(authRepository),
            ),
            ChangeNotifierProvider<RegisterViewModel>(
              create: (_) => RegisterViewModel(authRepository),
            ),
            ChangeNotifierProvider<LogoutViewModel>(
              create: (_) => LogoutViewModel(authRepository),
            ),
            ChangeNotifierProvider<ProfileViewModel>(
              create: (_) => ProfileViewModel(profileRepository, imageStorageRepository, matchRepository),
            ),
            ChangeNotifierProvider<AddMatchViewModel>(
              create: (_) => AddMatchViewModel(matchRepository, imageStorageRepository, profileRepository),
            ),
            ChangeNotifierProvider<CreateProfileViewModel>(
              create: (context) {
                final viewModel = CreateProfileViewModel(profileRepository, authRepository);
                // Set a callback to reload the profile after creation
                // This ensures that the profile is updated in the ProfileViewModel
                viewModel.setOnProfileCreatedCallback(() {
                  final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
                  profileViewModel.forceReloadUserProfile();
                });
                return viewModel;
              },
            ),
            ChangeNotifierProvider<SettingsViewModel>(
              create: (_) => SettingsViewModel(authRepository),
            ),
            ChangeNotifierProvider<DeleteProfileViewModel>(
              create: (_) => DeleteProfileViewModel(profileRepository),
            ),
            ChangeNotifierProvider<FriendsViewModel>(
              create: (context) => FriendsViewModel(Provider.of<FeedRepository>(context, listen: false)),
            ),
            ChangeNotifierProvider<UserSearchViewModel>(
              create: (_) => UserSearchViewModel(searchRepository),
            ),
            ChangeNotifierProvider<FollowViewModel>(
              create: (context) => FollowViewModel(followRepository, Provider.of<AuthRepository>(context, listen: false))..init(),
            ),
          ],
          child: MaterialApp(
            title: 'NetShots',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: lightTheme,
            darkTheme: darkTheme,
            locale: const Locale('it', 'IT'),
            supportedLocales: const [
              Locale('it', 'IT'), 
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthGate(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/create-profile': (context) => const CreateProfileScreen(),
            },
          ),
        );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final profileRepository = Provider.of<ProfileRepository>(context, listen: false);

    return StreamBuilder<bool>(
      stream: authRepository.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = authSnapshot.data == true;

        if (!isLoggedIn) {
          return const LoginScreen();
        }

        return FutureBuilder(
          future: profileRepository.getProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profile = profileSnapshot.data;
            if (profile == null) {
              return const CreateProfileScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
