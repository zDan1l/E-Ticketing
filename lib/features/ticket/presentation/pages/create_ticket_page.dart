import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/ticket_service.dart';
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
  bool _isLoading = false;
  final List<XFile> _attachedFiles = [];
  final Map<String, Uint8List> _fileBytesCache = {};
  final TicketService _ticketService = TicketService();
  final AttachmentService _attachmentService = AttachmentService();
  final ImagePicker _imagePicker = ImagePicker();

  final _categories = [
    {'value': 'hardware', 'label': 'Hardware', 'icon': Icons.computer_rounded},
    {'value': 'software', 'label': 'Software', 'icon': Icons.apps_rounded},
    {'value': 'network', 'label': 'Network', 'icon': Icons.wifi_rounded},
    {'value': 'access', 'label': 'Akses', 'icon': Icons.vpn_key_rounded},
    {'value': 'other', 'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
  ];

  void _handleSubmit() async {
    print('🎫 Submit pressed - Starting validation');
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null) {
      print('✅ Form validation passed');
      setState(() => _isLoading = true);

      print('🎫 Creating ticket with data:');
      print('  - Title: ${_titleController.text.trim()}');
      print('  - Category: $_selectedCategory');
      print('  - Priority: medium (default)');

      // Create ticket first with default priority
      final ticket = await _ticketService.createTicket(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        priority: 'medium', // Default priority
        description: _descriptionController.text.trim(),
      );

      print('🎫 Ticket creation result: ${ticket != null ? "SUCCESS - ID: ${ticket.id}" : "FAILED"}');

      if (mounted) {
        if (ticket != null) {
          // Upload attachments if ticket was created successfully
          print('📎 Checking attachments: ${_attachedFiles.length} files');
          if (_attachedFiles.isNotEmpty) {
            print('📎 Starting attachment upload process...');
            int uploadedCount = 0;
            for (int i = 0; i < _attachedFiles.length; i++) {
              final file = _attachedFiles[i];
              print('📎 Uploading file ${i + 1}/${_attachedFiles.length}: ${file.name} (${file.path})');

              final attachment = await _attachmentService.uploadAttachment(
                ticket.id,
                file,
              );

              print('📎 Upload ${i + 1} result: ${attachment != null ? "SUCCESS - ID: ${attachment.id}" : "FAILED"}');
              if (attachment != null) {
                uploadedCount++;
              }
            }

            print('✅ Upload complete: $uploadedCount/${_attachedFiles.length} successful');
          } else {
            print('ℹ️ No attachments to upload');
          }

          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tiket berhasil dibuat${_attachedFiles.isNotEmpty ? " dengan ${_attachedFiles.length} lampiran" : ""}!',
                style: const TextStyle(color: AppColors.onBackground),
              ),
              backgroundColor: AppColors.successAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Return true to indicate success
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isLoading = false);
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
      print('❌ Form validation failed');
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon lengkapi kategori'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengambil foto: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memilih gambar: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
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
                color: AppColors.surfaceContainerLowest,
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
                color: AppColors.surfaceContainerLowest,
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
              // File Attachments
              Container(
                color: AppColors.surfaceContainerLowest,
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
                                    color: AppColors.primaryFixed,
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
                                        style: Theme.of(context).textTheme.bodyMedium,
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