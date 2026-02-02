import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  final List<String> _investedCategories = ['Work', 'Study', 'Exercise', 'Reading', 'Creative'];
  final List<String> _spentCategories = ['Gaming', 'Social Media', 'TV', 'Oversleeping', 'Commute'];

  @override
  void initState() {
    super.initState();
    _titleController.text = "Work Session";
  }

  void _save() {
    final newEntry = TimeEntry(
      title: _titleController.text,
      category: _category,
      type: _type,
      durationMinutes: _durationMinutes,
      startTime: ref.read(selectedDateProvider), // Use selected date
    );

    final box = ref.read(ledgerBoxProvider);
    box.add(newEntry);

    // Trigger Gamification
    if (_type == 'invested') {
      ref.read(gamificationProvider.notifier).processAction(
        type: 'focus_session',
        minutes: _durationMinutes,
      );
    } // Could add 'spent' logic if desired (Start small)

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'invested' ? _investedCategories : _spentCategories;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              ),
              Expanded(
                child: Text(
                  "New Entry",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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
              _buildTypeButton('invested', "Invested"),
              const Gap(12),
              _buildTypeButton('spent', "Spent"),
            ],
          ),
          const Gap(24),

          // Duration
          Center(
            child: Text(
              _formatDuration(_durationMinutes),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeChip(15),
              const Gap(8),
              _buildTimeChip(30),
              const Gap(8),
              _buildTimeChip(60),
              const Gap(8),
              _buildTimeChip(90),
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
                  if (val) setState(() {
                    _category = c;
                    _titleController.text = "$c Session";
                  });
                },
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const Gap(32),

          // Save Button
          ElevatedButton(
            onPressed: _save,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(int minutes) {
    return GestureDetector(
      onTap: () => setState(() => _durationMinutes = minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${minutes}m",
          style: const TextStyle(fontWeight: FontWeight.w600),
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
