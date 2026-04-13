import 'package:flutter/material.dart';
import 'constants.dart';

// ── Member Model ──────────────────────────────────────────────────────────────
class Member {
  String name, email, phone, initials, gender, dob, address;
  String height, weight, bloodType, note;

  Member({
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    this.gender = '',
    this.dob = '',
    this.address = '',
    this.height = '',
    this.weight = '',
    this.bloodType = '',
    this.note = '',
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBERS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MembersPage extends StatefulWidget {
  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final List<Member> _members = [
    Member(name: 'Mohammed Ahmed', email: 'mohammed@gmail.com', phone: '01095121008', initials: 'MA', gender: 'Male', dob: '06/07/1999', address: '5 Alexsani street - Simbellawi', height: '175 CM', weight: '70 KG', bloodType: 'A+', note: 'No Note Found'),
    Member(name: 'Manar Samir',    email: 'Manar@gmail.com',    phone: '01085121008', initials: 'MS'),
    Member(name: 'Menna Gamal',    email: 'Menna@gmail.com',    phone: '01095121008', initials: 'MG'),
  ];

  void _openAdd() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (_) => AddMemberPage()));
    if (result is Member) setState(() => _members.add(result));
  }

  void _openMemberData(Member m) async {
    final updated = await Navigator.push(
      context, MaterialPageRoute(builder: (_) => MemberDataPage(member: m)));
    if (updated == 'deleted') {
      setState(() => _members.remove(m));
    } else if (updated is Member) {
      setState(() {});
    }
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
            ElevatedButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add, size: 14, color: kBlack),
              label: const Text('Add member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ]),
        ),
        // Table header
        Container(
          color: kLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(children: [
            SizedBox(width: 44, child: Text('Photo',  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
            SizedBox(width: 8),
            Expanded(flex: 3, child: Text('Name',   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
            Expanded(flex: 3, child: Text('Email',  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
            Expanded(flex: 3, child: Text('Phone',  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
            SizedBox(width: 36, child: Text('Action', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
          ]),
        ),
        const Divider(height: 1, color: kBorder),
        Expanded(child: _members.isEmpty
          ? const Center(child: Text('No members yet', style: TextStyle(color: kGrey)))
          : ListView.separated(
              itemCount: _members.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: kBorder),
              itemBuilder: (_, i) => _MemberRow(
                member: _members[i],
                onTap: () => _openMemberData(_members[i]),
              ),
            )),
      ])),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  _MemberRow({required this.member, required this.onTap});

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(member.initials,
                      style: const TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Text(member.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Divider(color: Color(0xFF2E2E3E), height: 1),
            _menuItem(context, Icons.person_outline, 'View Member Data', Colors.white, () {
              Navigator.pop(context); onTap();
            }),
            _menuItem(context, Icons.favorite_border, 'View Health Record', Colors.white, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => HealthDataPage(member: member)));
            }),
            _menuItem(context, Icons.edit_outlined, 'Edit Member Data', Colors.white, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditMemberPage(member: member)));
            }),
            _menuItem(context, Icons.delete_outline, 'Delete Member', Colors.red, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => DeleteMemberPage(member: member)));
            }),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(member.initials, style: const TextStyle(color: kBlack, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(member.name, style: const TextStyle(fontSize: 12, color: kBlack))),
          Expanded(flex: 3, child: Text(member.email, style: const TextStyle(fontSize: 11, color: kOrange, decoration: TextDecoration.underline))),
          Expanded(flex: 3, child: Text(member.phone, style: const TextStyle(fontSize: 11, color: kBlack))),
          SizedBox(width: 36, child: IconButton(
            onPressed: () => _showMenu(context),
            icon: const Icon(Icons.more_horiz, color: kGrey, size: 20),
            padding: EdgeInsets.zero,
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBER DATA PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MemberDataPage extends StatelessWidget {
  final Member member;
  MemberDataPage({required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(child: Column(children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Members', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Avatar
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(member.initials,
                    style: const TextStyle(color: kBlack, fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kOrange)),
              Text('No Diet Plan', style: const TextStyle(fontSize: 12, color: kGrey)),
              const SizedBox(height: 16),

              // Info rows
              _infoRow('Email', member.email),
              _infoRow('Phone', member.phone),
              Row(children: [
                Expanded(child: _infoBox('Gender', member.gender.isEmpty ? '-' : member.gender)),
                const SizedBox(width: 10),
                Expanded(child: _infoBox('Date of Birth', member.dob.isEmpty ? '-' : member.dob)),
              ]),
              const SizedBox(height: 8),
              _infoRow('Address', member.address.isEmpty ? '-' : member.address),
              const SizedBox(height: 16),

              // Action buttons
              Row(children: [
                Expanded(child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EditMemberPage(member: member)));
                    if (result is Member) Navigator.pop(context, result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange, foregroundColor: kBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DeleteMemberPage(member: member)));
                    if (result == 'deleted') Navigator.pop(context, 'deleted');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
              ]),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => HealthDataPage(member: member))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kOrange,
                  side: const BorderSide(color: kOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Health Data', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGrey,
                  side: const BorderSide(color: kBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Back To List'),
              )),
            ]),
          ),
        ),
        const SizedBox(height: 20),
      ]))),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: kLight, borderRadius: BorderRadius.circular(6)),
          child: Text(value, style: const TextStyle(fontSize: 13, color: kBlack)),
        ),
      ]),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
      const SizedBox(height: 3),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: kLight, borderRadius: BorderRadius.circular(6)),
        child: Text(value, style: const TextStyle(fontSize: 13, color: kBlack)),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HEALTH DATA PAGE
