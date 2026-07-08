import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/ticket_provider.dart';
import '../../../../services/attachment_service.dart';

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
  String _selectedPriority = 'medium'; // Default priority
  bool _isLoading = false;
  final List<XFile> _attachedFiles = [];
  final Map<String, Uint8List> _fileBytesCache = {};
  final AttachmentService _attachmentService = AttachmentService();
  final ImagePicker _imagePicker = ImagePicker();

  final _categories = [
    {'value': 'hardware', 'label': 'Hardware', 'icon': Icons.computer_rounded},
    {'value': 'software', 'label': 'Software', 'icon': Icons.apps_rounded},
    {'value': 'network', 'label': 'Network', 'icon': Icons.wifi_rounded},
    {'value': 'access', 'label': 'Akses', 'icon': Icons.vpn_key_rounded},
    {'value': 'other', 'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
  ];

  final _priorities = [
    {'value': 'low', 'label': 'Low', 'icon': Icons.arrow_downward_rounded},
    {'value': 'medium', 'label': 'Medium', 'icon': Icons.swap_vert_rounded},
    {'value': 'high', 'label': 'High', 'icon': Icons.arrow_upward_rounded},
    {'value': 'critical', 'label': 'Critical', 'icon': Icons.gpp_maybe_rounded},
  ];

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isLoading = true);

      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

      // Create ticket with user-selected category and priority
      final ticket = await ticketProvider.createTicket(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        priority: _selectedPriority,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        if (ticket != null) {
          // Upload attachments if ticket was created successfully
          if (_attachedFiles.isNotEmpty) {
            int uploadedCount = 0;
            for (int i = 0; i < _attachedFiles.length; i++) {
              final file = _attachedFiles[i];
              final attachment = await _attachmentService.uploadAttachment(
                ticket.id,
                file,
              );
              if (attachment != null) {
                uploadedCount++;
              }
            }
          }

          setState(() => _isLoading = false);

          context.showSuccessSnackBar(
            'Tiket berhasil dibuat${_attachedFiles.isNotEmpty ? " dengan ${_attachedFiles.length} lampiran" : ""}!',
          );
          // Return true to indicate success
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isLoading = false);
          context.showErrorSnackBar('Gagal membuat tiket. Silakan coba lagi.');
        }
      }
    } else {
      if (_selectedCategory == null) {
        context.showErrorSnackBar('Mohon lengkapi kategori');
      }
    }
  }

  void _addAttachment() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final XFile? photo = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (photo != null && mounted) {
                    final bytes = await photo.readAsBytes();
                    setState(() {
                      _attachedFiles.add(photo);
                      _fileBytesCache[photo.name] = bytes;
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    context.showErrorSnackBar('Gagal mengambil foto: $e');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null && mounted) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _attachedFiles.add(image);
                      _fileBytesCache[image.name] = bytes;
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    context.showErrorSnackBar('Gagal memilih gambar: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      final removedFile = _attachedFiles.removeAt(index);
      _fileBytesCache.remove(removedFile.name);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Tiket Baru',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'Plus Jakarta Sans',
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Description Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: StyledCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Tiket',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
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
              ),

              // Category Selection Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: StyledCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori Masalah',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
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
                            onTap: () {
                              setState(() => _selectedCategory = cat['value'] as String);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Priority Selection Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: StyledCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tingkat Prioritas',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _priorities.map((pri) {
                          final isSelected = _selectedPriority == pri['value'];
                          return ChipBadge(
                            label: pri['label'] as String,
                            icon: pri['icon'] as IconData?,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedPriority = pri['value'] as String);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // File Attachments Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: StyledCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lampiran Pendukung',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FileUploadArea(
                        label: 'Unggah Screenshot atau Dokumen',
                        subtitle: 'Maksimal 5 file, 25MB per file',
                        onTap: _addAttachment,
                        icon: Icons.upload_file_rounded,
                      ),
                      if (_attachedFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ..._attachedFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          final fileName = file.name;
                          final fileBytes = _fileBytesCache[fileName];
                          final fileSizeKB = fileBytes != null
                              ? (fileBytes.length / 1024).toStringAsFixed(1)
                              : '0.0';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: StyledCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                    ),
                                    child: fileName.endsWith('.jpg') ||
                                            fileName.endsWith('.jpeg') ||
                                            fileName.endsWith('.png') ||
                                            fileName.endsWith('.gif') ||
                                            fileName.endsWith('.webp')
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: fileBytes != null
                                                ? Image.memory(
                                                    fileBytes,
                                                    fit: BoxFit.cover,
                                                    width: 48,
                                                    height: 48,
                                                  )
                                                : const Icon(
                                                    Icons.image_rounded,
                                                    size: 24,
                                                    color: AppColors.primary,
                                                  ),
                                          )
                                        : const Icon(
                                            Icons.attach_file_rounded,
                                            size: 24,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$fileSizeKB KB',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
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
}