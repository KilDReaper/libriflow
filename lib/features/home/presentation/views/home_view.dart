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
    return Scaffold(
      body: Consumer<HomeProvider>(
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
      floatingActionButton: Consumer<HomeProvider>(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Consumer<HomeProvider>(
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
                      child: Icon(
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
      ),
    );
  }
}
