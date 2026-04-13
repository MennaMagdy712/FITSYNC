import 'package:flutter/material.dart';
import 'constants.dart';
import 'members.dart';
import 'plans.dart';

// ── Membership Model ──────────────────────────────────────────────────────────
class Membership {
  String memberName, planName, startDate, endDate;
  bool isActive;

  Membership({
    required this.memberName,
    required this.planName,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}

// Shared data — same members and plans used across the app
final List<Member> appMembers = [
  Member(
      name: 'Mohammed Ahmed',
      email: 'mohammed@gmail.com',
      phone: '01095121008',
      initials: 'MA'),
  Member(
      name: 'Manar Samir',
      email: 'Manar@gmail.com',
      phone: '01085121008',
      initials: 'MS'),
  Member(
      name: 'Menna Gamal',
      email: 'Menna@gmail.com',
      phone: '01095121008',
      initials: 'MG'),
  Member(
      name: 'Youssef Ahmed',
      email: 'Youssef@gmail.com',
      phone: '01075121008',
      initials: 'YA'),
  Member(
      name: 'Sara Ahmed',
      email: 'Sara@gmail.com',
      phone: '01065121008',
      initials: 'SA'),
];

final List<Plan> appPlans = [
  Plan(
      name: 'Basic Plan',
      price: 700,
      duration: 30,
      description: 'Access to gym equipment during staffed hours'),
  Plan(
      name: 'Standard Plan',
      price: 1200,
      duration: 60,
      description: 'Includes gym equipment and 2 group classes per week'),
  Plan(
      name: 'Premium Plan',
      price: 900,
      duration: 90,
      description: 'Unlimited access to equipment, classes, and sauna'),
  Plan(
      name: 'Annual Plan',
      price: 3000,
      duration: 365,
      description: 'Full year access with personal trainer sessions'),
];

// ══════════════════════════════════════════════════════════════════════════════
// MEMBERSHIPS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MembershipsPage extends StatefulWidget {
  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  final List<Membership> _memberships = [
    Membership(
        memberName: 'Youssef Ahmed',
        planName: 'Standard Plan',
        startDate: '3/8/2025  10:00:03 AM',
        endDate: '5/11/2025  10:00:03 AM'),
    Membership(
        memberName: 'Manar Samir',
        planName: 'Annual Plan',
        startDate: '10/8/2025  8:30:00 AM',
        endDate: '10/12/2025  10:00:03 AM'),
  ];

  void _openCreate() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (_) => CreateMembershipPage()),
    )
        .then((result) {
      if (result is Membership && mounted) {
        setState(() => _memberships.add(result));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(children: [
        // Top bar
        Container(
          color: kBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Row(children: [
              Icon(Icons.bolt, color: kOrange, size: 20),
              Text('FitSync',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Memberships',
                  style: TextStyle(
                      color: kBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Orange header banner
        Container(
          width: double.infinity,
          color: kOrange,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Active Memberships',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text('Members That have Active Plans',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                ])),
            ElevatedButton(
              onPressed: _openCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kBlack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: const Text('New Membership',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ]),
        ),

        // Table header
        Container(
          color: kLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(children: [
            Expanded(flex: 3, child: Text('Member', style: _hStyle)),
            Expanded(flex: 3, child: Text('Plan', style: _hStyle)),
            Expanded(flex: 4, child: Text('Start Date', style: _hStyle)),
            Expanded(flex: 4, child: Text('End Date', style: _hStyle)),
            SizedBox(width: 32, child: Text('Action', style: _hStyle)),
          ]),
        ),
        const Divider(height: 1, color: kBorder),

        // List
        Expanded(
            child: _memberships.isEmpty
                ? const Center(
                    child: Text('No memberships yet',
                        style: TextStyle(color: kGrey)))
                : ListView.separated(
                    itemCount: _memberships.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: kBorder),
                    itemBuilder: (_, i) {
                      final m = _memberships[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Expanded(
                              flex: 3,
                              child: Text(m.memberName,
                                  style: const TextStyle(
                                      fontSize: 12, color: kBlack))),
                          Expanded(
                              flex: 3,
                              child: Text(m.planName,
                                  style: const TextStyle(
                                      fontSize: 12, color: kBlack))),
                          Expanded(
                              flex: 4,
                              child: Text(m.startDate,
                                  style: const TextStyle(
                                      fontSize: 11, color: kGrey))),
                          Expanded(
                              flex: 4,
                              child: Text(m.endDate,
                                  style: const TextStyle(
                                      fontSize: 11, color: kGrey))),
                          SizedBox(
                            width: 32,
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _memberships.removeAt(i)),
                              icon: const Icon(Icons.close,
                                  color: Colors.red, size: 18),
                              padding: EdgeInsets.zero,
                              tooltip: 'Cancel Membership',
                            ),
                          ),
                        ]),
                      );
                    },
                  )),
      ])),
    );
  }
}

