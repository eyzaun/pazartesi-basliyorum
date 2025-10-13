import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/habit.dart';

/// Bottom sheet for skipping a habit with reason.
class SkipReasonSheet extends StatefulWidget {
  const SkipReasonSheet({
    required this.habit,
    super.key,
  });

  final Habit habit;

  @override
  State<SkipReasonSheet> createState() => _SkipReasonSheetState();
}

class _SkipReasonSheetState extends State<SkipReasonSheet> {
  static const List<String> _predefinedReasons = [
    'Meşguldüm',
    'Hastaydım',
    'Dinlenme günü',
    'Unuttum',
    'Motivasyon eksikliği',
    'Diğer',
  ];

  String? _selectedReason;
  final _customReasonController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _customReasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_selectedReason == null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir sebep seç')),
      );
      return;
    }

    if (_selectedReason == 'Diğer' &&
        _customReasonController.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen sebebi yaz')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reason = _selectedReason == 'Diğer'
        ? _customReasonController.text.trim()
        : _selectedReason;

    // Return data to parent
    Navigator.pop(context, {
      'reason': reason,
      'note': _noteController.text.trim(),
    });
  }

  void _handleCancel() {
    final hasChanges = _selectedReason != null ||
        _noteController.text.isNotEmpty ||
        _customReasonController.text.isNotEmpty;

    if (hasChanges) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Değişiklikler kaydedilmedi'),
          content: const Text('Çıkmak istediğinden emin misin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Geri Dön'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context);
              },
              child: const Text('Çık'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Neden Atladın?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Habit name
                  Row(
                    children: [
                      Text(
                        widget.habit.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.habit.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reason options
                  ..._predefinedReasons.map((reason) {
                    final isSelected = _selectedReason == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RadioListTile<String>(
                        value: reason,
                        groupValue: _selectedReason,
                        onChanged: (value) {
                          setState(() => _selectedReason = value);
                          HapticFeedback.mediumImpact();
                        },
                        title: Text(reason),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        tileColor: isSelected
                            ? theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3)
                            : null,
                      ),
                    );
                  }),

                  // Custom reason field (appears when "Diğer" selected)
                  if (_selectedReason == 'Diğer') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customReasonController,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Sebebini yaz...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      autofocus: true,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Note field
                  Text(
                    'Not Ekle (opsiyonel)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLength: 500,
                    maxLines: 3,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ek not...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '${_noteController.text.length}/500',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
