import 'package:flutter/material.dart';
import 'constants.dart';
import 'sessions.dart';
import 'memberships.dart';

// ── Booking Model ─────────────────────────────────────────────────────────────
class Booking {
  final String memberName, memberInitials;
  Booking({required this.memberName, required this.memberInitials});
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSIONS SCHEDULE PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionsSchedulePage extends StatefulWidget {
  @override
  State<SessionsSchedulePage> createState() => _SessionsSchedulePageState();
}

class _SessionsSchedulePageState extends State<SessionsSchedulePage> {
  // Upcoming sessions — للحجز
  final List<Session> _upcomingSessions = [
    Session(category: 'Pilates',       description: 'Morning Yoga',              trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.upcoming),
    Session(category: 'Pilates',       description: 'Morning Yoga',              trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.upcoming),
    Session(category: 'Cross Fit',     description: 'Morning Yoga',              trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.upcoming),
  ];

  // Ongoing sessions — للحضور
  final List<Session> _ongoingSessions = [
    Session(category: 'Cross Fit',     description: 'Morning Yoga-Completed',    trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.ongoing),
    Session(category: 'Material Arts', description: 'Cardio Blast-Ongoing',      trainer: 'Omar Yasser',   startTime: 'Feb 24, 2026 08:00 AM', endTime: 'Feb 24, 2026 10:00 AM', duration: '02:00:00', capacity: 25, enrolled: 25, status: SessionStatus.ongoing),
  ];

  // Map to track bookings per session
  final Map<int, List<Booking>> _bookings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        // Top bar
        Container(
          color: kBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Row(children: [
              Icon(Icons.bolt, color: kOrange, size: 20),
              Text('FitSync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Sessions Schedule',
                  style: TextStyle(color: kBlack, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Upcoming: Member Session (Booking) ──
            const Text('Member Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Session Valid For Manage Booking',
                style: TextStyle(fontSize: 11, color: kGrey)),
            const SizedBox(height: 10),

            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _upcomingSessions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(
                  width: 210,
                  child: _SessionScheduleCard(
                    session: _upcomingSessions[i],
                    bookings: _bookings[i] ?? [],
                    onViewMembers: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SessionMembersPage(
                          session: _upcomingSessions[i],
                          bookings: _bookings[i] ?? [],
                          onAddBooking: (b) => setState(() {
                            _bookings[i] = [...(_bookings[i] ?? []), b];
                          }),
                        ))),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Ongoing: Member Session (Attendance) ──
            const Text('Member Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Session Valid For Manage Attendance',
                style: TextStyle(fontSize: 11, color: kGrey)),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ongoingSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final idx = _upcomingSessions.length + i;
                return _SessionScheduleCard(
                  session: _ongoingSessions[i],
                  bookings: _bookings[idx] ?? [],
                  onViewMembers: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SessionMembersPage(
                        session: _ongoingSessions[i],
                        bookings: _bookings[idx] ?? [],
                        onAddBooking: (b) => setState(() {
                          _bookings[idx] = [...(_bookings[idx] ?? []), b];
                        }),
                      ))),
                );
              },
            ),
          ]),
        )),
      ])),
    );
  }
}

// ── Session Schedule Card ─────────────────────────────────────────────────────
class _SessionScheduleCard extends StatelessWidget {
  final Session session;
  final List<Booking> bookings;
  final VoidCallback onViewMembers;

  _SessionScheduleCard({
    required this.session,
    required this.bookings,
    required this.onViewMembers,
  });

  Color get _headerColor {
    switch (session.status) {
      case SessionStatus.completed: return Colors.grey.shade600;
      case SessionStatus.ongoing:   return const Color(0xFF1B6B3A);
      case SessionStatus.upcoming:  return kOrange;
    }
  }

