import 'package:flutter/material.dart';
import 'api_service.dart';
import 'member.dart';
import 'constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MEMBERS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MembersPage extends StatefulWidget {
  final ApiService api;
  const MembersPage({super.key, required this.api});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  ApiService get _api => widget.api;
  List<Member> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _api.getMembers();
      if (!mounted) return;
      setState(() {
        _members = data
            .map((j) => Member.fromJson(j as Map<String, dynamic>))
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMemberPage(api: _api)),
    );
    if (result == true) _loadMembers();
  }

  void _openMemberData(Member m) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberDataPage(member: m, api: _api),
      ),
    );
    if (updated == 'deleted' || updated is Member) _loadMembers();
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
                  ElevatedButton.icon(
                    onPressed: _openAdd,
                    icon: const Icon(Icons.add, size: 14, color: kBlack),
                    label: const Text(
                      'Add member',
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
            // Table header
            Container(
              color: kLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      'Photo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kBorder),

            // Body
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
              onPressed: _loadMembers,
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
    if (_members.isEmpty) {
      return const Center(
        child: Text('No members yet', style: TextStyle(color: kGrey)),
      );
    }
    return ListView.separated(
      itemCount: _members.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: kBorder),
      itemBuilder: (_, i) => _MemberRow(
        member: _members[i],
        onTap: () => _openMemberData(_members[i]),
        api: _api,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBER ROW
// ══════════════════════════════════════════════════════════════════════════════
class _MemberRow extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final ApiService api;
  const _MemberRow({
    required this.member, 
    required this.onTap,
    required this.api,
  });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: kOrange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          color: kBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      member.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2E2E3E), height: 1),
              _menuItem(
                context,
                Icons.person_outline,
                'View Member Data',
                Colors.white,
                () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              _menuItem(
                context,
                Icons.favorite_border,
                'View Health Record',
                Colors.white,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HealthDataPage(member: member, api: api),
                    ),
                  );
                },
              ),
              _menuItem(
                context,
                Icons.edit_outlined,
                'Edit Member Data',
                Colors.white,
                () {
                  Navigator.pop(context);
                  // Edit is handled inside MemberDataPage
                  onTap();
                },
              ),
              _menuItem(
                context,
                Icons.delete_outline,
                'Delete Member',
                Colors.red,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DeleteMemberPage(
                            member: member, 
                            api: api,
                            onDeleted: () {},
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: kBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                member.name,
                style: const TextStyle(fontSize: 12, color: kBlack),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                member.email,
                style: const TextStyle(
                  fontSize: 11,
                  color: kOrange,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                member.phone,
                style: const TextStyle(fontSize: 11, color: kBlack),
              ),
            ),
            SizedBox(
              width: 36,
              child: IconButton(
                onPressed: () => _showMenu(context),
                icon: const Icon(Icons.more_horiz, color: kGrey, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEMBER DATA PAGE
// ══════════════════════════════════════════════════════════════════════════════
class MemberDataPage extends StatelessWidget {
  final Member member;
  final ApiService api;
  const MemberDataPage({super.key, required this.member, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topBar('Members'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: kOrange,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            color: kBlack,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kOrange,
                        ),
                      ),
                      const Text(
                        'No Diet Plan',
                        style: TextStyle(fontSize: 12, color: kGrey),
                      ),
                      const SizedBox(height: 16),
                      _infoRow('Email', member.email),
                      _infoRow('Phone', member.phone),
                      Row(
                        children: [
                          Expanded(
                            child: _infoBox(
                              'Gender',
                              member.gender.isEmpty ? '-' : member.gender,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoBox(
                              'Date of Birth',
                              member.dob.isEmpty ? '-' : member.dob,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoRow(
                        'Address',
                        member.address.isEmpty ? '-' : member.address,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditMemberPage(
                                      member: member,
                                      api: api,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (result == true) {
                                  Navigator.pop(context, true);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kOrange,
                                foregroundColor: kBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeleteMemberPage(
                                      member: member,
                                      api: api,
                                      onDeleted: () =>
                                          Navigator.pop(context, 'deleted'),
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (result == 'deleted') {
                                  Navigator.pop(context, 'deleted');
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HealthDataPage(member: member, api: api),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kOrange,
                            side: const BorderSide(color: kOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Health Data',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGrey,
                            side: const BorderSide(color: kBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Back To List'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: kLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: kBlack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: kLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: kBlack),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HEALTH DATA PAGE  (تجلب البيانات من API)
// ══════════════════════════════════════════════════════════════════════════════
class HealthDataPage extends StatefulWidget {
  final Member member;
  final ApiService api;
  const HealthDataPage({super.key, required this.member, required this.api});

  @override
  State<HealthDataPage> createState() => _HealthDataPageState();
}

class _HealthDataPageState extends State<HealthDataPage> {
  bool _loading = true;
  String? _error;
  String _weight = '';
  String _height = '';
  String _bloodType = '';
  String _note = '';

  @override
  void initState() {
    super.initState();
    _loadHealthRecord();
  }

  Future<void> _loadHealthRecord() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await widget.api.getMemberHealthRecord(widget.member.id);
      if (!mounted) return;
      setState(() {
        // Backend HealthViewModel: Height, Weight, BloodType, Note
        _height = (data['height'] ?? data['Height'] ?? '').toString();
        _weight = (data['weight'] ?? data['Weight'] ?? '').toString();
        _bloodType = (data['bloodType'] ?? data['BloodType'] ?? '').toString();
        _note = (data['note'] ?? data['Note'] ?? '').toString();
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
            _topBar('Members'),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: kOrange),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadHealthRecord,
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: kOrange,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Health Record',
                                  style: TextStyle(
                                    color: kBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.member.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
                                        _weight.isEmpty ? 'No Data' : '$_weight kg',
                                        Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _healthCard(
                                        Icons.height,
                                        'Height',
                                        _height.isEmpty ? 'No Data' : '$_height cm',
                                        Colors.blue,
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
                                        _bloodType.isEmpty
                                            ? 'No Data'
                                            : _bloodType,
                                        Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _healthCard(
                                        Icons.note,
                                        'Note',
                                        _note.isEmpty ? 'No Note' : _note,
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: kGrey,
                                      side: const BorderSide(color: kBorder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Back To List'),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _healthCard(IconData icon, String label, String value, Color color) {
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
                Text(label, style: const TextStyle(fontSize: 10, color: kGrey)),
                Text(
                  value,
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
}



// ══════════════════════════════════════════════════════════════════════════════
// EDIT MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditMemberPage extends StatefulWidget {
  final Member member;
  final ApiService api;
  const EditMemberPage({super.key, required this.member, required this.api});

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  late TextEditingController _email, _phone, _building, _street, _city;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.member.email);
    _phone = TextEditingController(text: widget.member.phone);
    // Try to parse building number from stored address
    _building = TextEditingController();
    _street = TextEditingController();
    _city = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_email, _phone, _building, _street, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // MemberToUpdateViewModel expects: Name, Email, Phone, BuildingNumber (int), Street, City
      // Note: Name is not editable in this page, so we use the existing member name
      await widget.api.editMember(widget.member.id, {
        'name': widget.member.name,
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'buildingNumber': int.tryParse(_building.text.trim()) ?? 1,
        'street': _street.text.trim(),
        'city': _city.text.trim(),
      });
      widget.member.email = _email.text.trim();
      widget.member.phone = _phone.text.trim();
      widget.member.address =
          '${_building.text.trim()} ${_street.text.trim()} ${_city.text.trim()}'
              .trim();
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
            _topBar('Members'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: kOrange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.member.initials,
                        style: const TextStyle(
                          color: kBlack,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _field(
                            'Email',
                            _email,
                            type: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  'Phone',
                                  _phone,
                                  type: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field(
                                  'Building No.',
                                  _building,
                                  type: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _field('Street', _street)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('City', _city)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kGrey,
                                  side: const BorderSide(color: kBorder),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Back To List'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  foregroundColor: kBlack,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                        'Save',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kGrey)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class DeleteMemberPage extends StatefulWidget {
  final Member member;
  final ApiService? api;
  final VoidCallback? onDeleted;
  const DeleteMemberPage({
    super.key,
    required this.member,
    this.api,
    this.onDeleted,
  });

  @override
  State<DeleteMemberPage> createState() => _DeleteMemberPageState();
}

class _DeleteMemberPageState extends State<DeleteMemberPage> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    if (widget.api == null) {
      Navigator.pop(context, 'deleted');
      return;
    }
    setState(() => _deleting = true);
    try {
      await widget.api!.deleteMember(widget.member.id);
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
            _topBar('Members'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.member.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Are you sure you want to delete this member?',
                          style: TextStyle(fontSize: 13, color: kGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _deleting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kGrey,
                                  side: const BorderSide(color: kBorder),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'No',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _deleting ? null : _confirmDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: _deleting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
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
// ADD MEMBER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class AddMemberPage extends StatefulWidget {
  final ApiService api;
  const AddMemberPage({super.key, required this.api});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _building = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _blood = TextEditingController();
  final _note = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  String? _gender;
  bool _saving = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [
      _name,
      _email,
      _phone,
      _dob,
      _building,
      _street,
      _city,
      _height,
      _weight,
      _blood,
      _note,
      _pass,
      _confirmPass,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    // ── Validation ──────────────────────────────────────────────
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter member name')),
      );
      return;
    }
    if (_email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email')),
      );
      return;
    }
    if (_phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }
    if (_dob.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }
    if (_building.text.trim().isEmpty || _street.text.trim().isEmpty || _city.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill building number, street and city')),
      );
      return;
    }
    if (_height.text.trim().isEmpty || _weight.text.trim().isEmpty || _blood.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill height, weight and blood type')),
      );
      return;
    }
    if (_pass.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (_pass.text != _confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.api.createMember(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        gender: _gender!,
        dateOfBirth: _dob.text.trim(), // format: yyyy-MM-dd
        buildingNumber: int.tryParse(_building.text.trim()) ?? 1,
        street: _street.text.trim(),
        city: _city.text.trim(),
        height: double.tryParse(_height.text.trim()) ?? 0,
        weight: double.tryParse(_weight.text.trim()) ?? 0,
        bloodType: _blood.text.trim(),
        note: _note.text.trim(),
        password: _pass.text.trim(),
        confirmPassword: _confirmPass.text.trim(),
      );
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
            _topBar('Members'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Member',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: kBorder)),
                      ),
                      child: TabBar(
                        controller: _tab,
                        labelColor: kOrange,
                        unselectedLabelColor: kGrey,
                        indicatorColor: kOrange,
                        indicatorWeight: 2,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: const [
                          Tab(text: 'Member Info'),
                          Tab(text: 'Health Data'),
                          Tab(text: 'Account'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_tab.index == 0) _memberInfoTab(),
                    if (_tab.index == 1) _healthTab(),
                    if (_tab.index == 2) _accountTab(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kBlack,
                            side: const BorderSide(color: kBorder),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Back To List',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            foregroundColor: kBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                                  '+ Add',
                                  style: TextStyle(
                                    fontSize: 13,
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
          ],
        ),
      ),
    );
  }

  Widget _memberInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _secTitle('Personal Information'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Name', _name)),
            const SizedBox(width: 14),
            Expanded(
              child: _field('Email', _email, type: TextInputType.emailAddress),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _field('Phone', _phone, type: TextInputType.phone)),
            const SizedBox(width: 14),
            Expanded(child: _dateField('Date Of Birth', _dob)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Gender', style: TextStyle(fontSize: 12, color: kBlack)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          hint: const Text(
            'Select',
            style: TextStyle(fontSize: 13, color: kGrey),
          ),
          items: [
            'Male',
            'Female',
            'Other',
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _gender = v),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _secTitle('Address Information'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Building Number', _building)),
            const SizedBox(width: 14),
            Expanded(child: _field('Street', _street)),
          ],
        ),
        const SizedBox(height: 12),
        _field('City', _city),
      ],
    );
  }

  Widget _healthTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _secTitle('Health Data'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Height', _height)),
            const SizedBox(width: 14),
            Expanded(child: _field('Weight', _weight)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _field('Blood Type', _blood)),
            const SizedBox(width: 14),
            Expanded(child: _field('Note', _note)),
          ],
        ),
      ],
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

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          readOnly: true,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 16,
              color: kGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange),
            ),
          ),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (c, child) => Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(primary: kOrange),
                ),
                child: child!,
              ),
            );
            if (d != null) {
              // Format as yyyy-MM-dd for backend DateOnly
              final y = d.year.toString().padLeft(4, '0');
              final m = d.month.toString().padLeft(2, '0');
              final day = d.day.toString().padLeft(2, '0');
              ctrl.text = '$y-$m-$day';
            }
          },
        ),
      ],
    );
  }

  Widget _accountTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _secTitle('Account Credentials'),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password',
              style: TextStyle(fontSize: 12, color: kBlack),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _pass,
              obscureText: _obscurePass,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: kGrey,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kOrange),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Password',
              style: TextStyle(fontSize: 12, color: kBlack),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _confirmPass,
              obscureText: _obscureConfirm,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: kGrey,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: kOrange),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kOrange.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'The member will use this password to log in to the Member Portal.',
            style: TextStyle(fontSize: 11, color: kGrey),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED TOP BAR HELPER
// ══════════════════════════════════════════════════════════════════════════════
Widget _topBar(String badge) {
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
          child: Text(
            badge,
            style: const TextStyle(
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
