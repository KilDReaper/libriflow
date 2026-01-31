import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libriflow/features/profile/presentation/pages/profile_settings_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'dashboard_view.dart';
import 'search_view.dart';
import 'library_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final index = state is HomeTabChanged ? state.currentIndex : 0;

        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              DashboardView(),
              SearchView(),
              LibraryView(),
              ProfileSettingsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) {
              context.read<HomeBloc>().add(ChangeTab(value));
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person), 
                label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
