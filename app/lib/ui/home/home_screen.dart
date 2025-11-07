import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/home/home_viewmodel.dart';
import 'package:netshots/ui/friends/friends_screen.dart';
import 'package:netshots/ui/match/add_match_screen.dart';
import 'package:netshots/ui/profile/profile_screen/profile_screen.dart';
import 'package:netshots/ui/settings/settings_drawer.dart';
import 'package:netshots/ui/follow_requests/follow_request_button.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  HomeViewModel? _homeVm;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Attach a listener to HomeViewModel after the first frame so we can
    // animate the PageController when the view model index changes programmatically.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _homeVm = Provider.of<HomeViewModel>(context, listen: false);
        _homeVm?.addListener(_onHomeVmChanged);
      } catch (_) {
        _homeVm = null;
      }
    });
  }

  @override
  void dispose() {
    // Remove listener if added
    try {
      _homeVm?.removeListener(_onHomeVmChanged);
    } catch (_) {}
    _pageController.dispose();
    super.dispose();
  }

  void _onHomeVmChanged() {
    if (!mounted) return;
    final idx = _homeVm?.currentIndex ?? 0;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        idx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NetShots"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: const [
          FollowRequestButton(),
        ],
      ),
      drawer: const SettingsDrawer(),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // Aggiorna l'indice nel ViewModel quando l'utente fa swipe
              viewModel.setCurrentIndex(index);
            },
            children: const [
              FriendsScreen(),
              AddMatchScreen(),
              ProfileScreen(),
            ],
          );
        }
      ),
      bottomNavigationBar: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return BottomNavigationBar(
            currentIndex: viewModel.currentIndex,
            onTap: (index) {
              // Aggiorna sia il ViewModel che il PageController
              viewModel.setCurrentIndex(index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Amici',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Aggiungi partita',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profilo',
              ),
            ],
          );
        },
      ),
    );
  }
}