// ══════════════════════════════════════════════════════════════════════════════
class HealthDataPage extends StatelessWidget {
  final Member member;
  HealthDataPage({required this.member});

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Members', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Health Record Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: const Center(
                child: Text('Health Record',
                    style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Grid of health metrics
                Row(children: [
                  Expanded(child: _healthCard(Icons.monitor_weight, 'Weight',
                      member.weight.isEmpty ? 'No Data' : member.weight, Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _healthCard(Icons.height, 'Height',
                      member.height.isEmpty ? 'No Data' : member.height, Colors.blue)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _healthCard(Icons.bloodtype, 'Blood Type',
                      member.bloodType.isEmpty ? 'No Data' : member.bloodType, Colors.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _healthCard(Icons.note, 'Note',
                      member.note.isEmpty ? 'No Note Found' : member.note, Colors.green)),
                ]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGrey, side: const BorderSide(color: kBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Back To List'),
                )),
              ]),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _healthCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: kGrey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
        ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDIT MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditMemberPage extends StatefulWidget {
  final Member member;
  EditMemberPage({required this.member});
  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  late TextEditingController _email, _phone, _building, _city;

  @override
  void initState() {
    super.initState();
    _email    = TextEditingController(text: widget.member.email);
    _phone    = TextEditingController(text: widget.member.phone);
    _building = TextEditingController(text: widget.member.address);
    _city     = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_email, _phone, _building, _city]) c.dispose();
    super.dispose();
  }

