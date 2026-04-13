import 'package:flutter/material.dart';
import 'constants.dart';
import 'trainers.dart';

// ── Session Model ─────────────────────────────────────────────────────────────
class Session {
  String category, description, trainer, startTime, endTime, duration;
  int capacity, enrolled;
  SessionStatus status;

  Session({
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
}

enum SessionStatus { completed, ongoing, upcoming }

// Shared trainers list — used across the app
final List<Trainer> appTrainers = [
  Trainer(name: 'Youssef Ahmed', email: 'Youssef@gmail.com', phone: '01095121008', initials: 'YA', specializations: ['Martial Arts']),
  Trainer(name: 'Manar Samir',   email: 'Manar@gmail.com',   phone: '01085121008', initials: 'MS', specializations: ['Cross Fit']),
  Trainer(name: 'Menna Gamal',   email: 'Menna@gmail.com',   phone: '01095121008', initials: 'MG', specializations: ['Yoga']),
  Trainer(name: 'Omar Yasser',   email: 'Omar@gmail.com',    phone: '01075121008', initials: 'OY', specializations: ['Cardio']),
  Trainer(name: 'Sara Ahmed',    email: 'Sara@gmail.com',    phone: '01065121008', initials: 'SA', specializations: ['Dance Fitness']),
];

// ══════════════════════════════════════════════════════════════════════════════
// SESSIONS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionsPage extends StatefulWidget {
  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final List<Session> _sessions = [
    Session(category: 'Cross Fit',     description: 'Morning Yoga',              trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.completed),
    Session(category: 'Dance Fitness', description: 'Strength training',          trainer: 'Sara Ahmed',    startTime: 'Mar 02, 2026 11:00 AM', endTime: 'Mar 02, 2026 12:00 AM', duration: '01:00:00', capacity: 15, enrolled: 15, status: SessionStatus.completed),
    Session(category: 'Cross Fit',     description: 'Morning Yoga-Completed',     trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 20, status: SessionStatus.ongoing),
    Session(category: 'Material Arts', description: 'Cardio Blast-Ongoing',       trainer: 'Omar Yasser',   startTime: 'Feb 24, 2026 08:00 AM', endTime: 'Feb 24, 2026 10:00 AM', duration: '02:00:00', capacity: 25, enrolled: 25, status: SessionStatus.ongoing),
    Session(category: 'Dance Fitness', description: 'Strength Training-Upcoming', trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 0,  status: SessionStatus.upcoming),
    Session(category: 'Pilates',       description: 'Morning Yoga',               trainer: 'Youssef Ahmed', startTime: 'Feb 20, 2026 08:00 AM', endTime: 'Feb 20, 2026 09:00 AM', duration: '01:00:00', capacity: 20, enrolled: 0,  status: SessionStatus.upcoming),
  ];

  void _openAdd() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => CreateSessionPage()));
    if (result is Session) setState(() => _sessions.add(result));
  }

  Color _statusColor(SessionStatus s) {
    switch (s) {
      case SessionStatus.completed: return Colors.grey.shade600;
      case SessionStatus.ongoing:   return const Color(0xFF1B6B3A);
      case SessionStatus.upcoming:  return kOrange;
    }
  }

  String _statusLabel(SessionStatus s) {
    switch (s) {
      case SessionStatus.completed: return 'Completed';
      case SessionStatus.ongoing:   return 'Ongoing';
      case SessionStatus.upcoming:  return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            ElevatedButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add, size: 14, color: kBlack),
              label: const Text('Add Session',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ]),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Training Sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Manage Gym Training Sessions And Classes',
                style: TextStyle(fontSize: 11, color: kGrey)),
          ]),
        ),

        // Cards list
        Expanded(child: _sessions.isEmpty
          ? const Center(child: Text('No sessions yet', style: TextStyle(color: kGrey)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = _sessions[i];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _statusColor(s.status),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11), topRight: Radius.circular(11)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_month, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s.category,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_statusLabel(s.status),
                              style: TextStyle(
                                  color: _statusColor(s.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.description,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kBlack)),
                        const SizedBox(height: 8),
                        _infoLine(Icons.person, 'Trainer', s.trainer),
                        _infoLine(Icons.calendar_today, 'Date', s.startTime.split(' ').take(3).join(' ')),
                        _infoLine(Icons.access_time, 'Time', '${s.startTime.split(' ').skip(3).join(' ')}  ${s.endTime.split(' ').skip(3).join(' ')}'),
                        _infoLine(Icons.timer, 'Duration', s.duration),
                        _infoLine(Icons.people, 'Capacity', '${s.enrolled}/${s.capacity} Slots'),
                        const SizedBox(height: 10),

                        // Buttons
                        SizedBox(width: double.infinity, child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => SessionDetailsPage(session: s))),
                          icon: const Icon(Icons.visibility_outlined, size: 14, color: kBlack),
                          label: const Text('View Details', style: TextStyle(color: kBlack, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        )),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => EditSessionPage(session: s)));
                              if (result is Session) setState(() {});
                            },
                            icon: const Icon(Icons.edit_outlined, size: 13, color: kBlack),
                            label: const Text('Edit', style: TextStyle(color: kBlack, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => DeleteSessionPage(session: s)));
                              if (result == 'deleted') setState(() => _sessions.removeAt(i));
                            },
                            icon: const Icon(Icons.delete_outline, size: 13, color: Colors.red),
                            label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          )),
                        ]),
                      ]),
                    ),
                  ]),
                );
              },
            )),
      ])),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: kOrange),
        const SizedBox(width: 6),
        Text('$label : ', style: const TextStyle(fontSize: 11, color: kBlack)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: kBlack, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION DETAILS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class SessionDetailsPage extends StatelessWidget {
  final Session session;
  SessionDetailsPage({required this.session});

  Color get _statusColor {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        _sTopBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kOrange, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              // Orange header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Column(children: [
                  const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                  const SizedBox(height: 6),
                  Text(session.category,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),

              const Divider(height: 1, color: kBorder),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Description
                  _detailCard(Icons.description_outlined, 'Description', session.description, fullWidth: true),
                  const SizedBox(height: 10),
                  // Capacity + Trainer
                  Row(children: [
                    Expanded(child: _detailCard(Icons.people_outline, 'Capacity', '${session.enrolled}/${session.capacity} slots')),
                    const SizedBox(width: 10),
                    Expanded(child: _detailCard(Icons.person_outline, 'Trainer', session.trainer)),
                  ]),
                  const SizedBox(height: 10),
                  // Start + End Time
                  Row(children: [
                    Expanded(child: _detailCard(Icons.access_time, 'Start Time', session.startTime)),
                    const SizedBox(width: 10),
                    Expanded(child: _detailCard(Icons.access_time_filled, 'End Time', session.endTime)),
                  ]),
                  const SizedBox(height: 10),
                  // Duration
                  _detailCard(Icons.timer_outlined, 'Duration',
                      '${session.duration.split(':')[0]} Hours ${session.duration.split(':')[1]} Minutes',
                      fullWidth: true),
                  const SizedBox(height: 16),
                  // Back button
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kOrange, foregroundColor: kBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Back To List', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  )),
                ]),
              ),
            ]),
          ),
        )),
      ])),
    );
  }

  Widget _detailCard(IconData icon, String label, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: kOrange, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, color: kOrange)),
        ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CREATE SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class CreateSessionPage extends StatefulWidget {
  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  String? _category;
  String? _trainer;
  final _desc     = TextEditingController();
  final _capacity = TextEditingController();
  final _start    = TextEditingController();
  final _end      = TextEditingController();

  @override
  void dispose() {
    for (final c in [_desc, _capacity, _start, _end]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (_category == null || _trainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select category and trainer')));
      return;
    }
    Navigator.pop(context, Session(
      category: _category!,
      description: _desc.text.trim(),
      trainer: _trainer!,
      startTime: _start.text.trim(),
      endTime: _end.text.trim(),
      duration: '01:00:00',
      capacity: int.tryParse(_capacity.text) ?? 20,
      enrolled: 0,
      status: SessionStatus.upcoming,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [
        _sTopBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create New Session',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Schedule New Training Session',
                style: TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 20),

            // Session Information
            _secTitle('Session Information'),
            const SizedBox(height: 14),

            // Category + Trainer dropdowns
            Row(children: [
              Expanded(child: _dropdownField(
                label: 'Category',
                value: _category,
                // بيجيب الكاتيجوريز من kAllSpecializations في trainers.dart
                items: kAllSpecializations,
                onChanged: (v) => setState(() => _category = v),
                hint: 'Select Category',
              )),
              const SizedBox(width: 14),
              Expanded(child: _dropdownField(
                label: 'Trainer',
                value: _trainer,
                // بيجيب الترينيرز من appTrainers
                items: appTrainers.map((t) => t.name).toList(),
                onChanged: (v) => setState(() => _trainer = v),
                hint: 'Select Trainer',
              )),
            ]),
            const SizedBox(height: 12),

            // Description
            const Text('Description', style: TextStyle(fontSize: 12, color: kBlack)),
            const SizedBox(height: 5),
            TextField(
              controller: _desc,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe the session content and objectives',
                hintStyle: const TextStyle(fontSize: 12, color: kGrey),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
              ),
            ),
            const SizedBox(height: 12),

            // Capacity
            const Text('Capacity', style: TextStyle(fontSize: 12, color: kBlack)),
            const SizedBox(height: 5),
            SizedBox(width: double.infinity * 0.5, child: TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Minimum Number of Participants',
                hintStyle: const TextStyle(fontSize: 11, color: kGrey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
              ),
            )),
            const SizedBox(height: 20),

            // Date & Time
            _secTitle('Date & Time'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _dateTimeField('Start Date & Time', _start)),
              const SizedBox(width: 14),
              Expanded(child: _dateTimeField('End Date & Time', _end)),
            ]),
            const SizedBox(height: 24),

            // Buttons
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBlack, side: const BorderSide(color: kBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange, foregroundColor: kBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('Creat Session', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        )),
      ])),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDIT SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditSessionPage extends StatefulWidget {
  final Session session;
  EditSessionPage({required this.session});
  @override
  State<EditSessionPage> createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  String? _trainer;
  final _desc  = TextEditingController();
  final _start = TextEditingController();
  final _end   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trainer = appTrainers.any((t) => t.name == widget.session.trainer)
        ? widget.session.trainer : null;
    _desc.text  = widget.session.description;
    _start.text = widget.session.startTime;
    _end.text   = widget.session.endTime;
  }

  @override
  void dispose() {
    for (final c in [_desc, _start, _end]) c.dispose();
    super.dispose();
  }

  void _save() {
    if (_trainer != null) widget.session.trainer = _trainer!;
    widget.session.description = _desc.text.trim();
    widget.session.startTime   = _start.text.trim();
    widget.session.endTime     = _end.text.trim();
    Navigator.pop(context, widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [
        _sTopBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Edit Session',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Update Session Information',
                style: TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 20),

            _secTitle('Session Information'),
            const SizedBox(height: 14),

            // Trainer dropdown — من appTrainers
            _dropdownField(
              label: 'Trainer',
              value: _trainer,
              items: appTrainers.map((t) => t.name).toList(),
              onChanged: (v) => setState(() => _trainer = v),
              hint: 'Select Trainer',
            ),
            const SizedBox(height: 12),

            // Description
            const Text('Description', style: TextStyle(fontSize: 12, color: kBlack)),
            const SizedBox(height: 5),
            TextField(
              controller: _desc,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe the session content and objectives',
                hintStyle: const TextStyle(fontSize: 12, color: kGrey),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
              ),
            ),
            const SizedBox(height: 20),

            _secTitle('Date & Time'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _dateTimeField('Start Date & Time', _start)),
              const SizedBox(width: 14),
              Expanded(child: _dateTimeField('End Date & Time', _end)),
            ]),
            const SizedBox(height: 24),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBlack, side: const BorderSide(color: kBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange, foregroundColor: kBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('Update Session', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        )),
      ])),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE SESSION PAGE
