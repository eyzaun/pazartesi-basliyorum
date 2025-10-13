import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/initial_sync_service.dart';

class InitialSyncDialog extends ConsumerStatefulWidget {
  const InitialSyncDialog({super.key});

  @override
  ConsumerState<InitialSyncDialog> createState() => _InitialSyncDialogState();
}

class _InitialSyncDialogState extends ConsumerState<InitialSyncDialog> {
  InitialSyncProgress _progress = const InitialSyncProgress('Başlıyor...', 0.0);
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    final syncService = ref.read(initialSyncServiceProvider);

    try {
      await syncService.performInitialSync(
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }

          // Auto close when complete
          if (progress.progress >= 1.0) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isError || _progress.progress >= 1.0,
      child: AlertDialog(
        title: Row(
          children: [
            if (!_isError) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
            ] else
              const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(_isError ? 'Hata' : 'İlk Senkronizasyon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isError) ...[
              LinearProgressIndicator(
                value: _progress.progress,
                backgroundColor: Colors.grey[200],
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                _progress.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          if (_isError)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Kapat'),
            ),
          if (_isError)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isError = false;
                  _errorMessage = '';
                  _progress = const InitialSyncProgress('Başlıyor...', 0.0);
                });
                _startSync();
              },
              child: const Text('Tekrar Dene'),
            ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
Future<bool> showInitialSyncDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const InitialSyncDialog(),
  );

  return result ?? false;
}
