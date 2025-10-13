import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

/// Bottom sheet for editing an existing habit log.
class EditLogSheet extends StatefulWidget {
  const EditLogSheet({
    required this.habit,
    required this.log,
    super.key,
  });

  final Habit habit;
  final HabitLog log;

  @override
  State<EditLogSheet> createState() => _EditLogSheetState();
}

class _EditLogSheetState extends State<EditLogSheet>
    with SingleTickerProviderStateMixin {
  LogQuality? _selectedQuality;
  final _noteController = TextEditingController();
  File? _selectedPhoto;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize with existing values
    _selectedQuality = widget.log.quality;
    _noteController.text = widget.log.note ?? '';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _selectedPhoto = File(pickedFile.path));
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilemedi')),
      );
    }
  }

  void _removePhoto() {
    setState(() => _selectedPhoto = null);
    HapticFeedback.lightImpact();
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_selectedQuality == null) {
      _animationController
          .forward()
          .then((_) => _animationController.reverse());
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kalite seç')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Return updated data
    Navigator.pop(context, {
      'quality': _selectedQuality,
      'note': _noteController.text.trim(),
      'photo': _selectedPhoto,
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu kaydı silmek istediğinden emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context, {'delete': true});
    }
  }

  void _handleCancel() {
    final hasChanges = _selectedQuality != widget.log.quality ||
        _noteController.text.trim() != (widget.log.note ?? '') ||
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
      height: MediaQuery.of(context).size.height * 0.75,
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
                  // Title and Delete button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kaydı Düzenle',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Kaydı Sil',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Habit name and date
                  Row(
                    children: [
                      Text(
                        widget.habit.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              _formatDate(widget.log.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quality selector
                  Text(
                    'Kalite Seç',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                                () => _selectedQuality = LogQuality.minimal);
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
                                () => _selectedQuality = LogQuality.excellent);
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
                      hintText: 'Notunu buraya yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '${_noteController.text.length}/500',
                      suffixIcon: _noteController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _noteController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
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
                  if (_selectedPhoto != null) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedPhoto!,
                            width: double.infinity,
                            height: 200,
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
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Fotoğraf Ekle'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) {
      return 'Bugün';
    } else if (diff == 1) {
      return 'Dün';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

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
          color: isSelected ? color.withValues(alpha: 0.2) : null,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
