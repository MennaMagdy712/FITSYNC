import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';

// ── Trainer Model ─────────────────────────────────────────────────────────────
class Trainer {
  final int id;
  String name, email, phone, dob, address, initials;
  List<String> specializations;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    this.dob = '',
    this.address = '',
    this.specializations = const [],
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    String fullName = (json['name'] ?? '').toString();
    final parts = fullName.trim().split(' ');
    final initials = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    List<String> specs = [];
    var specRaw = json['specialties'] ??
        json['Specialties'] ??
        json['specialization'] ??
        json['Specializations'];
    if (specRaw is String && specRaw.isNotEmpty) {
      specs = specRaw.split(',').map((e) => e.trim()).toList();
    } else if (specRaw is List) {
      specs = List<String>.from(specRaw.map((e) => e.toString()));
    }

    return Trainer(
      id: json['id'] ?? 0,
      name: fullName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      initials: initials,
      dob: (json['dob'] ?? json['dateOfBirth'] ?? '')
          .toString()
          .split('T')
          .first,
      address: (json['address'] ?? '').toString(),
      specializations: specs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phone,
    'dateOfBirth': dob.isEmpty ? null : dob,
    'address': address,
    'specialization': specializations.join(', '),
  };
}

const List<String> kAllSpecializations = [
  'Yoga',
  'Cardio',
  'Strength Training',
  'Pilates',
  'Cross Fit',
  'Zumba',
  'Martial Arts',
  'Dance Fitness',
];

// ══════════════════════════════════════════════════════════════════════════════
// TRAINERS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class TrainersPage extends StatefulWidget {
  final ApiService api;
  const TrainersPage({super.key, required this.api});

  @override
  State<TrainersPage> createState() => _TrainersPageState();
}

class _TrainersPageState extends State<TrainersPage> {
  ApiService get _api => widget.api;
  List<Trainer> _trainers = [];
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
      final data = await _api.getTrainers();
      if (!mounted) return;
      setState(() {
        _trainers = data
            .map((j) => Trainer.fromJson(j as Map<String, dynamic>))
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
      MaterialPageRoute(builder: (_) => AddTrainerPage(api: _api)),
    );
    if (result == true) _load();
  }

  void _openDetails(Trainer t) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerDetailsPage(trainer: t, api: _api),
      ),
    );
    if (result == 'deleted' || result == true) {
      _load();
    }
  }

  void _showMenu(Trainer t) {
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
              // Header
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
                        t.initials,
                        style: const TextStyle(
                          color: kBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      t.name,
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

              _menuItem(Icons.person_outline, 'View Details', Colors.white, () {
                Navigator.pop(context);
                _openDetails(t);
              }),
              _menuItem(
                Icons.edit_outlined,
                'Edit Details',
                Colors.white,
                () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTrainerPage(trainer: t, api: _api),
                    ),
                  );
                  if (result == true) _load();
                },
              ),
              _menuItem(Icons.delete_outline, 'Delete', Colors.red, () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeleteTrainerPage(trainer: t, api: _api),
                  ),
                );
                if (result == 'deleted') _load();
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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
                      'Add Trainer',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Trainers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kOrange,
                    ),
                  ),
                  const Text(
                    'Professional Fitness Instructors',
                    style: TextStyle(fontSize: 11, color: kGrey),
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
                  Expanded(flex: 3, child: Text('Name', style: _hStyle)),
                  Expanded(flex: 3, child: Text('Email', style: _hStyle)),
                  Expanded(flex: 3, child: Text('Phone', style: _hStyle)),
                  Expanded(
                    flex: 3,
                    child: Text('Specialization', style: _hStyle),
                  ),
                  SizedBox(width: 36, child: Text('Action', style: _hStyle)),
                ],
              ),
            ),
            const Divider(height: 1, color: kBorder),

            // List
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
    if (_trainers.isEmpty) {
      return const Center(
        child: Text('No trainers yet', style: TextStyle(color: kGrey)),
      );
    }
    return ListView.separated(
      itemCount: _trainers.length,
      separatorBuilder: (_, index) => const Divider(height: 1, color: kBorder),
      itemBuilder: (_, i) => _TrainerRow(
        trainer: _trainers[i],
        onTap: () => _openDetails(_trainers[i]),
        onMenu: () => _showMenu(_trainers[i]),
      ),
    );
  }
}

