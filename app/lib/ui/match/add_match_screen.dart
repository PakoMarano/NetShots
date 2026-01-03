import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netshots/ui/home/home_viewmodel.dart';
import 'package:netshots/ui/match/add_match_viewmodel.dart';
import 'package:netshots/ui/profile/profile_screen/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class AddMatchScreen extends StatefulWidget {
  final bool showAppBar;

  const AddMatchScreen({super.key, this.showAppBar = true});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isVictory = false;
  DateTime _date = DateTime.now();
  String? _imagePath;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _sharePosition = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, maxWidth: 1600, maxHeight: 1200, imageQuality: 85);
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _imagePath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore nella selezione immagine: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_imagePath == null || _imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devi selezionare una foto per la partita')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final viewModel = Provider.of<AddMatchViewModel>(context, listen: false);
    final success = await viewModel.submitMatch(
      imagePath: _imagePath!,
      isVictory: _isVictory,
      date: _date,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      sharePosition: _sharePosition,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = viewModel.isSubmitting;
    });

    if (success) {
      if (!mounted) return;
      // Refresh profile (stats + gallery) so counts and photos update immediately
      try {
        final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
        await profileVm.loadUserProfile(force: true, silent: true);
      } catch (_) {
        // ignore if profile VM not available
      }
      
      if (!mounted) return;
      // Navigate to profile tab (HomeScreen will animate PageView when HomeViewModel index changes)
      try {
        final homeVm = Provider.of<HomeViewModel>(context, listen: false);
        homeVm.setCurrentIndex(1);
      } catch (_) {}

      if (!mounted) return;
      // Notify if location was requested but unavailable
      if (viewModel.lastPositionUnavailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partita aggiunta, ma la posizione non era disponibile'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partita aggiunta')));
      }

      if (!mounted) return;
      // Only pop if this route was pushed. If this screen is inside a PageView (no
      // navigator entry), popping the navigator can close the app or hide UI — avoid that.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        // Clear the form so the user sees fields reset and doesn't accidentally resubmit
        setState(() {
          _imagePath = null;
          _notesController.clear();
          _date = DateTime.now();
          _isVictory = false;
          _isSubmitting = false;
          _sharePosition = true;
        });
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore nel salvataggio')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image picker
          Center(
            child: GestureDetector(
              onTap: () => _showImageOptions(),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imagePath != null
                      ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                      : null,
                  color: _imagePath == null ? Colors.grey.shade200 : null,
                ),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.camera_alt, size: 48), SizedBox(height: 8), Text('Tocca per aggiungere foto')],
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Victory toggle
          Row(
            children: [
              const Text('Esito:'),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Text('Vittoria', style: TextStyle(color: _isVictory ? Colors.white : null)),
                selected: _isVictory,
                selectedColor: Colors.green,
                onSelected: (v) => setState(() => _isVictory = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Sconfitta', style: TextStyle(color: !_isVictory ? Colors.white : null)),
                selected: !_isVictory,
                selectedColor: Colors.red,
                onSelected: (v) => setState(() => _isVictory = false),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date picker
          Row(
            children: [
              const Text('Data: '),
              const SizedBox(width: 8),
              Text('${_date.day}/${_date.month}/${_date.year}'),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _pickDate, child: const Text('Cambia data')),
            ],
          ),
          const SizedBox(height: 12),

          // Share position toggle
          Row(
            children: [
              const Text('Condividi posizione:'),
              const SizedBox(width: 12),
              Switch(
                value: _sharePosition,
                onChanged: (value) => setState(() => _sharePosition = value),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Notes (limited length)
          TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 140,
            inputFormatters: [LengthLimitingTextInputFormatter(140)],
            decoration: const InputDecoration(
              labelText: 'Note (opzionali)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('Aggiungi partita'),
            ),
          ),
        ],
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Aggiungi partita'),
        ),
        body: content,
      );
    }

    return content;
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Scegli dalla galleria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scatta una foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Rimuovi foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _imagePath = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
