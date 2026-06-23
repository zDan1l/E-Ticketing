import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/role_model.dart';
import '../../services/user_api_service.dart';
import '../components/components.dart';

class AssignTicketDialog extends StatefulWidget {
  final String? currentAssigneeId;
  final Function(UserModel) onAssign;

  const AssignTicketDialog({
    super.key,
    this.currentAssigneeId,
    required this.onAssign,
  });

  @override
  State<AssignTicketDialog> createState() => _AssignTicketDialogState();
}

class _AssignTicketDialogState extends State<AssignTicketDialog> {
  final UserApiService _userService = UserApiService();
  UserModel? _selectedAssignee;
  List<UserModel> _helpdeskStaff = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHelpdeskStaff();
  }

  Future<void> _loadHelpdeskStaff() async {
    try {
      final staff = await _userService.getHelpdeskStaff();
      if (mounted) {
        setState(() {
          _helpdeskStaff = staff;
          _isLoading = false;
          _errorMessage = null;
          if (widget.currentAssigneeId != null &&
              widget.currentAssigneeId!.isNotEmpty) {
            _selectedAssignee = staff.firstWhere(
              (s) => s.id == widget.currentAssigneeId,
              orElse: () => UserModel(
                id: '',
                name: 'Unassigned',
                email: '',
                avatar: '',
                role: UserRole.helpdesk,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat helpdesk: ${e.toString()}';
          _helpdeskStaff = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final helpdeskStaff = _helpdeskStaff;

    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      title: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Assign Tiket',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih helpdesk untuk menangani tiket ini',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          if (_isLoading)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgress(
                      value: 0.3,
                      size: 36,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Memuat helpdesk...',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ClayButton(
                      text: 'Coba Lagi',
                      icon: Icons.refresh,
                      onPressed: _loadHelpdeskStaff,
                    ),
                  ],
                ),
              ),
            )
          else if (_helpdeskStaff.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      color: AppColors.outline,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tidak ada helpdesk tersedia',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClayButton(
                      text: 'Refresh',
                      icon: Icons.refresh,
                      onPressed: _loadHelpdeskStaff,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserModel>(
                  value: _selectedAssignee,
                  isExpanded: true,
                  elevation: 0,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    'Pilih Helpdesk',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.outline,
                  ),
                  items: [
                    DropdownMenuItem<UserModel>(
                      value: null,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: AppColors.error,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Unassign Tiket',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...helpdeskStaff.map((staff) {
                      return DropdownMenuItem<UserModel>(
                        value: staff,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  staff.avatar,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    staff.email,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (UserModel? value) {
                    setState(() {
                      _selectedAssignee = value;
                    });
                  },
                ),
              ),
            ),
          if (_selectedAssignee != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tiket akan di-assign ke ${_selectedAssignee!.name}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        ClayButton(
          text: 'Batal',
          isGhost: true,
          onPressed: () => Navigator.pop(context),
        ),
        ClayButton(
          text: 'Assign',
          onPressed:
              (_selectedAssignee != null || widget.currentAssigneeId != null) &&
                  !_isLoading &&
                  _errorMessage == null
              ? () {
                  if (_selectedAssignee != null) {
                    widget.onAssign(_selectedAssignee!);
                  } else {
                    widget.onAssign(
                      UserModel(
                        id: '',
                        name: 'Unassigned',
                        email: '',
                        avatar: '',
                        role: UserRole.helpdesk,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }
}

void showAssignTicketDialog({
  required BuildContext context,
  required String? currentAssigneeId,
  required Function(UserModel) onAssign,
}) {
  showDialog(
    context: context,
    builder: (context) => AssignTicketDialog(
      currentAssigneeId: currentAssigneeId,
      onAssign: onAssign,
    ),
  );
}
