import 'package:flutter/material.dart';
import 'constants.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'login_as_member_page.dart';
import 'members.dart';
import 'trainers.dart';
import 'sessions.dart';
import 'plans.dart';
import 'memberships.dart';
import 'sessions_schedule.dart';

void main() => runApp(const FitSyncApp());

class FitSyncApp extends StatelessWidget {
  const FitSyncApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const LoginPage(),
      routes: {
        '/home': (ctx) {
          final api = ModalRoute.of(ctx)!.settings.arguments as ApiService;
          return MainScreen(api: api);
        },
        '/member-login': (ctx) => const LoginAsMemberPage(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class MainScreen extends StatefulWidget {
  final ApiService api;
  const MainScreen({super.key, required this.api});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _logout() {
    widget.api.clearToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(api: widget.api),
      MembersPage(api: widget.api),
      TrainersPage(api: widget.api),
      SessionsPage(api: widget.api),
      PlansPage(api: widget.api),
      MembershipsPage(api: widget.api),
      SessionsSchedulePage(api: widget.api),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitSync',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: kBlack,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red, size: 20),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: kBlack,
        selectedItemColor: kOrange,
        unselectedItemColor: kGrey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 8,
        unselectedFontSize: 8,
        iconSize: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Trainers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Plans',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.loyalty), label: 'Member'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Sched.',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOME PAGE
// ══════════════════════════════════════════════════════════════════════════════
class HomePage extends StatelessWidget {
  final ApiService api;
  const HomePage({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildStats(),
            _buildAbout(),
            _buildWorkouts(),
            _buildWhyUs(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      color: kBlack,
      padding: const EdgeInsets.fromLTRB(20, 52, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top action bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginAsMemberPage(),
                  ),
                ),
                icon: const Icon(Icons.person, size: 14, color: kOrange),
                label: const Text(
                  'Member Portal',
                  style: TextStyle(fontSize: 11, color: kOrange),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kOrange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  api.clearToken();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 14, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 11, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FITNESS APP',
                        style: TextStyle(
                          color: kBlack,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Your body can '),
                          TextSpan(
                            text: 'Stand',
                            style: TextStyle(color: kOrange),
                          ),
                          TextSpan(text: '\nalmost anything!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Push your limits. Achieve your\nfitness goals with certified trainers.',
                      style: TextStyle(color: kGrey, fontSize: 11, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginAsMemberPage(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            foregroundColor: kBlack,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text('🏋️‍♀️', style: TextStyle(fontSize: 64)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      color: kOrange,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _statItem('88', 'Free Members'),
          _statItem('44', 'Active Members'),
          _statItem('26', 'Completed Sessions'),
        ],
      ),
    );
  }

  Widget _statItem(String number, String label) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0x26000000))),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kBlack,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Us',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: kGrey),
              children: [
                TextSpan(text: 'Empowering you to achieve '),
                TextSpan(
                  text: 'YOUR FITNESS GOALS',
                  style: TextStyle(color: kOrange, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: [
              _aboutCard(
                'Personal Trainer',
                'Achieve your goals with certified trainers.',
              ),
              _aboutCard(
                'Personal Trainer',
                'Achieve your goals with certified trainers.',
              ),
              _aboutCard(
                'Personal Trainer',
                'Achieve your goals with certified trainers.',
              ),
              _aboutCard(
                'Personal Trainer',
                'Achieve your goals with certified trainers.',
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              foregroundColor: kBlack,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Join Now',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutCard(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kLight,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: kOrange, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: const TextStyle(fontSize: 10, color: kGrey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkouts() {
    return Container(
      color: kBlack,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(18, 20, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workouts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: kGrey),
              children: [
                TextSpan(text: 'Transform Your Body With Our '),
                TextSpan(
                  text: 'Dynamic Upcoming Workouts!',
                  style: TextStyle(color: kOrange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _workoutCard('🏃', 'Group Workout', 'Cardio'),
                _workoutCard('🧘', 'Cross Workout', 'Flexibility'),
                _workoutCard('💪', 'Crossfit', 'Strength'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workoutCard(String emoji, String name, String type) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(type, style: const TextStyle(color: kOrange, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWhyUs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Us',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: kGrey),
              children: [
                TextSpan(text: 'Elevate fitness with '),
                TextSpan(
                  text: 'the best way possible',
                  style: TextStyle(color: kOrange, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _whyItem(
            '1',
            'Personalized Fitness Plans',
            'Get a workout tailored to your unique goals.',
          ),
          const SizedBox(height: 10),
          _whyItem(
            '2',
            'Personalized Fitness Plans',
            'Get a workout tailored to your unique goals.',
          ),
          const SizedBox(height: 10),
          _whyItem(
            '3',
            'Personalized Fitness Plans',
            'Get a workout tailored to your unique goals.',
          ),
        ],
      ),
    );
  }

  Widget _whyItem(String number, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: kOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: kBlack,
                fontSize: 13,
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
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kGrey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: kBlack,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FitSync',
            style: TextStyle(
              color: kOrange,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CONTACT US',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '📞 (+20)1234567890',
                      style: TextStyle(color: kGrey, fontSize: 10),
                    ),
                    Text(
                      '📷 @fitsync',
                      style: TextStyle(color: kGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'GYM TIMING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mon–Fri: 6AM – 6PM',
                      style: TextStyle(color: kGrey, fontSize: 10),
                    ),
                    Text(
                      'Sat–Sun: 8AM – 4PM',
                      style: TextStyle(color: kGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'OUR LOCATION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '📍 270 Fifth Ave, New York',
            style: TextStyle(color: kGrey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
