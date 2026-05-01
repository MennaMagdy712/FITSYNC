import 'package:flutter/material.dart';
import 'api_service.dart';
import 'constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MEMBER PORTAL PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MemberPortalPage extends StatefulWidget {
  final ApiService api;
  const MemberPortalPage({super.key, required this.api});

  @override
  State<MemberPortalPage> createState() => _MemberPortalPageState();
}

class _MemberPortalPageState extends State<MemberPortalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Data holders
  Map<String, dynamic>? _homeData;
  Map<String, dynamic>? _details;
  Map<String, dynamic>? _healthRecord;
  Map<String, dynamic>? _plan;
  List<dynamic>? _sessions;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.getMemberPortalHome(),
        widget.api.getMemberPortalDetails(),
        widget.api.getMemberPortalHealthRecord(),
        widget.api.getMemberPortalPlan(),
        widget.api.getMemberPortalSessions(),
      ]);
      if (!mounted) return;
      setState(() {
        _homeData = results[0] as Map<String, dynamic>;
        _details = results[1] as Map<String, dynamic>;
        _healthRecord = results[2] as Map<String, dynamic>;
        _plan = results[3] as Map<String, dynamic>;
        _sessions = results[4] as List<dynamic>;
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

  void _logout() {
    widget.api.clearToken();
    Navigator.of(context).pop();
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kOrange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'Member Portal',
                      style: TextStyle(
                        color: kOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadAll,
                    icon: const Icon(Icons.refresh, color: kGrey, size: 18),
                    padding: EdgeInsets.zero,
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: kBlack,
              child: TabBar(
                controller: _tab,
                labelColor: kOrange,
                unselectedLabelColor: kGrey,
                indicatorColor: kOrange,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'Home'),
                  Tab(text: 'Profile'),
                  Tab(text: 'Health'),
                  Tab(text: 'Sessions'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: kOrange),
                    )
                  : _error != null
                  ? _buildError()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: kBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_tab.index) {
      case 0:
        return _buildHome();
      case 1:
        return _buildProfile();
      case 2:
        return _buildHealth();
      case 3:
        return _buildSessions();
      default:
        return _buildHome();
    }
  }

  // ── HOME ─────────────────────────────────────────────────────────────────────
  Widget _buildHome() {
    final name = _homeData?['name'] ??
        _details?['name'] ??
        _details?['Name'] ??
        'Member';
    final planName = _homeData?['planName'] ??
        _plan?['PlanName'] ??
        _plan?['planName'] ??
        'No Plan';
    final endDate = _homeData?['memberShipEndDate'] ??
        _plan?['MemberShipEndDate'] ??
        _plan?['memberShipEndDate'] ??
        '';
    final sessionsCount = (_sessions?.length ?? 0).toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF2A1800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: kOrange,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.toString().isNotEmpty
                        ? name.toString().substring(0, 1).toUpperCase()
                        : 'M',
                    style: const TextStyle(
                      color: kBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back,',
                        style: TextStyle(color: kGrey, fontSize: 12),
                      ),
                      Text(
                        name.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.card_membership,
                  'Current Plan',
                  planName.toString(),
                  kOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.calendar_month,
                  'Sessions',
                  '$sessionsCount booked',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (endDate.isNotEmpty)
            _infoTile(
              Icons.event_available,
              'Membership Expires',
              endDate.toString().split('T').first,
              Colors.green,
            ),
          const SizedBox(height: 16),

          // Quick Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        Icons.person_outline,
                        'Profile',
                        () => _tab.animateTo(1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        Icons.favorite_border,
                        'Health',
                        () => _tab.animateTo(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        Icons.sports_gymnastics,
                        'Sessions',
                        () => _tab.animateTo(3),
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
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: kOrange, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kBlack),
            ),
          ],
        ),
      ),
    );
  }

  // ── PROFILE ──────────────────────────────────────────────────────────────────
  Widget _buildProfile() {
    final d = _details ?? {};
    final fields = <String, String>{
      'Name': _str(d['name'] ?? d['Name']),
      'Email': _str(d['email'] ?? d['Email']),
      'Phone': _str(d['phone'] ?? d['Phone'] ?? d['phoneNumber'] ?? d['PhoneNumber']),
      'Gender': _str(d['gender'] ?? d['Gender']),
      'Date of Birth': _str(d['dob'] ?? d['dateOfBirth'] ?? d['DateOfBirth'])
          .split('T')
          .first,
      'Address': _str(d['address'] ?? d['Address']),
      'Current Plan': _str(
        _plan?['PlanName'] ?? _plan?['planName'] ?? d['planName'],
      ),
      'Plan Expires': _str(
            _plan?['MemberShipEndDate'] ?? _plan?['memberShipEndDate'],
          )
          .split('T')
          .first,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: kOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _str(d['name'] ?? d['Name']).isNotEmpty
                  ? _str(d['name'] ?? d['Name'])
                      .substring(0, 1)
                      .toUpperCase()
                  : 'M',
              style: const TextStyle(
                color: kBlack,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _str(d['name'] ?? d['Name']),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const SizedBox(height: 20),

          // Info
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: fields.entries
                  .where((e) => e.value.isNotEmpty)
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: kBorder)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: kBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEALTH ───────────────────────────────────────────────────────────────────
  Widget _buildHealth() {
    final h = _healthRecord ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: kOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                'Health Record',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _healthCard(
                        Icons.monitor_weight,
                        'Weight',
                        _str(h['weight'] ?? h['Weight']),
                        Colors.orange,
                        'kg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _healthCard(
                        Icons.height,
                        'Height',
                        _str(h['height'] ?? h['Height']),
                        Colors.blue,
                        'cm',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _healthCard(
                        Icons.bloodtype,
                        'Blood Type',
                        _str(h['bloodType'] ?? h['BloodType']),
                        Colors.red,
                        '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _healthCard(
                        Icons.note,
                        'Note',
                        _str(h['note'] ?? h['Note']).isEmpty
                            ? 'No Note'
                            : _str(h['note'] ?? h['Note']),
                        Colors.green,
                        '',
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
  }

  Widget _healthCard(
    IconData icon,
    String label,
    String value,
    Color color,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: kGrey),
                ),
                Text(
                  value.isEmpty ? '-' : '$value $unit'.trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SESSIONS ─────────────────────────────────────────────────────────────────
  Widget _buildSessions() {
    final sessions = _sessions ?? [];
    if (sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_gymnastics, color: kGrey, size: 48),
            SizedBox(height: 12),
            Text(
              'No sessions booked yet',
              style: TextStyle(color: kGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = sessions[i] as Map<String, dynamic>;
        final name = _str(s['sessionName'] ?? s['SessionName'] ?? s['name'] ?? s['Name']);
        final trainer = _str(
          s['trainerName'] ?? s['TrainerName'] ?? s['trainer'],
        );
        final date = _str(
          s['sessionDate'] ?? s['SessionDate'] ?? s['date'],
        ).split('T').first;
        final status = _str(s['status'] ?? s['Status'] ?? s['bookingStatus']);
        final statusColor = status.toLowerCase().contains('attended')
            ? Colors.green
            : status.toLowerCase().contains('cancel')
            ? Colors.red
            : kOrange;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: kBlack,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Session ${i + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kBlack,
                      ),
                    ),
                    if (trainer.isNotEmpty)
                      Text(
                        'Trainer: $trainer',
                        style: const TextStyle(fontSize: 11, color: kGrey),
                      ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: const TextStyle(fontSize: 11, color: kGrey),
                      ),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _str(dynamic v) => v?.toString() ?? '';
}