// ══════════════════════════════════════════════════════════════════════════════
class DeleteSessionPage extends StatelessWidget {
  final Session session;
  DeleteSessionPage({required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        _sTopBar(context),
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kOrange, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Warning icon
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: kOrange, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Are you sure you want to delete this Session?',
                  style: const TextStyle(fontSize: 14, color: kOrange, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlack, side: const BorderSide(color: kBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('NO', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'deleted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange, foregroundColor: kBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('YES', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ]),
            ]),
          ),
        ))),
      ])),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
Widget _sTopBar(BuildContext context) {
  return Container(
    color: kBlack,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      const Row(children: [
        Icon(Icons.bolt, color: kOrange, size: 20),
        Text('FitSync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
        child: const Text('Sessions', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}

Widget _secTitle(String text) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kOrange)),
    const SizedBox(height: 6),
    const Divider(color: kBorder, height: 1),
  ]);
}

Widget _dropdownField({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required String hint,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
    const SizedBox(height: 5),
    DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: const TextStyle(fontSize: 13, color: kGrey)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
      ),
    ),
  ]);
}

Widget _dateTimeField(String label, TextEditingController ctrl) {
  return StatefulBuilder(builder: (context, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, readOnly: true,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: const Icon(Icons.calendar_today, size: 16, color: kGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
        ),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030),
            builder: (c, child) => Theme(
              data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: kOrange)),
              child: child!,
            ),
          );
          if (d != null) {
            final t = await showTimePicker(
              context: context, initialTime: TimeOfDay.now(),
              builder: (c, child) => Theme(
                data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: kOrange)),
                child: child!,
              ),
            );
            if (t != null) {
              ctrl.text = '${d.day}/${d.month}/${d.year} ${t.format(context)}';
            }
          }
        },
      ),
    ]);
  });
}
