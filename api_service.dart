import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7165/api';

  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  // ── تخزين الـ Token بعد Login ──────────────────
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ════════════════════════════════════════════════
  // ACCOUNT
  // ════════════════════════════════════════════════

  // POST /api/Account/Login  (Admin)
  Future<String> login(String email, String password) async {
    final res = await _dio.post('/Account/Login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'];
    setToken(token);
    return token;
  }

  // POST /api/Account/LoginAsMember
  Future<String> loginAsMember(String email, String password) async {
    final res = await _dio.post('/Account/LoginAsMember', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'];
    setToken(token);
    return token;
  }

  // ════════════════════════════════════════════════
  // MEMBER
  // ════════════════════════════════════════════════

  // GET /api/Member/Index
  Future<List<dynamic>> getMembers() async {
    final res = await _dio.get('/Member/Index');
    return res.data;
  }

  // GET /api/Member/Details/{id}
  Future<Map<String, dynamic>> getMemberDetails(int id) async {
    final res = await _dio.get('/Member/Details/$id');
    return res.data;
  }

  // GET /api/Member/HealthRecord/{id}
  Future<Map<String, dynamic>> getMemberHealthRecord(int id) async {
    final res = await _dio.get('/Member/HealthRecord/$id');
    return res.data;
  }

  // POST /api/Member/Create
  Future<void> createMember(Map<String, dynamic> data) async {
    await _dio.post('/Member/Create', data: data);
  }

  // PUT /api/Member/Edit/{id}
  Future<void> editMember(int id, Map<String, dynamic> data) async {
    await _dio.put('/Member/Edit/$id', data: data);
  }

  // DELETE /api/Member/Delete/{id}
  Future<void> deleteMember(int id) async {
    await _dio.delete('/Member/Delete/$id');
  }

  // ════════════════════════════════════════════════
  // MEMBER PORTAL (للـ Member بعد Login)
  // ════════════════════════════════════════════════

  Future<Map<String, dynamic>> getMemberPortalHome() async {
    final res = await _dio.get('/MemberPortal/Home');
    return res.data;
  }

  Future<Map<String, dynamic>> getMemberPortalDetails() async {
    final res = await _dio.get('/MemberPortal/Details');
    return res.data;
  }

  Future<Map<String, dynamic>> getMemberPortalHealthRecord() async {
    final res = await _dio.get('/MemberPortal/HealthRecord');
    return res.data;
  }

  Future<Map<String, dynamic>> getMemberPortalPlan() async {
    final res = await _dio.get('/MemberPortal/Plan');
    return res.data;
  }

  Future<List<dynamic>> getMemberPortalSessions() async {
    final res = await _dio.get('/MemberPortal/Sessions');
    return res.data;
  }

  Future<void> editMemberPortal(Map<String, dynamic> data) async {
    await _dio.put('/MemberPortal/Edit', data: data);
  }

  // ════════════════════════════════════════════════
  // MEMBERSHIP
  // ════════════════════════════════════════════════

  // GET /api/Membership/Index
  Future<List<dynamic>> getMemberships() async {
    final res = await _dio.get('/Membership/Index');
    return res.data;
  }

  // GET /api/Membership/Dropdowns
  Future<Map<String, dynamic>> getMembershipDropdowns() async {
    final res = await _dio.get('/Membership/Dropdowns');
    return res.data;
  }

  // POST /api/Membership/Create
  Future<void> createMembership(Map<String, dynamic> data) async {
    await _dio.post('/Membership/Create', data: data);
  }

  // DELETE /api/Membership/Cancel/{id}
  Future<void> cancelMembership(int id) async {
    await _dio.delete('/Membership/Cancel/$id');
  }

  // ════════════════════════════════════════════════
  // PLAN
  // ════════════════════════════════════════════════

  // GET /api/Plan/Index
  Future<List<dynamic>> getPlans() async {
    final res = await _dio.get('/Plan/Index');
    return res.data;
  }

  // GET /api/Plan/Details/{id}
  Future<Map<String, dynamic>> getPlanDetails(int id) async {
    final res = await _dio.get('/Plan/Details/$id');
    return res.data;
  }

  // PUT /api/Plan/Edit/{id}
  Future<void> editPlan(int id, Map<String, dynamic> data) async {
    await _dio.put('/Plan/Edit/$id', data: data);
  }

  // PUT /api/Plan/Activate/{id}
  Future<void> activatePlan(int id) async {
    await _dio.put('/Plan/Activate/$id');
  }

  // ════════════════════════════════════════════════
  // SESSION
  // ════════════════════════════════════════════════

  // GET /api/Session/Index
  Future<List<dynamic>> getSessions() async {
    final res = await _dio.get('/Session/Index');
    return res.data;
  }

  // GET /api/Session/Details/{id}
  Future<Map<String, dynamic>> getSessionDetails(int id) async {
    final res = await _dio.get('/Session/Details/$id');
    return res.data;
  }

  // GET /api/Session/Dropdowns
  Future<Map<String, dynamic>> getSessionDropdowns() async {
    final res = await _dio.get('/Session/Dropdowns');
    return res.data;
  }

  // POST /api/Session/Create
  Future<void> createSession(Map<String, dynamic> data) async {
    await _dio.post('/Session/Create', data: data);
  }

  // PUT /api/Session/Edit/{id}
  Future<void> editSession(int id, Map<String, dynamic> data) async {
    await _dio.put('/Session/Edit/$id', data: data);
  }

  // DELETE /api/Session/Delete/{id}
  Future<void> deleteSession(int id) async {
    await _dio.delete('/Session/Delete/$id');
  }

  // ════════════════════════════════════════════════
  // TRAINER
  // ════════════════════════════════════════════════

  // GET /api/Trainer/Index
  Future<List<dynamic>> getTrainers() async {
    final res = await _dio.get('/Trainer/Index');
    return res.data;
  }

  // GET /api/Trainer/Details/{id}
  Future<Map<String, dynamic>> getTrainerDetails(int id) async {
    final res = await _dio.get('/Trainer/Details/$id');
    return res.data;
  }

  // POST /api/Trainer/Create
  Future<void> createTrainer(Map<String, dynamic> data) async {
    await _dio.post('/Trainer/Create', data: data);
  }

  // PUT /api/Trainer/Edit/{id}
  Future<void> editTrainer(int id, Map<String, dynamic> data) async {
    await _dio.put('/Trainer/Edit/$id', data: data);
  }

  // DELETE /api/Trainer/Delete/{id}
  Future<void> deleteTrainer(int id) async {
    await _dio.delete('/Trainer/Delete/$id');
  }

  // ════════════════════════════════════════════════
  // BOOKING
  // ════════════════════════════════════════════════

  // GET /api/Booking/Index
  Future<List<dynamic>> getBookings() async {
    final res = await _dio.get('/Booking/Index');
    return res.data;
  }

  // GET /api/Booking/GetMembersForUpcomingSession/{id}
  Future<List<dynamic>> getMembersForUpcomingSession(int id) async {
    final res = await _dio.get('/Booking/GetMembersForUpcomingSession/$id');
    return res.data;
  }

  // GET /api/Booking/GetMembersForOngoingSession/{id}
  Future<List<dynamic>> getMembersForOngoingSession(int id) async {
    final res = await _dio.get('/Booking/GetMembersForOngoingSession/$id');
    return res.data;
  }

  // POST /api/Booking/Create
  Future<void> createBooking(Map<String, dynamic> data) async {
    await _dio.post('/Booking/Create', data: data);
  }

  // POST /api/Booking/Attended
  Future<void> markAttended(Map<String, dynamic> data) async {
    await _dio.post('/Booking/Attended', data: data);
  }

  // POST /api/Booking/Cancel
  Future<void> cancelBooking(Map<String, dynamic> data) async {
    await _dio.post('/Booking/Cancel', data: data);
  }
}