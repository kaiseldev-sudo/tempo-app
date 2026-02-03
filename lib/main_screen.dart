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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final barColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFEEEEEE);

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
          backgroundColor: primaryColor,
          elevation: 0, // Flat premium look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Squircle shape
          ),
          child: Icon(Icons.add, color: onPrimaryColor, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: barColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 0, 
        padding: EdgeInsets.zero, // Remove default padding to allow border to stretch
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor, width: 1.0),
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
                  context: context,
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
                  context: context,
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
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? primaryColor : (isDark ? Colors.grey[500] : Colors.grey),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : (isDark ? Colors.grey[500] : Colors.grey),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

}
