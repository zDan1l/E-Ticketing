enum UserRole {
  user('USER', 'Pengguna'),
  helpdesk('HELPDESK', 'Helpdesk'),
  admin('ADMIN', 'Administrator');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    // Handle both uppercase and lowercase inputs for backward compatibility
    final normalizedValue = value.toUpperCase();
    return UserRole.values.firstWhere(
      (role) => role.value == normalizedValue,
      orElse: () => UserRole.user,
    );
  }

  // For backward compatibility with lowercase values
  static UserRole fromLowerCase(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }
}

class UserPermission {
  static const String canViewAllTickets = 'can_view_all_tickets';
  static const String canAssignTickets = 'can_assign_tickets';
  static const String canUpdateTicketStatus = 'can_update_ticket_status';
  static const String canDeleteTicket = 'can_delete_ticket';
  static const String canViewAllUsers = 'can_view_all_users';
  static const String canManageUsers = 'can_manage_users';

  static Map<UserRole, Set<String>> get rolePermissions => {
        UserRole.user: {
          // Users can only manage their own tickets
        },
        UserRole.helpdesk: {
          canViewAllTickets,
          canAssignTickets,
          canUpdateTicketStatus,
        },
        UserRole.admin: {
          canViewAllTickets,
          canAssignTickets,
          canUpdateTicketStatus,
          canDeleteTicket,
          canViewAllUsers,
          canManageUsers,
        },
      };

  static bool hasPermission(UserRole role, String permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }

  static bool canUpdateStatusTo(UserRole role, String newStatus, String currentStatus) {
    // Users cannot manually update ticket status in the new workflow
    if (role == UserRole.user) {
      return false;
    }

    // Helpdesk and admin have limited status update capabilities
    // based on the backend automatic workflow
    if (role == UserRole.helpdesk || role == UserRole.admin) {
      // Admin can manually update for special cases
      if (role == UserRole.admin) {
        return true;
      }

      // Helpdesk can only update open -> in_progress (accept workflow)
      if (role == UserRole.helpdesk) {
        return currentStatus == 'open' && newStatus == 'in_progress';
      }
    }

    return false;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    this.isActive = true,
  });

  bool hasPermission(String permission) {
    return UserPermission.hasPermission(this.role, permission);
  }

  bool canUpdateStatusTo(String newStatus, String currentStatus) {
    return UserPermission.canUpdateStatusTo(this.role, newStatus, currentStatus);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    UserRole? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role.value,
      'isActive': isActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      role: UserRole.fromString(json['role'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}