const _hStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Color(0xFF555555),
);

class _TrainerRow extends StatelessWidget {
  final Trainer trainer;
  final VoidCallback onTap, onMenu;
  const _TrainerRow({
    required this.trainer,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                trainer.name,
                style: const TextStyle(fontSize: 12, color: kBlack),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                trainer.email,
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
                trainer.phone,
                style: const TextStyle(fontSize: 11, color: kBlack),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                trainer.specializations.isEmpty
                    ? '-'
                    : trainer.specializations.join(', '),
                style: const TextStyle(fontSize: 11, color: kBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 36,
              child: IconButton(
                onPressed: onMenu,
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
// TRAINER DETAILS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class TrainerDetailsPage extends StatelessWidget {
  final Trainer trainer;
  final ApiService api;
  const TrainerDetailsPage({
    super.key,
    required this.trainer,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Orange header card
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kOrange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              trainer.initials,
                              style: const TextStyle(
                                color: kOrange,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trainer.name,
                            style: const TextStyle(
                              color: kBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (trainer.specializations.isNotEmpty)
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
                                trainer.specializations.join(', '),
                                style: const TextStyle(
                                  color: kBlack,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Info cards
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          _detailRow(
                            Icons.email_outlined,
                            'Email',
                            trainer.email,
                            Colors.orange,
                          ),
                          const Divider(height: 1, color: kBorder),
                          _detailRow(
                            Icons.phone_outlined,
                            'Phone',
                            trainer.phone,
                            Colors.green,
                          ),
                          const Divider(height: 1, color: kBorder),
                          _detailRow(
                            Icons.calendar_today_outlined,
                            'Date Of Birth',
                            trainer.dob.isEmpty ? '-' : trainer.dob,
                            Colors.blue,
                          ),
                          const Divider(height: 1, color: kBorder),
                          _detailRow(
                            Icons.location_on_outlined,
                            'Address',
                            trainer.address.isEmpty ? '-' : trainer.address,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit & Delete Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTrainerPage(
                                    trainer: trainer,
                                    api: api,
                                  ),
                                ),
                              );
                              if (!context.mounted) return;
                              if (result == true) Navigator.pop(context, true);
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
                                  builder: (_) => DeleteTrainerPage(
                                    trainer: trainer,
                                    api: api,
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

                    // Back button
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
                          elevation: 0,
                        ),
                        child: const Text(
                          'Back To List',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
                const SizedBox(height: 2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: kBlack),
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
// ADD TRAINER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class AddTrainerPage extends StatefulWidget {
  final ApiService api;
  const AddTrainerPage({super.key, required this.api});

  @override
  State<AddTrainerPage> createState() => _AddTrainerPageState();
}

class _AddTrainerPageState extends State<AddTrainerPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _building = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  String? _gender;
  final Set<String> _selected = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _dob, _building, _street, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter trainer name')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.createTrainer({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim(),
        'dateOfBirth': _dob.text.isEmpty ? null : _dob.text.trim(),
        'address':
            '${_building.text.trim()} ${_street.text.trim()} ${_city.text.trim()}'
                .trim(),
        'specialization': _selected.join(', '),
      });
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
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Trainer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal Info
                    _secTitle('Personal Information'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _field('Name', _name)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _field(
                            'Email',
                            _email,
                            type: TextInputType.emailAddress,
                          ),
                        ),
                      ],
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
                        const SizedBox(width: 14),
                        Expanded(child: _dateField('Date Of Birth', _dob)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 12, color: kBlack),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      hint: const Text(
                        'Select',
                        style: TextStyle(fontSize: 13, color: kGrey),
                      ),
                      items: ['Male', 'Female']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
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

                    // Address Info
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
                    const SizedBox(height: 20),

                    // Professional Info
                    _secTitle('Professional Information'),
                    const SizedBox(height: 10),
                    ...kAllSpecializations.map(
                      (s) => CheckboxListTile(
                        value: _selected.contains(s),
                        onChanged: (v) => setState(
                          () => v! ? _selected.add(s) : _selected.remove(s),
                        ),
                        title: Text(
                          s,
                          style: const TextStyle(fontSize: 13, color: kBlack),
                        ),
                        activeColor: kOrange,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
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
                          child: const Text('Cancel'),
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
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
// EDIT TRAINER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditTrainerPage extends StatefulWidget {
  final Trainer trainer;
  final ApiService api;
  const EditTrainerPage({super.key, required this.trainer, required this.api});
  @override
  State<EditTrainerPage> createState() => _EditTrainerPageState();
}

class _EditTrainerPageState extends State<EditTrainerPage> {
  late TextEditingController _name, _email, _phone, _dob, _building;
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.trainer.name);
    _email = TextEditingController(text: widget.trainer.email);
    _phone = TextEditingController(text: widget.trainer.phone);
    _dob = TextEditingController(text: widget.trainer.dob);
    _building = TextEditingController(text: widget.trainer.address);
    _selected = Set.from(widget.trainer.specializations);
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _dob, _building]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Parse address: "123 Main Street Cairo" -> buildingNumber=123, street="Main Street", city="Cairo"
      final addressParts = _building.text.trim().split(' ');
      int buildingNumber = 1;
      String street = 'Street';
      String city = 'City';
      
      if (addressParts.isNotEmpty && int.tryParse(addressParts[0]) != null) {
        buildingNumber = int.parse(addressParts[0]);
        if (addressParts.length > 1) {
          street = addressParts.sublist(1, addressParts.length > 2 ? addressParts.length - 1 : addressParts.length).join(' ');
        }
        if (addressParts.length > 2) {
          city = addressParts.last;
        }
      } else if (addressParts.length >= 3) {
        // If no number at start, try to parse as "Street City"
        street = addressParts.sublist(0, addressParts.length - 1).join(' ');
        city = addressParts.last;
      }
      
      await widget.api.editTrainer(widget.trainer.id, {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'buildingNumber': buildingNumber,
        'street': street,
        'city': city,
        'specialization': _selected.isNotEmpty ? _selected.first : 'Yoga',
      });
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
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Trainer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const Text(
                      'Update trainer information',
                      style: TextStyle(fontSize: 12, color: kGrey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Editing info for:',
                      style: TextStyle(fontSize: 11, color: kGrey),
                    ),
                    Text(
                      widget.trainer.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kBlack,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _secTitle('Personal Information'),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _field('Name', _name)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _field(
                                  'Email',
                                  _email,
                                  type: TextInputType.emailAddress,
                                ),
                              ),
                            ],
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
                              const SizedBox(width: 14),
                              Expanded(
                                child: _dateField('Date Of Birth', _dob),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _field('Address', _building),
                          const SizedBox(height: 20),

                          _secTitle('Professional Information'),
                          const SizedBox(height: 8),
                          ...kAllSpecializations.map(
                            (s) => CheckboxListTile(
                              value: _selected.contains(s),
                              onChanged: (v) => setState(
                                () =>
                                    v! ? _selected.add(s) : _selected.remove(s),
                              ),
                              title: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kBlack,
                                ),
                              ),
                              activeColor: kOrange,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
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
                                child: const Text('Cancel'),
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
                                        'Update Trainer',
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
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE TRAINER PAGE
// ══════════════════════════════════════════════════════════════════════════════
class DeleteTrainerPage extends StatefulWidget {
  final Trainer trainer;
  final ApiService api;
  const DeleteTrainerPage({
    super.key,
    required this.trainer,
    required this.api,
  });

  @override
  State<DeleteTrainerPage> createState() => _DeleteTrainerPageState();
}

class _DeleteTrainerPageState extends State<DeleteTrainerPage> {
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await widget.api.deleteTrainer(widget.trainer.id);
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
            _topBar(context),
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
                          widget.trainer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Are you sure you want to delete this Trainer?',
                          style: TextStyle(fontSize: 13, color: kOrange),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Warning! This action cannot be undone. All data will be permanently deleted.',
                            style: TextStyle(fontSize: 12, color: Colors.white),
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
                                  'NO',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _deleting ? null : _delete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  foregroundColor: kBlack,
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

// ── Shared helpers ────────────────────────────────────────────────────────────
Widget _topBar(BuildContext context) {
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
            'Trainer',
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
                String month = d.month.toString().padLeft(2, '0');
                String day = d.day.toString().padLeft(2, '0');
                ctrl.text = '${d.year}-$month-$day';
              }
            },
          ),
        ],
      );
    },
  );
}
