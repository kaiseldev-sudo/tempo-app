import 'package:flutter/material.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/ledger/presentation/widgets/add_entry_modal.dart';
import '../../features/analysis/presentation/analysis_screen.dart'; // Import AnalysisScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LedgerScreen(),
    const AnalysisScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: SizedBox(
        width: 70, // Slightly wider/larger
        height: 70,
        child: FloatingActionButton(
          onPressed: () => AddEntryModal.show(context),
          backgroundColor: Colors.black,
          elevation: 0, // Flat premium look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Squircle shape
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 0, 
        padding: EdgeInsets.zero, // Remove default padding to allow border to stretch
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0), // Light grey border
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side - Ledger
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.book_outlined,
                  selectedIcon: Icons.book,
                  label: "Ledger",
                ),
              ),
              
              const SizedBox(width: 80), // Space for FAB
              
              // Right Side - Analysis
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.pie_chart_outline,
                  selectedIcon: Icons.pie_chart,
                  label: "Analysis",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

}