  void _save() {
    widget.member.email   = _email.text.trim();
    widget.member.phone   = _phone.text.trim();
    widget.member.address = _building.text.trim();
    Navigator.pop(context, widget.member);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Members', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Avatar
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(widget.member.initials,
                  style: const TextStyle(color: kBlack, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Text(widget.member.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kOrange)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _field('Email', _email, type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Phone', _phone, type: TextInputType.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Building Number', _building)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Street', TextEditingController())),
                  const SizedBox(width: 12),
                  Expanded(child: _field('City', _city)),
                ]),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGrey, side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Back To List'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kOrange, foregroundColor: kBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kGrey)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, keyboardType: type,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
        ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class DeleteMemberPage extends StatelessWidget {
  final Member member;
  DeleteMemberPage({required this.member});

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Members', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Member name
              Text(member.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kBlack),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Are you sure you want to delete this member?',
                  style: const TextStyle(fontSize: 13, color: kGrey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // Warning box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Text(
                  'Warning: This action cannot be undone. All member data will be permanently deleted.',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGrey, side: const BorderSide(color: kBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('No', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'deleted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
              ]),
            ]),
          ),
        ))),
      ])),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class AddMemberPage extends StatefulWidget {
  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _phone    = TextEditingController();
  final _dob      = TextEditingController();
  final _building = TextEditingController();
  final _street   = TextEditingController();
  final _city     = TextEditingController();
  final _height   = TextEditingController();
  final _weight   = TextEditingController();
  final _blood    = TextEditingController();
  final _note     = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [_name, _email, _phone, _dob, _building, _street, _city, _height, _weight, _blood, _note]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter member name')));
      return;
    }
    final parts = _name.text.trim().split(' ');
    final initials = parts.take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
    Navigator.pop(context, Member(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      initials: initials,
      gender: _gender ?? '',
      dob: _dob.text.trim(),
      address: '${_building.text.trim()} ${_street.text.trim()}'.trim(),
      height: _height.text.trim(),
      weight: _weight.text.trim(),
      bloodType: _blood.text.trim(),
      note: _note.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Members', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Add Member', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlack)),
            const SizedBox(height: 16),
            Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
              child: TabBar(
                controller: _tab,
                labelColor: kOrange, unselectedLabelColor: kGrey,
                indicatorColor: kOrange, indicatorWeight: 2,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [Tab(text: 'Member Info'), Tab(text: 'Health Data')],
              ),
            ),
            const SizedBox(height: 20),
            if (_tab.index == 0) _memberInfoTab(),
            if (_tab.index == 1) _healthTab(),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBlack, side: const BorderSide(color: kBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Back To List', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange, foregroundColor: kBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('+ Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        )),
      ])),
    );
  }

  Widget _memberInfoTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secTitle('Personal Information'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _field('Name', _name)),
        const SizedBox(width: 14),
        Expanded(child: _field('Email', _email, type: TextInputType.emailAddress)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field('Phone', _phone, type: TextInputType.phone)),
        const SizedBox(width: 14),
        Expanded(child: _dateField('Date Of Birth', _dob)),
      ]),
      const SizedBox(height: 12),
      const Text('Gender', style: TextStyle(fontSize: 12, color: kBlack)),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        value: _gender,
        hint: const Text('Select', style: TextStyle(fontSize: 13, color: kGrey)),
        items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _gender = v),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
        ),
      ),
      const SizedBox(height: 20),
      _secTitle('Address Information'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _field('Building Number', _building)),
        const SizedBox(width: 14),
        Expanded(child: _field('Street', _street)),
      ]),
      const SizedBox(height: 12),
      _field('City', _city),
    ]);
  }

  Widget _healthTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secTitle('Health Data'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _field('Height', _height)),
        const SizedBox(width: 14),
        Expanded(child: _field('Weight', _weight)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field('Blood Type', _blood)),
        const SizedBox(width: 14),
        Expanded(child: _field('Note', _note)),
      ]),
    ]);
  }

  Widget _secTitle(String text) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kOrange)),
      const SizedBox(height: 6),
      const Divider(color: kBorder, height: 1),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, keyboardType: type,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kOrange)),
        ),
      ),
    ]);
  }

  Widget _dateField(String label, TextEditingController ctrl) {
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
            initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now(),
            builder: (c, child) => Theme(
              data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: kOrange)),
              child: child!,
            ),
          );
          if (d != null) ctrl.text = '${d.day}/${d.month}/${d.year}';
        },
      ),
    ]);
  }
}
