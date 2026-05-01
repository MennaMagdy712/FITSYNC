import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';

// ── Membership Model ──────────────────────────────────────────────────────────
class Membership {
  final int id;
  final String memberName;
  final String planName;
  final String startDate;
  final String endDate;
  final bool isActive;

  Membership({
    required this.id,
    required this.memberName,
    required this.planName,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: (json['id'] ?? json['Id'] ?? json['memberId'] ?? json['MemberId'] ?? 0) as int,
      memberName: (json['memberName'] ?? json['MemberName'] ??
              json['member']?['name'] ?? json['member']?['Name'] ?? '')
          .toString(),
      planName: (json['planName'] ?? json['PlanName'] ??
              json['plan']?['name'] ?? json['plan']?['Name'] ?? '')
          .toString(),
      startDate: (json['startDate'] ?? json['StartDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? json['EndDate'] ?? '').toString(),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }
}

// ── DropdownItem helpers (جايين من الـ API) ───────────────────────────────────
class _MemberItem {
  final int id;
  final String name;
  final String initials;
  _MemberItem({required this.id, required this.name, required this.initials});

  factory _MemberItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['Name'] ?? '').toString();
    final parts = name.trim().split(' ');
    final initials = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
    return _MemberItem(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: name,
      initials: initials,
    );
  }
}

class _PlanItem {
  final int id;
  final String name;
  final double price;
  _PlanItem({required this.id, required this.name, required this.price});

  factory _PlanItem.fromJson(Map<String, dynamic> json) {
    return _PlanItem(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      price: ((json['price'] ?? json['Price'] ?? 0) as num).toDouble(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBERSHIPS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MembershipsPage extends StatefulWidget {
  final ApiService api;
  const MembershipsPage({super.key, required this.api});

  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  ApiService get _api => widget.api;
  List<Membership> _memberships = [];
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
      final data = await _api.getMemberships();
      if (!mounted) return;
      setState(() {
        _memberships = data
            .map((j) => Membership.fromJson(j as Map<String, dynamic>))
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

  Future<void> _cancel(int index) async {
    final m = _memberships[index];
    try {
      await _api.cancelMembership(m.id);
      if (!mounted) return;
      setState(() => _memberships.removeAt(index));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openCreate() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => CreateMembershipPage(api: _api)),
        )
        .then((result) {
          if (result == true && mounted) _load();
        });
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
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Memberships',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orange header banner
            Container(
              width: double.infinity,
              color: kOrange,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Memberships',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Members That have Active Plans',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'New Membership',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Analytics
            if (!_loading && _error == null) _buildReport(),

            // Table header
            Container(
              color: kLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Member', style: _hStyle)),
                  Expanded(flex: 3, child: Text('Plan', style: _hStyle)),
                  Expanded(flex: 4, child: Text('Start Date', style: _hStyle)),
                  Expanded(flex: 4, child: Text('End Date', style: _hStyle)),
                  SizedBox(width: 32, child: Text('Action', style: _hStyle)),
                ],
              ),
            ),
            const Divider(height: 1, color: kBorder),

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
    if (_memberships.isEmpty) {
      return const Center(
        child: Text('No memberships yet', style: TextStyle(color: kGrey)),
      );
    }
    return ListView.separated(
      itemCount: _memberships.length,
      separatorBuilder: (_, index) => const Divider(height: 1, color: kBorder),
      itemBuilder: (_, i) {
        final m = _memberships[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  m.memberName,
                  style: const TextStyle(fontSize: 12, color: kBlack),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  m.planName,
                  style: const TextStyle(fontSize: 12, color: kBlack),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  m.startDate,
                  style: const TextStyle(fontSize: 11, color: kGrey),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  m.endDate,
                  style: const TextStyle(fontSize: 11, color: kGrey),
                ),
              ),
              SizedBox(
                width: 32,
                child: IconButton(
                  onPressed: () => _cancel(i),
                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  tooltip: 'Cancel Membership',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReport() {
    // Members per plan
    final Map<String, int> membersPerPlan = {};
    for (var m in _memberships) {
      if (m.isActive) {
        membersPerPlan[m.planName] = (membersPerPlan[m.planName] ?? 0) + 1;
      }
    }

    // Popular plans
    Map<String, Map<String, int>> byMonth = {};
    Map<String, Map<String, int>> byYear = {};

    for (var m in _memberships) {
      try {
        final parts = m.startDate.split(' ');
        final dateParts = parts[0].split('/');
        if (dateParts.length == 3) {
          final month = dateParts[0];
          final year = dateParts[2];
          final monthYear = '$month/$year';
          byMonth.putIfAbsent(monthYear, () => {});
          byMonth[monthYear]![m.planName] =
              (byMonth[monthYear]![m.planName] ?? 0) + 1;
          byYear.putIfAbsent(year, () => {});
          byYear[year]![m.planName] = (byYear[year]![m.planName] ?? 0) + 1;
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final monthKey = '${now.month}/${now.year}';
    final yearKey = '${now.year}';

    String popularMonthly = 'N/A';
    String popularYearly = 'N/A';

    if (byMonth[monthKey]?.isNotEmpty == true) {
      popularMonthly = byMonth[monthKey]!.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
    if (byYear[yearKey]?.isNotEmpty == true) {
      popularYearly = byYear[yearKey]!.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membership Analytics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Top Monthly Plan',
                  popularMonthly,
                  Icons.star_border,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard(
                  'Top Yearly Plan',
                  popularYearly,
                  Icons.emoji_events_outlined,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Active Members per Plan:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 6),
          if (membersPerPlan.isEmpty)
            const Text('No data', style: TextStyle(fontSize: 11, color: kGrey))
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Column(
                children: membersPerPlan.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: kBorder)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(fontSize: 11, color: kBlack),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${e.value} Members',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: kOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

const _hStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Color(0xFF555555),
);

// ══════════════════════════════════════════════════════════════════════════════
// CREATE MEMBERSHIP PAGE
// ══════════════════════════════════════════════════════════════════════════════
class CreateMembershipPage extends StatefulWidget {
  final ApiService api;
  const CreateMembershipPage({super.key, required this.api});

  @override
  State<CreateMembershipPage> createState() => _CreateMembershipPageState();
}

class _CreateMembershipPageState extends State<CreateMembershipPage> {
  // Dropdown data from API
  List<_MemberItem> _members = [];
  List<_PlanItem> _plans = [];
  bool _loadingDropdowns = true;
  String? _dropError;

  int? _selectedMemberId;
  int? _selectedPlanId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      setState(() {
        _loadingDropdowns = true;
        _dropError = null;
      });
      // Fetch directly from members and plans endpoints to guarantee completeness
      final membersData = await widget.api.getMembers();
      final plansData = await widget.api.getPlans();
      
      setState(() {
        _members = membersData
            .map((j) => _MemberItem.fromJson(j as Map<String, dynamic>))
            .toList();
        _plans = plansData
            .map((j) => _PlanItem.fromJson(j as Map<String, dynamic>))
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
    if (_selectedMemberId == null || _selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select member and plan')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.api.createMembership({
        'memberId': _selectedMemberId,
        'planId': _selectedPlanId,
      });
      if (mounted) Navigator.pop(context, true);
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
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Memberships',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 11,
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: const BoxDecoration(
                            color: kLight,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Create Membership',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kBlack,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: kBorder),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _loadingDropdowns
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
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
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Member dropdown
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
                                      decoration: _dropDeco,
                                    ),
                                    const SizedBox(height: 16),

                                    // Plan dropdown
                                    const Text(
                                      'Plan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: kBlack,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      initialValue: _selectedPlanId,
                                      hint: const Text(
                                        '--Select Plan--',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kGrey,
                                        ),
                                      ),
                                      items: _plans
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p.id,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.workspace_premium,
                                                    color: kOrange,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${p.price.toStringAsFixed(0)} EGP',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: kGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedPlanId = v),
                                      decoration: _dropDeco,
                                    ),
                                    const SizedBox(height: 24),

                                    // Buttons
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
                                                  'Create Membership',
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

final _dropDeco = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kOrange),
  ),
);
