import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';

// ── Session Model ─────────────────────────────────────────────────────────────
class Session {
  final int id;
  String category, description, trainer, startTime, endTime, duration;
  int capacity, enrolled;
  SessionStatus status;

  Session({
    required this.id,
    required this.category,
    required this.description,
    required this.trainer,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.capacity,
    required this.enrolled,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    // Backend SessionViewModel returns computed Status as string (Upcoming/Ongoing/Completed)
    final statusStr = (json['status'] ?? json['Status'] ?? '').toString().toLowerCase();
    SessionStatus status;
    if (statusStr.contains('ongoing')) {
      status = SessionStatus.ongoing;
    } else if (statusStr.contains('completed')) {
      status = SessionStatus.completed;
    } else {
      status = SessionStatus.upcoming;
    }

    // Parse duration from TimeSpan (hh:mm:ss) or compute from dates
    String durationStr = '01:00:00';
    final rawDuration = json['duration'] ?? json['Duration'];
    if (rawDuration != null) {
      durationStr = rawDuration.toString();
    } else {
      // Try to compute from start/end dates
      final startRaw = json['startDate'] ?? json['StartDate'] ?? json['startTime'];
      final endRaw = json['endDate'] ?? json['EndDate'] ?? json['endTime'];
      if (startRaw != null && endRaw != null) {
        try {
          final start = DateTime.parse(startRaw.toString());
          final end = DateTime.parse(endRaw.toString());
          final diff = end.difference(start);
          final h = diff.inHours.toString().padLeft(2, '0');
          final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
          durationStr = '$h:$m:00';
        } catch (_) {}
      }
    }

    // enrolled = BookedSlots from backend
    int enrolled = 0;
    final enrolledRaw = json['bookedSlots'] ?? json['BookedSlots'] ??
        json['enrolled'] ?? json['bookedCount'] ?? 0;
    enrolled = enrolledRaw is int
        ? enrolledRaw
        : int.tryParse(enrolledRaw.toString()) ?? 0;

    // startTime / endTime — backend sends DateTime as ISO string
    final startTime = (json['startDate'] ?? json['StartDate'] ??
            json['startTime'] ?? '')
        .toString();
    final endTime = (json['endDate'] ?? json['EndDate'] ??
            json['endTime'] ?? '')
        .toString();

    return Session(
      id: json['id'] ?? json['Id'] ?? 0,
      // Backend returns CategoryName (not category)
      category: (json['categoryName'] ?? json['CategoryName'] ??
              json['category'] ?? json['type'] ?? '')
          .toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      // Backend returns TrainerName (not trainerName in all cases)
      trainer: (json['trainerName'] ?? json['TrainerName'] ??
              json['trainer']?['name'] ?? '')
          .toString(),
      startTime: startTime,
      endTime: endTime,
      duration: durationStr,
      capacity: (json['capacity'] ?? json['Capacity'] ?? 0) is int
          ? (json['capacity'] ?? json['Capacity'] ?? 0)
          : int.tryParse(
                  (json['capacity'] ?? json['Capacity'] ?? '0').toString()) ??
              0,
      enrolled: enrolled,
      status: status,
    );
  }
}

enum SessionStatus { completed, ongoing, upcoming }

// ── Dropdown helper items ─────────────────────────────────────────────────────
class _TrainerItem {
  final int id;
  final String name;
  _TrainerItem({required this.id, required this.name});

