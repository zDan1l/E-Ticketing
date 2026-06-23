import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/ticket_service.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  bool _isLoading = false;
  final List<String> _attachedFiles = [];
  final TicketService _ticketService = TicketService();

  final _categories = [
    {'value': 'hardware', 'label': 'Hardware', 'icon': Icons.computer_rounded},
    {'value': 'software', 'label': 'Software', 'icon': Icons.apps_rounded},
    {'value': 'network', 'label': 'Network', 'icon': Icons.wifi_rounded},
    {'value': 'access', 'label': 'Akses', 'icon': Icons.vpn_key_rounded},
    {'value': 'other', 'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
  ];

  final _priorities = [
    {'value': 'low', 'label': 'Low', 'color': AppColors.priorityLow},
    {'value': 'medium', 'label': 'Medium', 'color': AppColors.priorityMedium},
    {'value': 'high', 'label': 'High', 'color': AppColors.priorityHigh},
    {
      'value': 'critical',
      'label': 'Critical',
      'color': AppColors.priorityCritical
    },
  ];

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _selectedPriority != null) {
      setState(() => _isLoading = true);

      final ticket = await _ticketService.createTicket(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        priority: _selectedPriority!,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (ticket != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tiket berhasil dibuat!'),
              backgroundColor: AppColors.successAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Return true to indicate success
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat tiket. Silakan coba lagi.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (_selectedCategory == null || _selectedPriority == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon lengkapi kategori dan prioritas'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addAttachment() {
    setState(() {
      _attachedFiles.add('screenshot_${_attachedFiles.length + 1}.png');
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: ClayIconButton(
          icon: Icons.close_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Tiket Baru',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Title & Description
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledInput(
                      label: 'Judul Tiket',
                      hint: 'Contoh: Laptop tidak bisa konek WiFi',
                      controller: _titleController,
                      prefixIcon: Icons.title_rounded,
                      maxLength: 100,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        if (v.trim().length < 3) {
                          return 'Judul harus minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    StyledInput(
                      label: 'Deskripsi',
                      hint: 'Jelaskan masalah Anda secara detail...',
                      controller: _descriptionController,
                      maxLines: 5,
                      prefixIcon: Icons.description_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        if (v.trim().length < 10) {
                          return 'Deskripsi harus minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Category Selection
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat['value'];
                        return ChipBadge(
                          label: cat['label'] as String,
                          icon: cat['icon'] as IconData?,
                          isSelected: isSelected,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          textColor: isSelected
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                          onTap: isSelected
                              ? null
                              : () {
                                  setState(() => _selectedCategory = cat['value'] as String);
                                },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Priority Selection
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prioritas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _priorities.map((pri) {
                        final isSelected = _selectedPriority == pri['value'];
                        final value = pri['value'] as String;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                          child: Opacity(
                            opacity: _selectedPriority == null || isSelected ? 1.0 : 0.4,
                            child: Container(
                              decoration: isSelected
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull + 2),
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    )
                                  : null,
                              padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
                              child: PriorityBadge(
                                text: pri['label'] as String,
                                priority: _getPriorityLevel(value),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // File Attachments
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lampiran',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FileUploadArea(
                      label: 'Unggah Screenshot atau Dokumen',
                      subtitle: 'Max 5 file, 25MB per file',
                      onTap: _addAttachment,
                      icon: Icons.upload_file,
                    ),
                    if (_attachedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ..._attachedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: StyledCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file_rounded, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    file,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                ClayIconButton(
                                  icon: Icons.close_rounded,
                                  size: 32,
                                  onPressed: () => _removeAttachment(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClayButton(
                  text: _isLoading ? 'Memuat...' : 'Buat Tiket',
                  onPressed: _isLoading ? null : _handleSubmit,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PriorityLevel _getPriorityLevel(String value) {
    switch (value) {
      case 'low':
        return PriorityLevel.low;
      case 'medium':
        return PriorityLevel.medium;
      case 'high':
        return PriorityLevel.high;
      case 'critical':
        return PriorityLevel.critical;
      default:
        return PriorityLevel.low;
    }
  }
}