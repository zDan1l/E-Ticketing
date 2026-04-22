import '../models/ticket_model.dart';
import '../models/notification_model.dart';

class DummyData {
  DummyData._();

  static const String currentUserName = 'Ahmad Fauzi';
  static const String currentUserEmail = 'ahmad.fauzi@email.com';
  static const String currentUserRole = 'user';
  static const String currentUserAvatar = 'AF';

  static List<TicketModel> get tickets => [
        TicketModel(
          id: '1',
          ticketNumber: 'TKT-20260417-001',
          title: 'Laptop tidak bisa konek WiFi',
          category: 'network',
          priority: 'high',
          status: 'in_progress',
          description:
              'Laptop kantor saya tidak bisa terkoneksi ke jaringan WiFi sejak kemarin. Sudah coba restart dan forget network tapi tetap tidak bisa. Muncul error "Can\'t connect to this network" setiap kali mencoba connect.',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          assigneeName: 'Budi Santoso',
          assigneeAvatar: 'BS',
          commentsCount: 3,
          attachmentsCount: 1,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TicketModel(
          id: '2',
          ticketNumber: 'TKT-20260417-002',
          title: 'Printer lantai 3 paper jam',
          category: 'hardware',
          priority: 'medium',
          status: 'open',
          description:
              'Printer HP LaserJet di lantai 3 mengalami paper jam yang berulang. Sudah dicoba bersihkan tapi tetap macet setelah beberapa kali print.',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          commentsCount: 0,
          attachmentsCount: 2,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        TicketModel(
          id: '3',
          ticketNumber: 'TKT-20260416-005',
          title: 'Install Microsoft Office 365',
          category: 'software',
          priority: 'low',
          status: 'resolved',
          description:
              'Request install Microsoft Office 365 untuk laptop baru yang baru diterima. Butuh Word, Excel, dan PowerPoint.',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          assigneeName: 'Sari Dewi',
          assigneeAvatar: 'SD',
          commentsCount: 5,
          attachmentsCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        TicketModel(
          id: '4',
          ticketNumber: 'TKT-20260416-003',
          title: 'Email tidak bisa mengirim attachment',
          category: 'software',
          priority: 'high',
          status: 'in_progress',
          description:
              'Outlook tidak bisa mengirim email dengan attachment. Setiap kali attach file dan klik send, muncul error "message undeliverable".',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          assigneeName: 'Budi Santoso',
          assigneeAvatar: 'BS',
          commentsCount: 2,
          attachmentsCount: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        TicketModel(
          id: '5',
          ticketNumber: 'TKT-20260415-001',
          title: 'VPN tidak bisa connect dari rumah',
          category: 'network',
          priority: 'critical',
          status: 'closed',
          description:
              'Tidak bisa connect ke VPN kantor dari rumah. Sudah coba berbagai troubleshoot tapi tetap gagal.',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          assigneeName: 'Budi Santoso',
          assigneeAvatar: 'BS',
          commentsCount: 8,
          attachmentsCount: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TicketModel(
          id: '6',
          ticketNumber: 'TKT-20260415-004',
          title: 'Request akses ke shared drive',
          category: 'other',
          priority: 'low',
          status: 'closed',
          description:
              'Mohon diberikan akses ke shared drive departemen Marketing untuk kebutuhan kolaborasi project Q2.',
          reporterName: 'Ahmad Fauzi',
          reporterAvatar: 'AF',
          assigneeName: 'Sari Dewi',
          assigneeAvatar: 'SD',
          commentsCount: 4,
          attachmentsCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        ),
      ];

  static List<TicketTimeline> getTimelineForTicket(String ticketId) {
    return [
      TicketTimeline(
        action: 'created',
        status: 'open',
        description: 'Tiket dibuat',
        actorName: 'Ahmad Fauzi',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TicketTimeline(
        action: 'assigned',
        status: 'in_progress',
        description: 'Tiket di-assign ke Budi Santoso',
        actorName: 'Admin Sistem',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TicketTimeline(
        action: 'commented',
        status: 'in_progress',
        description: 'Menambahkan komentar',
        actorName: 'Budi Santoso',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static List<CommentModel> getCommentsForTicket(String ticketId) {
    return [
      CommentModel(
        id: 'c1',
        body:
            'Sudah saya cek, sepertinya ada masalah di driver WiFi. Bisa coba update driver terlebih dahulu?',
        authorName: 'Budi Santoso',
        authorRole: 'helpdesk',
        authorAvatar: 'BS',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CommentModel(
        id: 'c2',
        body: 'Baik, saya coba update driver dulu. Terima kasih.',
        authorName: 'Ahmad Fauzi',
        authorRole: 'user',
        authorAvatar: 'AF',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      CommentModel(
        id: 'c3',
        body:
            'Sudah update driver tapi masih belum bisa. Berikut saya lampirkan screenshot errornya.',
        authorName: 'Ahmad Fauzi',
        authorRole: 'user',
        authorAvatar: 'AF',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  static List<NotificationModel> get notifications => [
        NotificationModel(
          id: 'n1',
          type: 'ticket_status_changed',
          title: 'Status Tiket Diperbarui',
          body: 'Tiket TKT-20260417-001 berubah menjadi In Progress',
          isRead: false,
          ticketId: '1',
          ticketNumber: 'TKT-20260417-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        NotificationModel(
          id: 'n2',
          type: 'new_comment',
          title: 'Komentar Baru',
          body: 'Budi Santoso mengomentari tiket TKT-20260417-001',
          isRead: false,
          ticketId: '1',
          ticketNumber: 'TKT-20260417-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        NotificationModel(
          id: 'n3',
          type: 'ticket_assigned',
          title: 'Tiket Di-assign',
          body: 'Tiket TKT-20260417-001 di-assign ke Budi Santoso',
          isRead: true,
          ticketId: '1',
          ticketNumber: 'TKT-20260417-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        NotificationModel(
          id: 'n4',
          type: 'ticket_status_changed',
          title: 'Tiket Selesai',
          body: 'Tiket TKT-20260416-005 berubah menjadi Resolved',
          isRead: true,
          ticketId: '3',
          ticketNumber: 'TKT-20260416-005',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        NotificationModel(
          id: 'n5',
          type: 'ticket_status_changed',
          title: 'Tiket Ditutup',
          body: 'Tiket TKT-20260415-001 berubah menjadi Closed',
          isRead: true,
          ticketId: '5',
          ticketNumber: 'TKT-20260415-001',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  // Dashboard stats
  static Map<String, int> get ticketStats => {
        'open': 2,
        'in_progress': 2,
        'resolved': 1,
        'closed': 2,
      };

  static int get totalTickets => tickets.length;
  static int get unreadNotifications =>
      notifications.where((n) => !n.isRead).length;
}