const _hStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555));

// ══════════════════════════════════════════════════════════════════════════════
// CREATE MEMBERSHIP PAGE
// ══════════════════════════════════════════════════════════════════════════════
class CreateMembershipPage extends StatefulWidget {
  @override
  State<CreateMembershipPage> createState() => _CreateMembershipPageState();
}

class _CreateMembershipPageState extends State<CreateMembershipPage> {
  String? _selectedMember;
  String? _selectedPlan;

  void _submit() {
    if (_selectedMember == null || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select member and plan')));
      return;
    }

    final now = DateTime.now();
    final plan = appPlans.firstWhere((p) => p.name == _selectedPlan);
    final end = now.add(Duration(days: plan.duration));

    String fmt(DateTime d) =>
        '${d.month}/${d.day}/${d.year}  ${d.hour > 12 ? d.hour - 12 : d.hour}:${d.minute.toString().padLeft(2, '0')}:00 ${d.hour >= 12 ? 'PM' : 'AM'}';

    Navigator.pop(
        context,
        Membership(
          memberName: _selectedMember!,
          planName: _selectedPlan!,
          startDate: fmt(now),
          endDate: fmt(end),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(children: [
        // Top bar
        Container(
          color: kBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Row(children: [
              Icon(Icons.bolt, color: kOrange, size: 20),
              Text('FitSync',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Memberships',
                  style: TextStyle(
                      color: kBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: kLight,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                child: const Center(
                  child: Text('Create Membership',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kBlack)),
                ),
              ),
              const Divider(height: 1, color: kBorder),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member dropdown
                      const Text('Member',
                          style: TextStyle(
                              fontSize: 13,
                              color: kBlack,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedMember,
                        hint: const Text('--Select Member--',
                            style: TextStyle(fontSize: 13, color: kGrey)),
                        items: appMembers
                            .map((m) => DropdownMenuItem(
                                  value: m.name,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                              color: kOrange,
                                              shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text(m.initials,
                                              style: const TextStyle(
                                                  color: kBlack,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(m.name,
                                            style: const TextStyle(fontSize: 13)),
                                      ]),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMember = v),
                        decoration: _dropDeco,
                      ),
                      const SizedBox(height: 16),

                      // Plan dropdown
                      const Text('Plan',
                          style: TextStyle(
                              fontSize: 13,
                              color: kBlack,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedPlan,
                        hint: const Text('--Select Plan--',
                            style: TextStyle(fontSize: 13, color: kGrey)),
                        items: appPlans
                            .map((p) => DropdownMenuItem(
                                  value: p.name,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.workspace_premium,
                                            color: kOrange, size: 16),
                                        const SizedBox(width: 8),
                                        Text(p.name,
                                            style: const TextStyle(fontSize: 13)),
                                        const SizedBox(width: 6),
                                        Text(
                                            '${p.price.toStringAsFixed(0)} EGP',
                                            style: const TextStyle(
                                                fontSize: 11, color: kGrey)),
                                      ]),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPlan = v),
                        decoration: _dropDeco,
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(children: [
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            foregroundColor: kBlack,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Create Membership',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGrey,
                            side: const BorderSide(color: kGrey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 12)),
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

final _dropDeco = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kOrange)),
);
