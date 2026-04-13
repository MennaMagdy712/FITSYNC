import 'package:flutter/material.dart';
import 'constants.dart';

// ── Plan Model ────────────────────────────────────────────────────────────────
class Plan {
  String name, description;
  double price;
  int duration;
  bool isActive;

  Plan({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.isActive = true,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// PLANS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class PlansPage extends StatefulWidget {
  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final List<Plan> _plans = [
    Plan(name: 'Basic Plan',    price: 700,  duration: 30,  description: 'Access to gym equipment during staffed hours'),
    Plan(name: 'Standard Plan', price: 1200, duration: 60,  description: 'Includes gym equipment and 2 group classes per week'),
    Plan(name: 'Premium Plan',  price: 900,  duration: 90,  description: 'Unlimited access to equipment, classes, and sauna'),
    Plan(name: 'Annual Plan',   price: 3000, duration: 365, description: 'Full year access with personal trainer sessions'),
  ];

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
              child: const Text('Plans', style: TextStyle(color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Membership Plans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Manage Gym Membership Packages',
                style: TextStyle(fontSize: 11, color: kGrey)),
          ]),
        ),

        // FIX: استبدلنا GridView بـ ListView عشان نتفادى overflow
        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          children: [
            // Row 1
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _buildCard(context, _plans[0])),
              const SizedBox(width: 10),
              Expanded(child: _buildCard(context, _plans[1])),
            ]),
            const SizedBox(height: 10),
            // Row 2
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _buildCard(context, _plans[2])),
              const SizedBox(width: 10),
              Expanded(child: _buildCard(context, _plans[3])),
            ]),
          ],
        )),
      ])),
    );
  }

  Widget _buildCard(BuildContext context, Plan plan) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: plan.isActive ? Colors.grey.shade600 : Colors.grey.shade400,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11), topRight: Radius.circular(11)),
          ),
          child: Text(plan.name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        ),

        // Price + Info
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(color: kOrange, fontSize: 18, fontWeight: FontWeight.w800)),
            const Text('EGP', style: TextStyle(color: kGrey, fontSize: 10)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.loop, size: 11, color: kOrange),
              const SizedBox(width: 4),
              Text('Duration : ${plan.duration}', style: const TextStyle(fontSize: 10, color: kBlack)),
            ]),
            const SizedBox(height: 3),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.description_outlined, size: 11, color: kOrange),
              const SizedBox(width: 4),
              const Text('Description', style: TextStyle(fontSize: 10, color: kBlack)),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 2),
              child: Text(plan.description,
                  style: const TextStyle(fontSize: 10, color: kGrey),
                  maxLines: 3,
                  softWrap: true),
            ),
          ]),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          child: Column(children: [
            // View Details
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PlanDetailsPage(plan: plan))),
              icon: const Icon(Icons.visibility_outlined, size: 12, color: kBlack),
              label: const Text('View Details', style: TextStyle(color: kBlack, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            )),
            const SizedBox(height: 4),
            // Edit + Deactivate
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                // FIX: Navigator.push مباشرة هنا
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => EditPlanPage(plan: plan)));
                  setState(() {}); // refresh بعد الرجوع
                },
                icon: const Icon(Icons.edit_outlined, size: 11, color: kBlack),
                label: const Text('Edit', style: TextStyle(color: kBlack, fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              )),
              const SizedBox(width: 4),
              Expanded(child: OutlinedButton.icon(
                // FIX: setState مباشرة هنا
                onPressed: () => setState(() => plan.isActive = !plan.isActive),
                icon: Icon(
                  plan.isActive ? Icons.block : Icons.check_circle_outline,
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
                  side: BorderSide(color: plan.isActive ? Colors.red : Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLAN DETAILS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class PlanDetailsPage extends StatelessWidget {
  final Plan plan;
  PlanDetailsPage({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        _pTopBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                decoration: const BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Column(children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                  const SizedBox(height: 6),
                  Text(plan.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
              ),

              // Price
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: kLight,
                child: Center(
                  child: Text(
                    plan.price.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kOrange),
                  ),
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _detailRow(Icons.description_outlined, 'Description', plan.description),
                  const SizedBox(height: 10),
                  _detailRow(Icons.loop, 'Duration', '${plan.duration} days'),
                  const SizedBox(height: 10),
                  _detailRow(Icons.circle, 'Status',
                      plan.isActive ? 'Active' : 'Inactive',
                      valueColor: plan.isActive ? Colors.green : Colors.red),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton(
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
                ]),
              ),
            ]),
          ),
        )),
      ])),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: kOrange),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 11, color: valueColor ?? kOrange)),
      ])),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDIT PLAN PAGE
// ══════════════════════════════════════════════════════════════════════════════
class EditPlanPage extends StatefulWidget {
  final Plan plan;
  EditPlanPage({required this.plan});
  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  late TextEditingController _name, _duration, _price, _desc;

  @override
  void initState() {
    super.initState();
    _name     = TextEditingController(text: widget.plan.name);
    _duration = TextEditingController(text: widget.plan.duration.toString());
    _price    = TextEditingController(text: widget.plan.price.toStringAsFixed(0));
    _desc     = TextEditingController(text: widget.plan.description);
  }

  @override
  void dispose() {
    for (final c in [_name, _duration, _price, _desc]) c.dispose();
    super.dispose();
  }

  void _save() {
    widget.plan.name        = _name.text.trim();
    widget.plan.duration    = int.tryParse(_duration.text) ?? widget.plan.duration;
    widget.plan.price       = double.tryParse(_price.text) ?? widget.plan.price;
    widget.plan.description = _desc.text.trim();
    Navigator.pop(context, widget.plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [
        _pTopBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Edit Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOrange)),
            const Text('Update Plan details',
                style: TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 24),

            // Plan Name
            _formField('Plan Name', _name, required: true),
            const SizedBox(height: 14),

            // Duration + Price
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _formField('Duration (Days)', _duration,
                    type: TextInputType.number, required: true),
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 2),
                  child: Text('e.g 30 days', style: TextStyle(fontSize: 10, color: kGrey)),
                ),
              ])),
              const SizedBox(width: 14),
              Expanded(child: _formField('Price (EGP)', _price,
                  type: TextInputType.number, required: true)),
            ]),
            const SizedBox(height: 14),

            // Description
            const Text('Description',
                style: TextStyle(fontSize: 12, color: kBlack)),
            const SizedBox(height: 5),
            TextField(
              controller: _desc,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe the session content and objectives',
                hintStyle: const TextStyle(fontSize: 12, color: kGrey),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: kOrange)),
              ),
            ),
            const SizedBox(height: 28),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBlack,
                  side: const BorderSide(color: kBorder),
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
                child: const Text('Update Plan',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        )),
      ])),
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, bool required = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kBlack)),
        if (required)
          const Text(' *', style: TextStyle(fontSize: 12, color: Colors.red)),
      ]),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, keyboardType: type,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange)),
        ),
      ),
    ]);
  }
}

// ── Shared top bar ────────────────────────────────────────────────────────────
Widget _pTopBar(BuildContext context) {
  return Container(
    color: kBlack,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      const Row(children: [
        Icon(Icons.bolt, color: kOrange, size: 20),
        Text('FitSync',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: kOrange, borderRadius: BorderRadius.circular(20)),
        child: const Text('Plans',
            style: TextStyle(
                color: kBlack, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}
