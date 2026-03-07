import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:libriflow/features/home/presentation/providers/home_provider.dart';
import 'package:libriflow/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:libriflow/features/scanner/presentation/pages/qr_scanner_page.dart';
import 'package:libriflow/shared/utils/mysnackbar.dart';
import 'enhanced_dashboard_view.dart';
import 'search_view.dart';
import 'library_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _openScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null && context.mounted) {
      MySnackBar.show(
        context,
        message: "Scanned: ${result['code']}",
        background: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;
        final showRail = isDesktop || isTablet;

        return Scaffold(
          body: Row(
            children: [
              // Side Navigation Rail for tablets and desktops
              if (showRail)
                Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    return NavigationRail(
                      selectedIndex: homeProvider.currentIndex,
                      onDestinationSelected: (value) {
                        context.read<HomeProvider>().changeTab(value);
                      },
                      labelType: isDesktop
                          ? NavigationRailLabelType.all
                          : NavigationRailLabelType.selected,
                      backgroundColor: Colors.white,
                      elevation: 1,
                      leading: isDesktop
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 40,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'LibriFlow',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                      trailing: showRail && homeProvider.currentIndex != 3
                          ? Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: FloatingActionButton(
                                    onPressed: () => _openScanner(context),
                                    backgroundColor: Colors.blue.shade600,
                                    child: const Icon(Icons.qr_code_scanner),
                                  ),
                                ),
                              ),
                            )
                          : null,
                      selectedIconTheme: IconThemeData(
                        color: const Color(0xFF1A73E8),
                        size: isDesktop ? 28 : 24,
                      ),
                      unselectedIconTheme: IconThemeData(
                        color: Colors.grey.shade600,
                        size: isDesktop ? 26 : 24,
                      ),
                      selectedLabelTextStyle: TextStyle(
                        color: const Color(0xFF1A73E8),
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelTextStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isDesktop ? 13 : 11,
                        fontWeight: FontWeight.w500,
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.dashboard_rounded),
                          selectedIcon: Icon(Icons.dashboard_rounded),
                          label: Text('Dashboard'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search_rounded),
                          selectedIcon: Icon(Icons.search_rounded),
                          label: Text('Search'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.library_books_rounded),
                          selectedIcon: Icon(Icons.library_books_rounded),
                          label: Text('Library'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: Text('Profile'),
                        ),
                      ],
                    );
                  },
                ),
              
              // Vertical Divider
              if (showRail)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                ),
              
              // Main Content
              Expanded(
                child: Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    return IndexedStack(
                      index: homeProvider.currentIndex,
                      children: const [
                        EnhancedDashboardView(),
                        SearchView(),
                        LibraryView(),
                        ProfileSettingsPage(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: isMobile
              ? Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    // Hide FAB on profile page
                    if (homeProvider.currentIndex == 3) {
                      return const SizedBox.shrink();
                    }
                    
                    return FloatingActionButton.extended(
                      onPressed: () => _openScanner(context),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan'),
                      backgroundColor: Colors.blue.shade600,
                    );
                  },
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: isMobile
              ? Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: BottomNavigationBar(
                        currentIndex: homeProvider.currentIndex,
                        onTap: (value) {
                          context.read<HomeProvider>().changeTab(value);
                        },
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        selectedItemColor: const Color(0xFF1A73E8),
                        unselectedItemColor: Colors.grey.shade600,
                        selectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        items: [
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: homeProvider.currentIndex == 0
                                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.dashboard_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            activeIcon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.dashboard_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            label: 'Dashboard',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: homeProvider.currentIndex == 1
                                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            activeIcon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            label: 'Search',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: homeProvider.currentIndex == 2
                                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.library_books_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            activeIcon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.library_books_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            label: 'Library',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: homeProvider.currentIndex == 3
                                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            activeIcon: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                            label: 'Profile',
                          ),
                        ],
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}