  String get _statusLabel {
    switch (session.status) {
      case SessionStatus.completed: return 'Completed';
      case SessionStatus.ongoing:   return 'Ongoing';
      case SessionStatus.upcoming:  return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _headerColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11), topRight: Radius.circular(11)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_month, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(session.category,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(_statusLabel,
                  style: TextStyle(color: _headerColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.description,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
            const SizedBox(height: 6),
            _line(Icons.person,        'Trainer',  session.trainer),
            _line(Icons.calendar_today,'Date',     session.startTime.split(' ').take(3).join(' ')),
            _line(Icons.access_time,   'Time',     '${session.startTime.split(' ').skip(3).join(' ')}  ${session.endTime.split(' ').skip(3).join(' ')}'),
            _line(Icons.timer,         'Duration', session.duration),
            _line(Icons.people,        'Capacity', '${session.enrolled}/${session.capacity} Slots'),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: onViewMembers,
              icon: const Icon(Icons.visibility_outlined, size: 13, color: kBlack),
              label: const Text('View Members', style: TextStyle(color: kBlack, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _line(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Icon(icon, size: 12, color: kOrange),
        const SizedBox(width: 4),
        Text('$label : ', style: const TextStyle(fontSize: 10, color: kBlack)),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 10, color: kBlack, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION MEMBERS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionMembersPage extends StatefulWidget {
  final Session session;
  final List<Booking> bookings;
  final Function(Booking) onAddBooking;

  SessionMembersPage({
    required this.session,
    required this.bookings,
    required this.onAddBooking,
  });

  @override
  State<SessionMembersPage> createState() => _SessionMembersPageState();
}

class _SessionMembersPageState extends State<SessionMembersPage> {
  late List<Booking> _localBookings;

  @override
  void initState() {
    super.initState();
    _localBookings = List.from(widget.bookings);
  }

  void _openNewBooking() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => NewBookingPage(
          onBook: (booking) {
            setState(() => _localBookings.add(booking));
            widget.onAddBooking(booking);
          },
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        // Top bar
        Container(
          color: kBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Row(children: [
              Icon(Icons.bolt, color: kOrange, size: 20),
              Text('FitSync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Sessions Schedule',
                  style: TextStyle(color: kBlack, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Orange banner
        Container(
          width: double.infinity,
          color: kOrange,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Session Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Members That Already Book Session',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ])),
            ElevatedButton(
              onPressed: _openNewBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
              ),
              child: const Text('New Booking',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ]),
        ),

        // Members list or empty state
        Expanded(child: Column(children: [
          Expanded(child: _localBookings.isEmpty
            ? Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.people, color: Colors.red.shade300, size: 48),
                  const SizedBox(height: 10),
                  const Text('No Bookings Available',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kBlack)),
                  const Text('Add your first booking to get started',
                      style: TextStyle(fontSize: 12, color: kGrey)),
                ]),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _localBookings.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: kBorder),
                itemBuilder: (_, i) {
                  final b = _localBookings[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(b.memberInitials,
                            style: const TextStyle(color: kBlack, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(b.memberName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kBlack))),
                      IconButton(
                        onPressed: () => setState(() => _localBookings.removeAt(i)),
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        padding: EdgeInsets.zero,
                      ),
                    ]),
                  );
                },
              )),

          // Back To List button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange, foregroundColor: kBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text('Back To List',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            )),
          ),
        ])),
      ])),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NEW BOOKING PAGE
// ══════════════════════════════════════════════════════════════════════════════
class NewBookingPage extends StatefulWidget {
  final Function(Booking) onBook;
  NewBookingPage({required this.onBook});

  @override
  State<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends State<NewBookingPage> {
  String? _selectedMember;

  void _submit() {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a member')));
      return;
    }
    final member = appMembers.firstWhere((m) => m.name == _selectedMember);
    widget.onBook(Booking(
      memberName: member.name,
      memberInitials: member.initials,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        // Top bar
        Container(
          color: kBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Row(children: [
              Icon(Icons.bolt, color: kOrange, size: 20),
              Text('FitSync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Sessions Schedule',
                  style: TextStyle(color: kBlack, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kOrange, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Center(
                  child: Text('Booking Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kBlack)),
                ),
              ),
              const Divider(height: 1, color: kBorder),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Member dropdown — من appMembers
                  const Text('Member',
                      style: TextStyle(fontSize: 13, color: kBlack, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedMember,
                    hint: const Text('--Select Member--',
                        style: TextStyle(fontSize: 13, color: kGrey)),
                    items: appMembers.map((m) => DropdownMenuItem(
                      value: m.name,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 26, height: 26,
                          decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(m.initials,
                              style: const TextStyle(color: kBlack, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Text(m.name, style: const TextStyle(fontSize: 13)),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedMember = v),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kOrange)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(children: [
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange, foregroundColor: kBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Create Booking',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGrey,
                        side: const BorderSide(color: kGrey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ))),
      ])),
    );
  }
}
