import 'package:flutter/material.dart';
import 'constants.dart';
import 'sessions.dart';
import 'api_service.dart';

// ── Booking Model ─────────────────────────────────────────────────────────────
class Booking {
  final int memberId;
  final int sessionId;
  final String memberName, memberInitials;
  bool attended;

  Booking({
    required this.memberId,
    required this.sessionId,
    required this.memberName,
    required this.memberInitials,
    this.attended = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Backend returns MemberForSessionViewModel:
    // MemberId, MemberName, SessionId, BookingDate, IsAttended
    final name = (json['memberName'] ?? json['MemberName'] ??
            json['member']?['name'] ?? '')
        .toString();
    final parts = name.trim().split(' ');
    final initials = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
    return Booking(
      memberId: json['memberId'] ?? json['MemberId'] ?? 0,
      sessionId: json['sessionId'] ?? json['SessionId'] ?? 0,
      memberName: name,
      memberInitials: initials,
      attended: json['isAttended'] ?? json['IsAttended'] ??
          json['attended'] ?? false,
    );
  }
}

// ── Member Dropdown Item ───────────────────────────────────────────────────────
class _MemberItem {
  final int id;
  final String name, initials;
  _MemberItem({required this.id, required this.name, required this.initials});

  factory _MemberItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final parts = name.trim().split(' ');
    final initials = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
    return _MemberItem(id: json['id'] ?? 0, name: name, initials: initials);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSIONS SCHEDULE PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionsSchedulePage extends StatefulWidget {
  final ApiService api;
  const SessionsSchedulePage({super.key, required this.api});

  @override
  State<SessionsSchedulePage> createState() => _SessionsSchedulePageState();
}

class _SessionsSchedulePageState extends State<SessionsSchedulePage> {
  ApiService get _api => widget.api;

  List<Session> _upcomingSessions = [];
  List<Session> _ongoingSessions = [];
  List<Session> _completedSessions = [];
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
      final all = data
          .map((j) => Session.fromJson(j as Map<String, dynamic>))
          .toList();
      setState(() {
        _upcomingSessions = all
            .where((s) => s.status == SessionStatus.upcoming)
            .toList();
        _ongoingSessions = all
            .where((s) => s.status == SessionStatus.ongoing)
            .toList();
        _completedSessions = all
            .where((s) => s.status == SessionStatus.completed)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upcoming ──
          const Text(
            'Member Session',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const Text(
            'Session Valid For Manage Booking',
            style: TextStyle(fontSize: 11, color: kGrey),
          ),
          const SizedBox(height: 10),

          if (_upcomingSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No upcoming sessions',
                style: TextStyle(color: kGrey, fontSize: 12),
              ),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _upcomingSessions.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(
                  width: 210,
                  child: _SessionScheduleCard(
                    session: _upcomingSessions[i],
                    onViewMembers: () => _openMembers(_upcomingSessions[i]),
                    onAddMember: () => _openAddMember(_upcomingSessions[i]),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ── Ongoing ──
          const Text(
            'Member Session',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const Text(
            'Session Valid For Manage Attendance',
            style: TextStyle(fontSize: 11, color: kGrey),
          ),
          const SizedBox(height: 10),

          if (_ongoingSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No ongoing sessions',
                style: TextStyle(color: kGrey, fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ongoingSessions.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _SessionScheduleCard(
                session: _ongoingSessions[i],
                onViewMembers: () => _openMembers(_ongoingSessions[i]),
                // No Add Member for ongoing sessions
              ),
            ),

          const SizedBox(height: 20),

          // ── Completed ──
          const Text(
            'Completed Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const Text(
            'Past Sessions',
            style: TextStyle(fontSize: 11, color: kGrey),
          ),
          const SizedBox(height: 10),

          if (_completedSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No completed sessions',
                style: TextStyle(color: kGrey, fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _completedSessions.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _SessionScheduleCard(
                session: _completedSessions[i],
                onViewMembers: () => _openMembers(_completedSessions[i]),
                // No Add Member for completed sessions
              ),
            ),
        ],
      ),
    );
  }

  void _openMembers(Session session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionMembersPage(session: session, api: _api),
      ),
    );
  }

  void _openAddMember(Session session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingPage(
          sessionId: session.id,
          api: _api,
          onBooked: _load,
        ),
      ),
    );
  }