  factory _TrainerItem.fromJson(Map<String, dynamic> json) =>
      _TrainerItem(id: json['id'] ?? 0, name: (json['name'] ?? '').toString());
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSIONS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionsPage extends StatefulWidget {
  final ApiService api;
  const SessionsPage({super.key, required this.api});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  ApiService get _api => widget.api;
  List<Session> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _api.getSessions();
      if (!mounted) return;
      setState(() {
        _sessions = data
            .map((j) => Session.fromJson(j as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openAdd() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateSessionPage(api: _api)),
    );
    if (added == true) _load();
  }

  Color _statusColor(SessionStatus s) {
    switch (s) {
      case SessionStatus.completed:
        return Colors.grey.shade600;
      case SessionStatus.ongoing:
        return const Color(0xFF1B6B3A);
      case SessionStatus.upcoming:
        return kOrange;
    }
  }

  String _statusLabel(SessionStatus s) {
    switch (s) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.ongoing:
        return 'Ongoing';
      case SessionStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              color: kBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: kOrange, size: 20),
                      Text(
                        'FitSync',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _openAdd,
                    icon: const Icon(Icons.add, size: 14, color: kBlack),
                    label: const Text(
                      'Add Session',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kBlack,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kOrange,
                    ),
                  ),
                  Text(
                    'Manage Gym Training Sessions And Classes',
                    style: TextStyle(fontSize: 11, color: kGrey),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kOrange));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: kBlack,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_sessions.isEmpty) {
      return const Center(
        child: Text('No sessions yet', style: TextStyle(color: kGrey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: _sessions.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = _sessions[i];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(s.status),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(s.status),
                        style: TextStyle(
                          color: _statusColor(s.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoLine(Icons.person, 'Trainer', s.trainer),
                    _infoLine(
                      Icons.calendar_today,
                      'Date',
                      s.startTime.split(' ').take(3).join(' '),
                    ),
                    _infoLine(
                      Icons.access_time,
                      'Time',
                      '${s.startTime.split(' ').skip(3).join(' ')}  ${s.endTime.split(' ').skip(3).join(' ')}',
                    ),
                    _infoLine(Icons.timer, 'Duration', s.duration),
                    _infoLine(
                      Icons.people,
                      'Capacity',
                      '${s.enrolled}/${s.capacity} Slots',
                    ),
                    const SizedBox(height: 10),

                    // View Details
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SessionDetailsPage(session: s),
                          ),
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: kBlack,
                        ),
                        label: const Text(
                          'View Details',
                          style: TextStyle(color: kBlack, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditSessionPage(session: s, api: _api),
                                ),
                              );
                              if (updated == true) _load();
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: kBlack,
                            ),
                            label: const Text(
                              'Edit',
                              style: TextStyle(color: kBlack, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DeleteSessionPage(session: s, api: _api),
                                ),
                              );
                              if (result == 'deleted') _load();
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 13,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: kOrange),
          const SizedBox(width: 6),
          Text(
            '$label : ',
            style: const TextStyle(fontSize: 11, color: kBlack),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: kBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION DETAILS PAGE  (read-only)
// ══════════════════════════════════════════════════════════════════════════════
class SessionDetailsPage extends StatelessWidget {
  final Session session;
  const SessionDetailsPage({super.key, required this.session});

  Color get _statusColor {
    switch (session.status) {
      case SessionStatus.completed:
        return Colors.grey.shade600;
      case SessionStatus.ongoing:
        return const Color(0xFF1B6B3A);
      case SessionStatus.upcoming:
        return kOrange;
    }
  }

  String get _statusLabel {
    switch (session.status) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.ongoing:
        return 'Ongoing';
      case SessionStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _sTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kOrange, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: const BoxDecoration(
                          color: kOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              session.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel,
                                style: TextStyle(
                                  color: _statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: kBorder),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _detailCard(
                              Icons.description_outlined,
                              'Description',
                              session.description,
                              fullWidth: true,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _detailCard(
                                    Icons.people_outline,
                                    'Capacity',
                                    '${session.enrolled}/${session.capacity} slots',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _detailCard(
                                    Icons.person_outline,
                                    'Trainer',
                                    session.trainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _detailCard(
                                    Icons.access_time,
                                    'Start Time',
                                    session.startTime,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _detailCard(
                                    Icons.access_time_filled,
                                    'End Time',
                                    session.endTime,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _detailCard(
                              Icons.timer_outlined,
                              'Duration',
                              '${session.duration.split(':')[0]} Hours ${session.duration.split(':')[1]} Minutes',
                              fullWidth: true,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  foregroundColor: kBlack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Back To List',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(
    IconData icon,
    String label,
    String value, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 11, color: kOrange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CREATE SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class CreateSessionPage extends StatefulWidget {
  final ApiService api;
  const CreateSessionPage({super.key, required this.api});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  // Dropdowns من الـ API
  List<Map<String, dynamic>> _categories = [];
  List<_TrainerItem> _trainers = [];
  bool _loadingDropdowns = true;
  String? _dropError;

  int? _categoryId;
  int? _trainerId;
  final _desc = TextEditingController();
  final _capacity = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  @override
  void dispose() {
    for (final c in [_desc, _capacity, _start, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    try {
      setState(() {
        _loadingDropdowns = true;
        _dropError = null;
      });
      final data = await widget.api.getSessionDropdowns();
      final categoriesRaw = data['categories'] as List? ?? [];
      final trainersRaw = data['trainers'] as List? ?? [];
      setState(() {
        _categories = categoriesRaw
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _trainers = trainersRaw
            .map((j) => _TrainerItem.fromJson(j as Map<String, dynamic>))
            .toList();
        _loadingDropdowns = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dropError = e.toString();
        _loadingDropdowns = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_categoryId == null || _trainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and trainer')),
      );
      return;
    }
    
    // Validate description length (10-500 characters)
    final description = _desc.text.trim();
    if (description.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be at least 10 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (description.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be less than 500 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate capacity (0-25)
    final capacity = int.tryParse(_capacity.text) ?? 20;
    if (capacity < 0 || capacity > 25) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capacity must be between 0 and 25'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Parse date/time from format "dd/MM/yyyy HH:mm" to ISO8601
    String? parseDateTime(String text) {
      if (text.isEmpty) return null;
      try {
        // Format: "28/4/2026 10:30 AM"
        final parts = text.split(' ');
        if (parts.length < 3) return null;
        
        final dateParts = parts[0].split('/');
        if (dateParts.length != 3) return null;
        
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        
        // Parse time
        final timePart = parts[1];
        final amPm = parts.length > 2 ? parts[2] : 'AM';
        final timeParts = timePart.split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        if (amPm.toUpperCase() == 'PM' && hour != 12) hour += 12;
        if (amPm.toUpperCase() == 'AM' && hour == 12) hour = 0;
        
        final dt = DateTime(year, month, day, hour, minute);
        return dt.toIso8601String();
      } catch (e) {
        debugPrint('Error parsing date: $text - $e');
        return null;
      }
    }
    
    final startDate = parseDateTime(_start.text.trim());
    final endDate = parseDateTime(_end.text.trim());
    
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid start and end times')),
      );
      return;
    }
    
    setState(() => _saving = true);
    try {
      debugPrint('Creating session with:');
      debugPrint('  categoryId: $_categoryId');
      debugPrint('  trainerId: $_trainerId');
      debugPrint('  description: $description');
      debugPrint('  startDate: $startDate');
      debugPrint('  endDate: $endDate');
      debugPrint('  capacity: $capacity');
      
      await widget.api.createSession({
        'categoryId': _categoryId,
        'trainerId': _trainerId,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'capacity': capacity,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        debugPrint('Error creating session: $e');
        
        // Extract error message from DioException
        String errorMsg = 'Failed to create session';
        if (e.toString().contains('Description must be between')) {
          errorMsg = 'Description must be between 10 and 500 characters';
        } else if (e.toString().contains('Capacity must be between')) {
          errorMsg = 'Capacity must be between 0 and 25';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _sTopBar(context),
            Expanded(
              child: _loadingDropdowns
                  ? const Center(
                      child: CircularProgressIndicator(color: kOrange),
                    )
                  : _dropError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dropError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _loadDropdowns,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOrange,
                              foregroundColor: kBlack,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Session',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kOrange,
                            ),
                          ),
                          const Text(
                            'Schedule New Training Session',
                            style: TextStyle(fontSize: 12, color: kGrey),
                          ),
                          const SizedBox(height: 20),
                          _secTitle('Session Information'),
                          const SizedBox(height: 14),

                          // Category + Trainer
                          Row(
                            children: [
                              Expanded(child: _categoryDropdown()),
                              const SizedBox(width: 14),
                              Expanded(child: _trainerDropdown()),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(fontSize: 12, color: kBlack),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _desc,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 13),
                            decoration: _textAreaDeco,
                          ),
                          const SizedBox(height: 12),

                          // Capacity
                          const Text(
                            'Capacity',
                            style: TextStyle(fontSize: 12, color: kBlack),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _capacity,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: _fieldDeco.copyWith(
                              hintText: 'Minimum Number of Participants',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: kGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _secTitle('Date & Time'),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _dateTimeField(
                                  'Start Date & Time',
                                  _start,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _dateTimeField('End Date & Time', _end),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kBlack,
                                  side: const BorderSide(color: kBorder),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: _saving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  foregroundColor: kBlack,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: kBlack,
                                        ),
                                      )
                                    : const Text(
                                        'Create Session',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 12, color: kBlack)),
        const SizedBox(height: 5),
        DropdownButtonFormField<int>(
          value: _categoryId,
          hint: const Text(
            'Select',
            style: TextStyle(fontSize: 13, color: kGrey),
          ),
          isExpanded: true,
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c['id'] as int,
                  child: Text(
                    c['name'].toString(),
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _categoryId = v),
          decoration: _fieldDeco,
        ),
      ],
    );
  }

  Widget _trainerDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trainer', style: TextStyle(fontSize: 12, color: kBlack)),
        const SizedBox(height: 5),
        DropdownButtonFormField<int>(
          value: _trainerId,
          hint: const Text(
            'Select Trainer',
            style: TextStyle(fontSize: 13, color: kGrey),
          ),
          isExpanded: true,
          items: _trainers
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(
                    t.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _trainerId = v),
          decoration: _fieldDeco,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDIT SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditSessionPage extends StatefulWidget {
  final Session session;
  final ApiService api;
  const EditSessionPage({super.key, required this.session, required this.api});

  @override
  State<EditSessionPage> createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  List<_TrainerItem> _trainers = [];
  bool _loadingTrainers = true;

  int? _trainerId;
  final _desc = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _desc.text = widget.session.description;
    _start.text = widget.session.startTime;
    _end.text = widget.session.endTime;
    _loadTrainers();
  }

  @override
  void dispose() {
    for (final c in [_desc, _start, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTrainers() async {
    try {
      final data = await widget.api.getSessionDropdowns();
      final trainersRaw = data['trainers'] as List? ?? [];
      setState(() {
        _trainers = trainersRaw
            .map((j) => _TrainerItem.fromJson(j as Map<String, dynamic>))
            .toList();
        // حاول تطابق الترينر الحالي بالاسم
        final match = _trainers
            .where((t) => t.name == widget.session.trainer)
            .toList();
        if (match.isNotEmpty) _trainerId = match.first.id;
        _loadingTrainers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTrainers = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.editSession(widget.session.id, {
        'TrainerId': _trainerId,
        'Description': _desc.text.trim(),
        'StartDate': _start.text.trim(),
        'EndDate': _end.text.trim(),
      });
      // تحديث الـ local object
      widget.session.description = _desc.text.trim();
      widget.session.startTime = _start.text.trim();
      widget.session.endTime = _end.text.trim();
      if (_trainerId != null) {
        final match = _trainers.where((t) => t.id == _trainerId).toList();
        if (match.isNotEmpty) widget.session.trainer = match.first.name;
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _sTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Session',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const Text(
                      'Update Session Information',
                      style: TextStyle(fontSize: 12, color: kGrey),
                    ),
                    const SizedBox(height: 20),
                    _secTitle('Session Information'),
                    const SizedBox(height: 14),

                    // Trainer dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trainer',
                          style: TextStyle(fontSize: 12, color: kBlack),
                        ),
                        const SizedBox(height: 5),
                        _loadingTrainers
                            ? const LinearProgressIndicator(color: kOrange)
                            : DropdownButtonFormField<int>(
                                initialValue: _trainerId,
                                hint: const Text(
                                  'Select Trainer',
                                  style: TextStyle(fontSize: 13, color: kGrey),
                                ),
                                items: _trainers
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text(
                                          t.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _trainerId = v),
                                decoration: _fieldDeco,
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 12, color: kBlack),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13),
                      decoration: _textAreaDeco,
                    ),
                    const SizedBox(height: 20),

                    _secTitle('Date & Time'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _dateTimeField('Start Date & Time', _start),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _dateTimeField('End Date & Time', _end),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kBlack,
                            side: const BorderSide(color: kBorder),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            foregroundColor: kBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: kBlack,
                                  ),
                                )
                              : const Text(
                                  'Update Session',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class DeleteSessionPage extends StatefulWidget {
  final Session session;
  final ApiService api;
  const DeleteSessionPage({
    super.key,
    required this.session,
    required this.api,
  });

  @override
  State<DeleteSessionPage> createState() => _DeleteSessionPageState();
}

class _DeleteSessionPageState extends State<DeleteSessionPage> {
  bool _deleting = false;

  Future<void> _confirm() async {
    setState(() => _deleting = true);
    try {
      await widget.api.deleteSession(widget.session.id);
      if (mounted) Navigator.pop(context, 'deleted');
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _sTopBar(context),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: kOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Are you sure you want to delete this Session?',
                          style: TextStyle(
                            fontSize: 14,
                            color: kOrange,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Warning! This action cannot be undone. All member data will be permanently deleted.',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: _deleting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kBlack,
                                side: const BorderSide(color: kBorder),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'NO',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _deleting ? null : _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kOrange,
                                foregroundColor: kBlack,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: _deleting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kBlack,
                                      ),
                                    )
                                  : const Text(
                                      'YES',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════════════════════
Widget _sTopBar(BuildContext context) {
  return Container(
    color: kBlack,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        const Row(
          children: [
            Icon(Icons.bolt, color: kOrange, size: 20),
            Text(
              'FitSync',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: kOrange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Sessions',
            style: TextStyle(
              color: kBlack,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _secTitle(String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: kOrange,
        ),
      ),
      const SizedBox(height: 6),
      const Divider(color: kBorder, height: 1),
    ],
  );
}

Widget _dropdownField({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required String hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        initialValue: value,
        hint: Text(hint, style: const TextStyle(fontSize: 13, color: kGrey)),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: _fieldDeco,
      ),
    ],
  );
}

Widget _dateTimeField(String label, TextEditingController ctrl) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            readOnly: true,
            style: const TextStyle(fontSize: 13),
            decoration: _fieldDeco.copyWith(
              suffixIcon: const Icon(
                Icons.calendar_today,
                size: 16,
                color: kGrey,
              ),
            ),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (c, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(primary: kOrange),
                  ),
                  child: child!,
                ),
              );
              if (d != null) {
                if (!context.mounted) return;
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (c, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(primary: kOrange),
                    ),
                    child: child!,
                  ),
                );
                if (!context.mounted) return;
                if (t != null) {
                  ctrl.text =
                      '${d.day}/${d.month}/${d.year} ${t.format(context)}';
                }
              }
            },
          ),
        ],
      );
    },
  );
}

const _fieldDeco = InputDecoration(
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kOrange),
  ),
);

const _textAreaDeco = InputDecoration(
  hintText: 'Describe the session content and objectives',
  hintStyle: TextStyle(fontSize: 12, color: kGrey),
  contentPadding: EdgeInsets.all(12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: kOrange),
  ),
);
