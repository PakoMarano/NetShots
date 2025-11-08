import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netshots/data/repositories/auth_repository.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/services/image/image_storage_service_mock.dart';
import 'package:netshots/data/repositories/image_storage_repository.dart';
import 'package:netshots/data/services/auth/auth_service_mock.dart';
import 'package:netshots/data/services/profile/profile_service_mock.dart';
import 'package:netshots/ui/auth/login/login_viewmodel.dart';
import 'package:netshots/ui/auth/logout/logout_viewmodel.dart';
import 'package:netshots/ui/auth/register/register_viewmodel.dart';
import 'package:netshots/ui/core/themes/theme.dart';
import 'package:netshots/ui/home/home_viewmodel.dart';
import 'package:netshots/ui/friends/friends_viewmodel.dart';
import 'package:netshots/ui/profile/create_profile/create_profile_screen.dart';
import 'package:netshots/ui/profile/create_profile/create_profile_viewmodel.dart';
import 'package:netshots/ui/profile/delete_profile/delete_profile_viewmodel.dart';
import 'package:netshots/ui/profile/profile_screen/profile_viewmodel.dart';
import 'package:netshots/ui/match/add_match_viewmodel.dart';
import 'package:netshots/ui/settings/settings_viewmodel.dart';
import 'package:netshots/ui/user_search/user_search_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/auth/login/login_screen.dart';
import 'package:netshots/data/services/match/match_service_mock.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/data/services/search/search_service_mock.dart';
import 'package:netshots/data/repositories/search_repository.dart';
import 'package:netshots/data/services/follow/follow_service_mock.dart';
import 'package:netshots/data/repositories/follow_repository.dart';
import 'package:netshots/ui/follow/follow_viewmodel.dart';
import 'ui/auth/register/register_screen.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences and repositories
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthServiceMock(prefs);
  final authRepository = AuthRepository(authService);
  final profileService = ProfileServiceMock(prefs);
  final profileRepository = ProfileRepository(profileService);
  final matchService = MatchServiceMock(prefs);
  final matchRepository = MatchRepository(matchService, profileService);
  final imageStorageService = ImageStorageServiceMock();
  final imageStorageRepository = ImageStorageRepository(imageStorageService);
  final searchService = MockSearchService();
  final searchRepository = SearchRepository(searchService);
  final followService = FollowServiceMock(prefs);
  final followRepository = FollowRepository(followService);

  runApp(MyApp(
    authRepository: authRepository, 
    profileRepository: profileRepository,
    imageStorageRepository: imageStorageRepository,
    matchRepository: matchRepository,
    searchRepository: searchRepository,
    followRepository: followRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final ImageStorageRepository imageStorageRepository;
  final MatchRepository matchRepository;
  final SearchRepository searchRepository;
  final FollowRepository followRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.imageStorageRepository,
    required this.matchRepository,
    required this.searchRepository,
    required this.followRepository,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determineInitialRoute(),
      builder: (context, snapshot) {
        // Show a loading indicator while determining the initial route
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final initialRoute = snapshot.data ?? '/login';

        return MultiProvider(
          providers: [
            // Repository providers 
            Provider<AuthRepository>.value(value: authRepository),
            Provider<ProfileRepository>.value(value: profileRepository),
            Provider<ImageStorageRepository>.value(value: imageStorageRepository),
            Provider<MatchRepository>.value(value: matchRepository),
        Provider<SearchRepository>.value(value: searchRepository),
        Provider<FollowRepository>.value(value: followRepository),
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
              create: (_) => FriendsViewModel(),
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
            initialRoute: initialRoute,
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/create-profile': (context) => const CreateProfileScreen(),
            },
          ),
        );
      },
    );
  }

  Future<String> _determineInitialRoute() async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (!isLoggedIn) {
      return '/login';
    }
    final profile = await profileRepository.getProfile();
    if (profile == null) {
      return '/create-profile';
    }
    return '/home';
  }
}
