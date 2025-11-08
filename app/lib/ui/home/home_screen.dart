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
    try {
      _homeVm?.removeListener(_onHomeVmChanged);
    } catch (_) {}
    _pageController.dispose();
    super.dispose();
  }

  void _onHomeVmChanged() {
    if (!mounted) return;
    final idx = _homeVm?.currentIndex ?? 0;
    final int targetPage = idx < 0 ? 0 : (idx > 1 ? 1 : idx);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep FAB visible when keyboard appears (especially on Friends search)
      resizeToAvoidBottomInset: false,
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
              viewModel.setCurrentIndex(index);
            },
            children: const [
              FriendsScreen(),
              ProfileScreen(),
            ],
          );
        },
      ),

      floatingActionButton: Transform.translate(
        offset: const Offset(0, 6),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.75,
                  minChildSize: 0.4,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: const AddMatchScreen(showAppBar: false),
                        ),
                      ),
                    );
                  },
                );
              },
            );

            if (result == true) {
              try {
                final vm = Provider.of<HomeViewModel>(context, listen: false);
                vm.setCurrentIndex(1);
              } catch (_) {}
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          final bool leftActive = viewModel.currentIndex == 0;
          final bool rightActive = viewModel.currentIndex == 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              BottomAppBar(
                elevation: 8.0,
                shape: const CircularNotchedRectangle(),
                notchMargin: 6.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.transparent),
                        onPressed: () {
                          viewModel.setCurrentIndex(0);
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: Column(
                            key: ValueKey<bool>(leftActive),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group,
                                color: leftActive ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Amici',
                                style: TextStyle(
                                  color: leftActive ? Theme.of(context).primaryColor : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.transparent),
                        onPressed: () {
                          viewModel.setCurrentIndex(1);
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: Column(
                            key: ValueKey<bool>(rightActive),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                color: rightActive ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Profilo',
                                style: TextStyle(
                                  color: rightActive ? Theme.of(context).primaryColor : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}