import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';

// ── Plan Model ────────────────────────────────────────────────────────────────
class Plan {
  final int id;
  String name, description;
  double price;
  int duration;
  bool isActive;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.isActive = true,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    // Backend field is 'durationDays', fallback to 'duration' for safety
    final rawDur = json['durationDays'] ?? json['duration'] ?? 0;
    return Plan(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      price: ((json['price'] ?? json['Price'] ?? 0) as num).toDouble(),
      duration: (rawDur is int) ? rawDur : (int.tryParse(rawDur.toString()) ?? 0),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'durationDays': duration, // Backend field name
    'isActive': isActive,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// PLANS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class PlansPage extends StatefulWidget {
  final ApiService api;
  const PlansPage({super.key, required this.api});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  ApiService get _api => widget.api;
  List<Plan> _plans = [];
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
      final data = await _api.getPlans();
      if (!mounted) return;
      setState(() {
        _plans = data
            .map((j) => Plan.fromJson(j as Map<String, dynamic>))
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

  Future<void> _toggleActive(Plan plan) async {
    try {
      await _api.activatePlan(plan.id);
      if (!mounted) return;
      setState(() => plan.isActive = !plan.isActive);
    } catch (e) {
      if (mounted) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPlanPage(api: _api)),
          );
          if (added == true) _load();
        },
        backgroundColor: kOrange,
        child: const Icon(Icons.add, color: kBlack),
      ),
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
                      'Plans',
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

            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membership Plans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kOrange,
                    ),
                  ),
                  Text(
                    'Manage Gym Membership Packages',
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
    if (_plans.isEmpty) {
      return const Center(
        child: Text('No plans yet', style: TextStyle(color: kGrey)),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        for (int i = 0; i < _plans.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCard(_plans[i])),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < _plans.length
                      ? _buildCard(_plans[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCard(Plan plan) {
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: plan.isActive
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Text(
              plan.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),

          // Price + Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.price.toStringAsFixed(2),
                  style: const TextStyle(
                    color: kOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('EGP', style: TextStyle(color: kGrey, fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.loop, size: 11, color: kOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Duration : ${plan.duration}',
                      style: const TextStyle(fontSize: 10, color: kBlack),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 11,
                      color: kOrange,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 10, color: kBlack),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 2),
                  child: Text(
                    plan.description,
                    style: const TextStyle(fontSize: 10, color: kGrey),
                    maxLines: 3,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanDetailsPage(plan: plan),
                      ),
                    ),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 12,
                      color: kBlack,
                    ),
                    label: const Text(
                      'View Details',
                      style: TextStyle(color: kBlack, fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditPlanPage(plan: plan, api: _api),
                            ),
                          );
                          if (updated == true) _load();
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 11,
                          color: kBlack,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(color: kBlack, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleActive(plan),
                        icon: Icon(
                          plan.isActive
                              ? Icons.block
                              : Icons.check_circle_outline,
                          size: 11,
                          color: plan.isActive ? Colors.red : Colors.green,
                        ),
                        label: Text(
                          plan.isActive ? 'Deactivate' : 'Activate',
                          style: TextStyle(
                            color: plan.isActive ? Colors.red : Colors.green,
                            fontSize: 10,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: plan.isActive ? Colors.red : Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
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
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLAN DETAILS PAGE  (read-only — لا تحتاج api)
// ══════════════════════════════════════════════════════════════════════════════
class PlanDetailsPage extends StatelessWidget {
  final Plan plan;
  const PlanDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _pTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
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
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        color: kLight,
                        child: Center(
                          child: Text(
                            plan.price
                                .toStringAsFixed(0)
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},',
                                ),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: kOrange,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _detailRow(
                              Icons.description_outlined,
                              'Description',
                              plan.description,
                            ),
                            const SizedBox(height: 10),
                            _detailRow(
                              Icons.loop,
                              'Duration',
                              '${plan.duration} days',
                            ),
                            const SizedBox(height: 10),
                            _detailRow(
                              Icons.circle,
                              'Status',
                              plan.isActive ? 'Active' : 'Inactive',
                              valueColor: plan.isActive
                                  ? Colors.green
                                  : Colors.red,
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

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: kOrange),
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
                style: TextStyle(fontSize: 11, color: valueColor ?? kOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDIT PLAN PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditPlanPage extends StatefulWidget {
  final Plan plan;
  final ApiService api;
  const EditPlanPage({super.key, required this.plan, required this.api});

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  late TextEditingController _name, _duration, _price, _desc;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.plan.name);
    _duration = TextEditingController(text: widget.plan.duration.toString());
    _price = TextEditingController(text: widget.plan.price.toStringAsFixed(0));
    _desc = TextEditingController(text: widget.plan.description);
  }

  @override
  void dispose() {
    for (final c in [_name, _duration, _price, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    // Validate description length (5-200 characters)
    final description = _desc.text.trim();
    if (description.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be at least 5 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (description.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be less than 200 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate duration (1-365 days)
    final duration = int.tryParse(_duration.text) ?? 0;
    if (duration < 1 || duration > 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duration must be between 1 and 365 days'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate price (1-10000)
    final price = double.tryParse(_price.text) ?? 0;
    if (price < 1 || price > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Price must be between 1 and 10000 EGP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _saving = true);
    try {
      await widget.api.editPlan(widget.plan.id, {
        'PlanName': _name.text.trim(),
        'DurationDays': duration,
        'Price': price,
        'Description': description,
      });
      // تحديث الـ local object
      widget.plan.name = _name.text.trim();
      widget.plan.duration = duration;
      widget.plan.price = price;
      widget.plan.description = description;
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
            _pTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const Text(
                      'Update Plan details',
                      style: TextStyle(fontSize: 12, color: kGrey),
                    ),
                    const SizedBox(height: 24),
                    _formField('Plan Name', _name, required: true),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _formField(
                                'Duration (Days)',
                                _duration,
                                type: TextInputType.number,
                                required: true,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 4, left: 2),
                                child: Text(
                                  'e.g 30 days',
                                  style: TextStyle(fontSize: 10, color: kGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _formField(
                            'Price (EGP)',
                            _price,
                            type: TextInputType.number,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 12, color: kBlack),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _desc,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: _textAreaDeco,
                    ),
                    const SizedBox(height: 28),
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
                                  'Update Plan',
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

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13),
          decoration: _fieldDeco,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD PLAN PAGE
// ══════════════════════════════════════════════════════════════════════════════
class AddPlanPage extends StatefulWidget {
  final ApiService api;
  const AddPlanPage({super.key, required this.api});

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  late TextEditingController _name, _duration, _price, _desc;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _duration = TextEditingController();
    _price = TextEditingController();
    _desc = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_name, _duration, _price, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.isEmpty ||
        _duration.text.isEmpty ||
        _price.text.isEmpty ||
        _desc.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.createPlan({
        'name': _name.text.trim(),
        'durationDays': int.tryParse(_duration.text) ?? 30,
        'price': double.tryParse(_price.text) ?? 0,
        'description': _desc.text.trim(),
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
            _pTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                    const Text(
                      'Create a new membership package',
                      style: TextStyle(fontSize: 12, color: kGrey),
                    ),
                    const SizedBox(height: 24),
                    _formField('Plan Name', _name, required: true),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _formField(
                                'Duration (Days)',
                                _duration,
                                type: TextInputType.number,
                                required: true,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 4, left: 2),
                                child: Text(
                                  'e.g 30 days',
                                  style: TextStyle(fontSize: 10, color: kGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _formField(
                            'Price (EGP)',
                            _price,
                            type: TextInputType.number,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 12, color: kBlack),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _desc,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: _textAreaDeco,
                    ),
                    const SizedBox(height: 28),
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
                                  'Add Plan',
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

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13),
          decoration: _fieldDeco,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════════════════════
Widget _pTopBar(BuildContext context) {
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
            'Plans',
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
