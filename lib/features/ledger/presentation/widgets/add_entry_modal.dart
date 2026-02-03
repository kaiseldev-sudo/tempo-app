import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:tempo/features/ledger/domain/time_entry.dart';
import '../../../../features/gamification/presentation/providers/gamification_provider.dart';
import '../providers/ledger_provider.dart';

class AddEntryModal extends ConsumerStatefulWidget {
  const AddEntryModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEntryModal(),
    );
  }

  @override
  ConsumerState<AddEntryModal> createState() => _AddEntryModalState();
}

class _AddEntryModalState extends ConsumerState<AddEntryModal> {
  String _type = 'invested'; // invested, spent
  String _category = 'Work';
  int _durationMinutes = 60;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _investedCategories = ['Work', 'Study', 'Exercise', 'Reading', 'Creative'];
  final List<String> _spentCategories = ['Gaming', 'Social Media', 'TV', 'Oversleeping', 'Commute'];

  @override
  void initState() {
    super.initState();
    _titleController.text = "Work Session";
  }

  void _save() async {
    // 1. Capture all necessary state before closing the modal
    final title = _titleController.text;
    final notes = _notesController.text;
    final type = _type;
    final category = _category;
    final duration = _durationMinutes;
    final date = ref.read(selectedDateProvider);
    
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    final entrySaver = ref.read(addTimeEntryProvider);

    // 2. Close the modal immediately to avoid UI conflicts with badge modals
    if (mounted) {
      Navigator.pop(context);
    }

    int? xpEarned;
    List<String>? badgeIds;

    try {
      // 3. Trigger Gamification
      if (type == 'invested') {
        final result = await gamificationNotifier.processAction(
          type: 'focus_session',
          minutes: duration,
          sessionTime: date,
        );
        xpEarned = result['xpEarned'] as int?;
        badgeIds = List<String>.from(result['badgeIds'] ?? []);
      }

      // 4. Create and save entry
      final newEntry = TimeEntry(
        title: title,
        category: category,
        type: type,
        durationMinutes: duration,
        startTime: date,
        notes: notes,
        xpEarned: xpEarned,
        unlockedBadgeIds: badgeIds,
      );

      await entrySaver(newEntry);
    } catch (e) {
      debugPrint('Failed to save entry: $e');
      // For a better UX, we could use a global snackbar here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'invested' ? _investedCategories : _spentCategories;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final inputFillColor = isDark ? Colors.grey[800] : Colors.grey[50];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: textColor,
                ),
                Expanded(
                  child: Text(
                    "New Entry",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor
                        ),
                  ),
                ),
                const SizedBox(width: 48), // Balance close button
              ],
            ),
            const Gap(24),
  
            // Type Selector
            Row(
              children: [
                _buildTypeButton(context, 'invested', "Invested"),
                const Gap(12),
                _buildTypeButton(context, 'spent', "Spent"),
              ],
            ),
            const Gap(24),
  
            // Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_durationMinutes > 5) {
                      setState(() => _durationMinutes -= 5);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                const Gap(16),
                Text(
                  _formatDuration(_durationMinutes),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
                ),
                const Gap(16),
                IconButton(
                  onPressed: () {
                    setState(() => _durationMinutes += 5);
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeChip(context, 15),
                const Gap(8),
                _buildTimeChip(context, 30),
                const Gap(8),
                _buildTimeChip(context, 60),
                const Gap(8),
                _buildTimeChip(context, 90),
              ],
            ),
            const Gap(24),
  
            // Category
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final isSelected = _category == c;
                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _category = c;
                        _titleController.text = "$c Session";
                      });
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const Gap(24),
  
            // Custom Note
            TextField(
              controller: _notesController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Add a note (optional)...",
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
            ),
            const Gap(32),
  
            // Save Button
            ElevatedButton(
              onPressed: _save,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTypeButton(BuildContext context, String type, String label) {
    final isSelected = _type == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryColor : borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? onPrimaryColor : (isDark ? Colors.white : Colors.black),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, int minutes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return GestureDetector(
      onTap: () => setState(() => _durationMinutes = minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${minutes}m",
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return "${h}h ${m}m";
    if (h > 0) return "${h}h";
    return "${m}m";
  }
}
