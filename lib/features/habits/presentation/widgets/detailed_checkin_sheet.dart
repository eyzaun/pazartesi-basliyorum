import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

/// Bottom sheet for detailed check-in with quality, note, and photo.
class DetailedCheckInSheet extends StatefulWidget {
  const DetailedCheckInSheet({
    required this.habit,
    super.key,
    this.existingLog,
    this.initialNote,
  });

  final Habit habit;
  final HabitLog? existingLog;
  final String? initialNote;

  @override
  State<DetailedCheckInSheet> createState() => _DetailedCheckInSheetState();
}

class _DetailedCheckInSheetState extends State<DetailedCheckInSheet>
    with SingleTickerProviderStateMixin {
  LogQuality? _selectedQuality;
  final _noteController = TextEditingController();
  File? _selectedPhoto;
  bool _isLoading = false;
  bool _shareWithFriends = false; // Default: don't share
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load existing data if editing
    if (widget.existingLog != null) {
      _selectedQuality = widget.existingLog!.quality;
      _noteController.text = widget.existingLog!.note ?? '';
    } else if (widget.initialNote != null) {
      // Use initial note if provided (e.g., from timer)
      _noteController.text = widget.initialNote!;
    }

    // Auto-save draft
    _noteController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    // TODO: Implement auto-save to SharedPreferences
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
        );
      }
    }
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kameradan Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _handleComplete() async {
    if (_selectedQuality == null) {
      // Shake animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kalite seç')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Return data to parent
    Navigator.pop(context, {
      'quality': _selectedQuality,
      'note': _noteController.text.trim(),
      'photo': _selectedPhoto,
      'shareWithFriends': _shareWithFriends,
    });
  }

  void _handleCancel() {
    final hasChanges = _selectedQuality != null ||
        _noteController.text.isNotEmpty ||
        _selectedPhoto != null;

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
                    'Nasıl Hissettin?',
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

                  // Quality selector
                  Row(
                    children: [
                      Expanded(
                        child: _QualityButton(
                          label: 'Kötü',
                          emoji: '😐',
                          color: const Color(0xFFFFE66D),
                          isSelected: _selectedQuality == LogQuality.minimal,
                          onTap: () {
                            setState(
                                () => _selectedQuality = LogQuality.minimal,);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QualityButton(
                          label: 'İyi',
                          emoji: '🙂',
                          color: const Color(0xFF4ECDC4),
                          isSelected: _selectedQuality == LogQuality.good,
                          onTap: () {
                            setState(() => _selectedQuality = LogQuality.good);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QualityButton(
                          label: 'Mükemmel',
                          emoji: '😊',
                          color: const Color(0xFF6C63FF),
                          isSelected: _selectedQuality == LogQuality.excellent,
                          onTap: () {
                            setState(
                                () => _selectedQuality = LogQuality.excellent,);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ),
                    ],
                  ),
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
                    maxLines: 4,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Bugün nasıldı? Notlarını ekle...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '${_noteController.text.length}/500',
                      suffixIcon: _noteController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _noteController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // Photo section
                  Text(
                    'Fotoğraf Ekle (opsiyonel)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedPhoto == null)
                    OutlinedButton.icon(
                      onPressed: _showPhotoSourceDialog,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Fotoğraf Ekle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedPhoto!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: _removePhoto,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Share with friends option
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SwitchListTile(
                      value: _shareWithFriends,
                      onChanged: (value) {
                        setState(() => _shareWithFriends = value);
                        HapticFeedback.mediumImpact();
                      },
                      title: Row(
                        children: [
                          Icon(
                            Icons.share,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Arkadaşlarla Paylaş',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        _shareWithFriends
                            ? '✅ "${widget.habit.name}" tamamlandı paylaşılacak'
                            : 'Tamamladığın bu alışkanlığı arkadaşlarınla paylaş',
                        style: TextStyle(
                          fontSize: 12,
                          color: _shareWithFriends
                              ? theme.colorScheme.primary
                              : Colors.grey[600],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    onPressed: _isLoading ? null : _handleComplete,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tamamla'),
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

/// Quality selection button widget.
class _QualityButton extends StatelessWidget {
  const _QualityButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: isSelected ? 1.2 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: isSelected ? null : Colors.grey,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