  Widget _topBar() {
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Sessions Schedule',
              style: TextStyle(
                color: kBlack,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session Schedule Card ─────────────────────────────────────────────────────
class _SessionScheduleCard extends StatelessWidget {
  final Session session;
  final VoidCallback onViewMembers;
  final VoidCallback? onAddMember;

  const _SessionScheduleCard({
    required this.session,
    required this.onViewMembers,
    this.onAddMember,
  });

  Color get _headerColor {
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _headerColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
                const SizedBox(height: 6),
                _line(Icons.person, 'Trainer', session.trainer),
                _line(
                  Icons.calendar_today,
                  'Date',
                  session.startTime.split(' ').take(3).join(' '),
                ),
                _line(
                  Icons.access_time,
                  'Time',
                  '${session.startTime.split(' ').skip(3).join(' ')}  '
                      '${session.endTime.split(' ').skip(3).join(' ')}',
                ),
                _line(Icons.timer, 'Duration', session.duration),
                _line(
                  Icons.people,
                  'Capacity',
                  '${session.enrolled}/${session.capacity} Slots',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onViewMembers,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 13,
                      color: kBlack,
                    ),
                    label: const Text(
                      'View Members',
                      style: TextStyle(color: kBlack, fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                // Add Member button – only for upcoming sessions
                if (session.status == SessionStatus.upcoming &&
                    onAddMember != null) ...
                  [
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onAddMember,
                        icon: const Icon(
                          Icons.person_add_outlined,
                          size: 13,
                          color: kBlack,
                        ),
                        label: const Text(
                          'Add Member',
                          style: TextStyle(
                            color: kBlack,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: kOrange),
          const SizedBox(width: 4),
          Text(
            '$label : ',
            style: const TextStyle(fontSize: 10, color: kBlack),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
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
// SESSION MEMBERS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionMembersPage extends StatefulWidget {
  final Session session;
  final ApiService api;

  const SessionMembersPage({
    super.key,
    required this.session,
    required this.api,
  });

  @override
  State<SessionMembersPage> createState() => _SessionMembersPageState();
}

class _SessionMembersPageState extends State<SessionMembersPage> {
  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;

  bool get _isOngoing => widget.session.status == SessionStatus.ongoing;

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
      final data = _isOngoing
          ? await widget.api.getMembersForOngoingSession(widget.session.id)
          : await widget.api.getMembersForUpcomingSession(widget.session.id);
      if (!mounted) return;
      setState(() {
        _bookings = data
            .map((j) => Booking.fromJson(j as Map<String, dynamic>))
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

  Future<void> _cancelBooking(int index) async {
    final b = _bookings[index];
    try {
      // Backend MemberAttendOrCancelViewModel expects MemberId + SessionId
      await widget.api.cancelBooking({
        'MemberId': b.memberId,
        'SessionId': b.sessionId,
      });
      if (!mounted) return;
      setState(() => _bookings.removeAt(index));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAttended(int index) async {
    final b = _bookings[index];
    try {
      // Backend MemberAttendOrCancelViewModel expects MemberId + SessionId
      await widget.api.markAttended({
        'MemberId': b.memberId,
        'SessionId': b.sessionId,
      });
      if (!mounted) return;
      setState(() => _bookings[index].attended = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openNewBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingPage(
          sessionId: widget.session.id,
          api: widget.api,
          onBooked: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sessions Schedule',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orange banner
            Container(
              width: double.infinity,
              color: kOrange,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session Members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Members That Already Book Session',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  if (!_isOngoing)
                    ElevatedButton(
                      onPressed: _openNewBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'New Booking',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildList()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          foregroundColor: kBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kOrange));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
    if (_bookings.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 10),
            const Text(
              'No Bookings Available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kBlack,
              ),
            ),
            const Text(
              'Add your first booking to get started',
              style: TextStyle(fontSize: 12, color: kGrey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      separatorBuilder: (_, index) => const Divider(height: 1, color: kBorder),
      itemBuilder: (_, i) {
        final b = _bookings[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  b.memberInitials,
                  style: const TextStyle(
                    color: kBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b.memberName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kBlack,
                  ),
                ),
              ),

              // Ongoing → زرار Attended
              if (_isOngoing)
                b.attended
                    ? const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 22,
                        ),
                      )
                    : TextButton(
                        onPressed: () => _markAttended(i),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Attended',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),

              // Upcoming → زرار Cancel
              if (!_isOngoing)
                IconButton(
                  onPressed: () => _cancelBooking(i),
                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NEW BOOKING PAGE
// ══════════════════════════════════════════════════════════════════════════════
class NewBookingPage extends StatefulWidget {
  final int sessionId;
  final ApiService api;
  final VoidCallback onBooked;

  const NewBookingPage({
    super.key,
    required this.sessionId,
    required this.api,
    required this.onBooked,
  });

  @override
  State<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends State<NewBookingPage> {
  List<_MemberItem> _members = [];
  bool _loadingMembers = true;
  String? _dropError;

  int? _selectedMemberId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _loadingMembers = true;
        _dropError = null;
      });
      final data = await widget.api.getMembers();
      if (!mounted) return;
      setState(() {
        _members = data
            .map((j) => _MemberItem.fromJson(j as Map<String, dynamic>))
            .toList();
        _loadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dropError = e.toString();
        _loadingMembers = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.api.createBooking({
        'memberId': _selectedMemberId,
        'sessionId': widget.sessionId,
      });
      widget.onBooked();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sessions Schedule',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: const BoxDecoration(
                            color: kLight,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Booking Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: kBlack,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: kBorder),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _loadingMembers
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: kOrange,
                                    ),
                                  ),
                                )
                              : _dropError != null
                              ? Column(
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
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _loadMembers,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kOrange,
                                        foregroundColor: kBlack,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Member',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: kBlack,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      initialValue: _selectedMemberId,
                                      hint: const Text(
                                        '--Select Member--',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kGrey,
                                        ),
                                      ),
                                      items: _members
                                          .map(
                                            (m) => DropdownMenuItem(
                                              value: m.id,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 26,
                                                    height: 26,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: kOrange,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      m.initials,
                                                      style: const TextStyle(
                                                        color: kBlack,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    m.name,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedMemberId = v),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: kBorder,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: kBorder,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: kOrange,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _submitting
                                              ? null
                                              : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kOrange,
                                            foregroundColor: kBlack,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _submitting
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: kBlack,
                                                      ),
                                                )
                                              : const Text(
                                                  'Create Booking',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton(
                                          onPressed: _submitting
                                              ? null
                                              : () => Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: kGrey,
                                            side: const BorderSide(
                                              color: kGrey,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
