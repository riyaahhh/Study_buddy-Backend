import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/message_model.dart';

class DummyData {
  // ─── NEARBY STUDENTS ──────────────────────────────────────────
  static List<UserModel> nearbyUsers = [
    UserModel(
      id: 'dummy-1',
      name: 'Priya Sharma',
      email: 'priya@example.com',
      bio: 'B.Tech CSE @ PCCOE | AI & ML enthusiast',
      subjects: ['Machine Learning', 'Data Structures', 'Flutter'],
      latitude: 18.5210,
      longitude: 73.8580,
    ),
    UserModel(
      id: 'dummy-2',
      name: 'Aman Verma',
      email: 'aman@example.com',
      bio: 'Final year @ VIT Pune | Competitive programmer',
      subjects: ['DSA', 'System Design', 'Java'],
      latitude: 18.5190,
      longitude: 73.8550,
    ),
    UserModel(
      id: 'dummy-3',
      name: 'Sneha Patil',
      email: 'sneha@example.com',
      bio: 'MCA student | Web & Mobile dev',
      subjects: ['React', 'Node.js', 'Python'],
      latitude: 18.5220,
      longitude: 73.8600,
    ),
    UserModel(
      id: 'dummy-4',
      name: 'Rohan Kulkarni',
      email: 'rohan@example.com',
      bio: 'B.Tech IT | Placement prep mode 🚀',
      subjects: ['Aptitude', 'Core Java', 'DBMS'],
      latitude: 18.5180,
      longitude: 73.8540,
    ),
    UserModel(
      id: 'dummy-5',
      name: 'Ananya Singh',
      email: 'ananya@example.com',
      bio: 'AI & DS student | Kaggle competitions',
      subjects: ['Deep Learning', 'NLP', 'Statistics'],
      latitude: 18.5230,
      longitude: 73.8610,
    ),
    UserModel(
      id: 'dummy-6',
      name: 'Karan Mehta',
      email: 'karan@example.com',
      bio: 'Full stack dev | Open source contributor',
      subjects: ['Spring Boot', 'Flutter', 'PostgreSQL'],
      latitude: 18.5170,
      longitude: 73.8530,
    ),
  ];

  // ─── STUDY SESSIONS ───────────────────────────────────────────
  static List<SessionModel> sessions = [
    SessionModel(
      id: 'dummy-s1',
      title: 'DSA Interview Prep',
      subject: 'Data Structures',
      description:
          'Solving LeetCode medium problems together. Arrays, Trees, Graphs.',
      hostId: 'dummy-1',
      hostName: 'Priya Sharma',
      locationName: 'PCCOE Library',
      latitude: 18.5210,
      longitude: 73.8580,
      maxMembers: 6,
      status: 'upcoming',
      scheduledAt:
          DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      createdAt:
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    ),
    SessionModel(
      id: 'dummy-s2',
      title: 'ML Study Group',
      subject: 'Machine Learning',
      description: 'Covering regression, classification and neural networks.',
      hostId: 'dummy-2',
      hostName: 'Aman Verma',
      locationName: 'VIT Pune Seminar Hall',
      latitude: 18.5190,
      longitude: 73.8550,
      maxMembers: 8,
      status: 'active',
      scheduledAt: DateTime.now().toIso8601String(),
      createdAt:
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    ),
    SessionModel(
      id: 'dummy-s3',
      title: 'Flutter App Development',
      subject: 'Mobile Dev',
      description: 'Building a full-stack Flutter app with State Management.',
      hostId: 'dummy-3',
      hostName: 'Sneha Patil',
      locationName: 'Online - Google Meet',
      latitude: 18.5220,
      longitude: 73.8600,
      maxMembers: 5,
      status: 'upcoming',
      scheduledAt:
          DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      createdAt:
          DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    ),
    SessionModel(
      id: 'dummy-s4',
      title: 'DBMS & SQL Practice',
      subject: 'Database',
      description:
          'Normalization, queries, indexing — covering everything for placements.',
      hostId: 'dummy-4',
      hostName: 'Rohan Kulkarni',
      locationName: 'Cafe Coffee Day, FC Road',
      latitude: 18.5180,
      longitude: 73.8540,
      maxMembers: 4,
      status: 'upcoming',
      scheduledAt:
          DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
      createdAt: DateTime.now()
          .subtract(const Duration(minutes: 30))
          .toIso8601String(),
    ),
    SessionModel(
      id: 'dummy-s5',
      title: 'Deep Learning Paper Reading',
      subject: 'AI Research',
      description:
          'Reading and discussing latest arxiv papers on transformers.',
      hostId: 'dummy-5',
      hostName: 'Ananya Singh',
      locationName: 'Online - Discord',
      latitude: 18.5230,
      longitude: 73.8610,
      maxMembers: 10,
      status: 'upcoming',
      scheduledAt:
          DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      createdAt:
          DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    ),
  ];

  // ─── CHAT MESSAGES ────────────────────────────────────────────
  static List<MessageModel> messagesForSession(
      String sessionId, String myUserId, String myName) {
    return [
      MessageModel(
        id: 'msg-1',
        sessionId: sessionId,
        senderId: 'dummy-1',
        senderName: 'Priya Sharma',
        content: 'Hey everyone! Ready to start? 👋',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      ),
      MessageModel(
        id: 'msg-2',
        sessionId: sessionId,
        senderId: 'dummy-2',
        senderName: 'Aman Verma',
        content: 'Yes! Let\'s start with arrays today.',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 28))
            .toIso8601String(),
      ),
      MessageModel(
        id: 'msg-3',
        sessionId: sessionId,
        senderId: myUserId,
        senderName: myName,
        content: 'I\'m in! Should we do sliding window first?',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 25))
            .toIso8601String(),
      ),
      MessageModel(
        id: 'msg-4',
        sessionId: sessionId,
        senderId: 'dummy-1',
        senderName: 'Priya Sharma',
        content: 'Great idea! I\'ll share the LeetCode link.',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 20))
            .toIso8601String(),
      ),
      MessageModel(
        id: 'msg-5',
        sessionId: sessionId,
        senderId: 'dummy-3',
        senderName: 'Sneha Patil',
        content: 'Sorry I\'m late! What problem are we on?',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 10))
            .toIso8601String(),
      ),
      MessageModel(
        id: 'msg-6',
        sessionId: sessionId,
        senderId: 'dummy-2',
        senderName: 'Aman Verma',
        content: 'Maximum subarray! Kadane\'s algorithm 🔥',
        sentAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      ),
    ];
  }
}
