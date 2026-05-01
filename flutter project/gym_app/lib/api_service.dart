import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kIsWeb, debugPrint
// Conditional import: picks stub on web, native impl on mobile/desktop
import 'http_ssl_stub.dart'
    if (dart.library.io) 'http_ssl_native.dart';

class ApiService {
  // ─────────────────────────────────────────────────────────────────────────
  // 🔧 إعداد الـ Base URL
  //
  // • 192.168.1.11 → الـ IP الحقيقي للجهاز على الشبكة (للموبايل الحقيقي)
  // • localhost    → للـ Web أو Windows
  // ─────────────────────────────────────────────────────────────────────────
  static const String _physicalDevUrl = 'http://192.168.1.11:7165/api';
  static const String _localUrl = 'http://localhost:7165/api';

  static String get baseUrl {
    // On web always use localhost; on all native platforms use physical device IP
    if (kIsWeb) return _localUrl;
    return getBaseUrlForPlatform(_physicalDevUrl, _localUrl);
  }

  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      ) {
    // Platform-safe SSL bypass (stub on web, native on mobile/desktop)
    configureSsl(_dio);

    // إضافة Interceptor لتتبع الـ API calls والـ responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('╔════════════════════════════════════════════════════════════════');
          debugPrint('║ 📤 API REQUEST');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Method: ${options.method}');
          debugPrint('║ URL: ${options.baseUrl}${options.path}');
          debugPrint('║ Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('║ Body: ${options.data}');
          }
          debugPrint('╚════════════════════════════════════════════════════════════════');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('╔════════════════════════════════════════════════════════════════');
          debugPrint('║ 📥 API RESPONSE');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Status Code: ${response.statusCode}');
          debugPrint('║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
          debugPrint('║ Response Data: ${response.data}');
          debugPrint('╚════════════════════════════════════════════════════════════════');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('╔════════════════════════════════════════════════════════════════');
          debugPrint('║ ❌ API ERROR');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          debugPrint('║ Status Code: ${error.response?.statusCode}');
          debugPrint('║ Error Message: ${error.message}');
          if (error.response?.data != null) {
            debugPrint('║ Error Data: ${error.response?.data}');
          }
          debugPrint('╚════════════════════════════════════════════════════════════════');
          return handler.next(error);
        },
      ),
    );
  }

  // ── تخزين الـ Token بعد Login ──────────────────
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ── حذف الـ Token عند Logout ──────────────────
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ════════════════════════════════════════════════
  // ACCOUNT
  // ════════════════════════════════════════════════

  // POST /api/Account/Login  (Admin)
  Future<String> login(String email, String password) async {
    final res = await _dio.post(
      '/Account/Login',
      data: {'Email': email, 'Password': password, 'RememberMe': false},
    );
    // Backend returns PascalCase keys (System.Text.Json default)
    final token = res.data['token'] ?? res.data['Token'];
    setToken(token);
    return token;
  }

  // POST /api/Account/LoginAsMember
  Future<String> loginAsMember(String email, String password) async {
    final res = await _dio.post(
      '/Account/LoginAsMember',
      data: {'Email': email, 'Password': password},
    );
    // Backend returns PascalCase keys (System.Text.Json default)
    final token = res.data['token'] ?? res.data['Token'];
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

  // POST /api/Member/Create  ← multipart/form-data (backend uses IFormFile)
  Future<void> createMember({
    required String name,
    required String email,
    required String phone,
    required String gender, // "Male" | "Female" | "Other"
    required String dateOfBirth, // "yyyy-MM-dd"
    required int buildingNumber,
    required String street,
    required String city,
    required double height,
    required double weight,
    required String bloodType,
    String note = '',
    required String password,
    required String confirmPassword,
  }) async {
    // Backend expects multipart because of IFormFile PhotoFile.
    // We send a dummy 1×1 PNG so validation passes.
    final dummyPng = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
      0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
      0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
      0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ];

    // gender enum: Male=1, Female=2
    final genderMap = {
      'Male': 1,
      'Female': 2,
      'Other': 3,
    };
    final genderValue = genderMap[gender] ?? 1;

    final formData = FormData.fromMap({
      'PhotoFile': MultipartFile.fromBytes(
        dummyPng,
        filename: 'photo.png',
        contentType: DioMediaType('image', 'png'),
      ),
      'Name': name,
      'Phone': phone,
      'Email': email,
      'DateOfBirth': dateOfBirth,
      'Gender': genderValue,
      'BuildingNumber': buildingNumber,
      'Street': street,
      'City': city,
      'HealthViewModel.Height': height,
      'HealthViewModel.Weight': weight,
      'HealthViewModel.BloodType': bloodType,
      'HealthViewModel.Note': note,
      'Password': password,
      'ConfirmPassword': confirmPassword,
    });

    final token = _dio.options.headers['Authorization'];
    await _dio.post(
      '/Member/Create',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Authorization': token},
      ),
    );
  }

  // PUT /api/Member/Edit/{id}
  Future<void> editMember(int id, Map<String, dynamic> data) async {
    // Backend expects: Name, Phone, Email, BuildingNumber, Street, City
    // MemberToUpdateViewModel validation:
    // - Phone: required, Egyptian format (010/011/012/015 + 8 digits)
    // - Email: required, valid email, 5-100 chars
    // - BuildingNumber: required, 1-9000
    // - Street: required, 2-100 chars
    // - City: required, 2-50 chars, letters only
    
    final name = (data['name'] ?? data['Name'] ?? '').toString().trim();
    final phone = (data['phone'] ?? data['Phone'] ?? '').toString().trim();
    final email = (data['email'] ?? data['Email'] ?? '').toString().trim();
    final street = (data['street'] ?? data['Street'] ?? '').toString().trim();
    final city = (data['city'] ?? data['City'] ?? '').toString().trim();
    final buildingNumber = data['buildingNumber'] ?? data['BuildingNumber'] ?? 0;
    
    // Validate required fields
    if (name.isEmpty) throw Exception('Name is required');
    if (phone.isEmpty) throw Exception('Phone is required');
    if (email.isEmpty) throw Exception('Email is required');
    if (street.isEmpty) throw Exception('Street is required');
    if (city.isEmpty) throw Exception('City is required');
    
    // Validate Egyptian phone format
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      throw Exception('Phone must be a valid Egyptian mobile number (010/011/012/015 + 8 digits)');
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Invalid email format');
    }
    
    // Validate building number range (1-9000)
    if (buildingNumber < 1 || buildingNumber > 9000) {
      throw Exception('Building number must be between 1 and 9000');
    }
    
    // Validate string lengths
    if (email.length < 5 || email.length > 100) {
      throw Exception('Email must be between 5 and 100 characters');
    }
    if (street.length < 2 || street.length > 100) {
      throw Exception('Street must be between 2 and 100 characters');
    }
    if (city.length < 2 || city.length > 50) {
      throw Exception('City must be between 2 and 50 characters');
    }
    
    // Validate city contains only letters and spaces
    final cityRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!cityRegex.hasMatch(city)) {
      throw Exception('City can only contain letters and spaces');
    }
    
    // Backend expects specific format
    final payload = {
      'Name': name,
      'Phone': phone,
      'Email': email,
      'BuildingNumber': buildingNumber,
      'Street': street,
      'City': city,
    };
    
    debugPrint('📤 Sending editMember payload: $payload');
    
    try {
      await _dio.put('/Member/Edit/$id', data: payload);
      debugPrint('✅ Member updated successfully');
    } catch (e) {
      debugPrint('❌ editMember error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // DELETE /api/Member/Delete/{id}
  Future<void> deleteMember(int id) async {
    if (id <= 0) {
      throw Exception('Invalid member ID');
    }
    
    debugPrint('📤 Deleting member with ID: $id');
    
    try {
      final response = await _dio.delete('/Member/Delete/$id');
      debugPrint('✅ Member deleted successfully: ${response.data}');
    } catch (e) {
      debugPrint('❌ deleteMember error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
        
        // Extract error message from backend
        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          String errorMsg = errorData['message'] ?? 'Unknown error';
          if (errorData['details'] != null) {
            errorMsg += '\n${errorData['details']}';
          }
          throw Exception(errorMsg);
        }
      }
      rethrow;
    }
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
  // Backend returns PascalCase: { Members: [...], Plans: [...] }
  Future<Map<String, dynamic>> getMembershipDropdowns() async {
    final res = await _dio.get('/Membership/Dropdowns');
    final raw = res.data as Map<String, dynamic>;
    return {
      'members': raw['Members'] ?? raw['members'] ?? [],
      'plans': raw['Plans'] ?? raw['plans'] ?? [],
    };
  }

  // POST /api/Membership/Create
  Future<void> createMembership(Map<String, dynamic> data) async {
    // Backend CreateMembershipViewModel expects PascalCase: MemberId, PlanId
    await _dio.post('/Membership/Create', data: {
      'MemberId': data['memberId'] ?? data['MemberId'],
      'PlanId': data['planId'] ?? data['PlanId'],
    });
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

  // POST /api/Plan/Create
  Future<void> createPlan(Map<String, dynamic> data) async {
    await _dio.post('/Plan/Create', data: data);
  }

  // GET /api/Plan/Details/{id}
  Future<Map<String, dynamic>> getPlanDetails(int id) async {
    final res = await _dio.get('/Plan/Details/$id');
    return res.data;
  }

  // PUT /api/Plan/Edit/{id}
  Future<void> editPlan(int id, Map<String, dynamic> data) async {
    // Backend expects: PlanName, Description, DurationDays, Price
    // UpdatePlanViewModel validation:
    // - Description: required, 5-200 chars
    // - DurationDays: required, 1-365
    // - Price: required, 1-10000
    
    final planName = (data['name'] ?? data['planName'] ?? data['PlanName'] ?? '').toString().trim();
    final description = (data['description'] ?? data['Description'] ?? '').toString().trim();
    final durationDays = data['durationDays'] ?? data['DurationDays'] ?? 0;
    
    // Parse price - handle both int and double
    num priceNum = 0;
    if (data['price'] != null) {
      priceNum = data['price'] is num ? data['price'] : num.tryParse(data['price'].toString()) ?? 0;
    } else if (data['Price'] != null) {
      priceNum = data['Price'] is num ? data['Price'] : num.tryParse(data['Price'].toString()) ?? 0;
    }
    final price = priceNum.toDouble();
    
    // Validate required fields
    if (planName.isEmpty) throw Exception('Plan name is required');
    if (description.isEmpty) throw Exception('Description is required');
    
    // Validate description length (5-200 characters)
    if (description.length < 5 || description.length > 200) {
      throw Exception('Description must be between 5 and 200 characters');
    }
    
    // Validate duration (1-365 days)
    if (durationDays < 1 || durationDays > 365) {
      throw Exception('Duration must be between 1 and 365 days');
    }
    
    // Validate price (1-10000)
    if (price < 1 || price > 10000) {
      throw Exception('Price must be between 1 and 10000');
    }
    
    final payload = {
      'PlanName': planName,
      'Description': description,
      'DurationDays': durationDays,
      'Price': price,
    };
    
    debugPrint('📤 Sending editPlan payload: $payload');
    
    try {
      await _dio.put('/Plan/Edit/$id', data: payload);
      debugPrint('✅ Plan updated successfully');
    } catch (e) {
      debugPrint('❌ editPlan error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
        
        // Extract error message from backend
        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          String errorMsg = errorData['message'] ?? 'Unknown error';
          if (errorData['details'] != null) {
            errorMsg += '\n${errorData['details']}';
          }
          throw Exception(errorMsg);
        }
      }
      rethrow;
    }
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
    final raw = res.data as Map<String, dynamic>;
    
    // Parse trainers
    final trainersRaw = raw['Trainers'] ?? raw['trainers'] ?? [];
    final trainers = (trainersRaw as List).map((t) {
      if (t is Map) {
        return {
          'id': t['id'] ?? t['Id'] ?? 0,
          'name': t['name'] ?? t['Name'] ?? '',
        };
      }
      return t;
    }).toList();
    
    // Parse categories - Backend returns objects with id and name
    final categoriesRaw = raw['Categories'] ?? raw['categories'] ?? [];
    final categories = (categoriesRaw as List).map((c) {
      if (c is Map) {
        return {
          'id': c['id'] ?? c['Id'] ?? 0,
          'name': c['name'] ?? c['Name'] ?? '',
        };
      }
      return c;
    }).toList();
    
    return {
      'trainers': trainers,
      'categories': categories,
    };
  }

  // POST /api/Session/Create
  Future<void> createSession(Map<String, dynamic> data) async {
    // Backend expects CategoryId (int) and TrainerId (int)
    // Also expects DateTime format for StartDate and EndDate
    
    final payload = {
      'Description': data['description'] ?? data['Description'] ?? '',
      'Capacity': data['capacity'] ?? data['Capacity'] ?? 20,
      'StartDate': (data['startTime'] ?? data['startDate'] ?? data['StartDate'] ?? DateTime.now().toIso8601String()).toString().replaceAll('Z', ''),
      'EndDate': (data['endTime'] ?? data['endDate'] ?? data['EndDate'] ?? DateTime.now().add(const Duration(hours: 1)).toIso8601String()).toString().replaceAll('Z', ''),
      'TrainerId': data['trainerId'] ?? data['TrainerId'] ?? 1,
      'CategoryId': data['categoryId'] ?? data['CategoryId'] ?? 1,
    };

    debugPrint('📤 Sending createSession payload: $payload');
    
    try {
      await _dio.post('/Session/Create', data: payload);
    } catch (e) {
      debugPrint('❌ createSession error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // PUT /api/Session/Edit/{id}
  Future<void> editSession(int id, Map<String, dynamic> data) async {
    // Backend expects: Description, StartDate, EndDate, TrainerId
    // UpdateSessionViewModel validation:
    // - Description: 10-500 characters (required)
    // - StartDate: DateTime (required)
    // - EndDate: DateTime (required)
    // - TrainerId: int (required)
    
    final description = (data['description'] ?? data['Description'] ?? '').toString().trim();
    final trainerId = data['trainerId'] ?? data['TrainerId'];
    final startDate = data['startDate'] ?? data['StartDate'] ?? data['startTime'];
    final endDate = data['endDate'] ?? data['EndDate'] ?? data['endTime'];
    
    // Validate required fields
    if (description.isEmpty) {
      throw Exception('Description is required');
    }
    if (description.length < 10 || description.length > 500) {
      throw Exception('Description must be between 10 and 500 characters');
    }
    if (trainerId == null) {
      throw Exception('Trainer is required');
    }
    if (startDate == null) {
      throw Exception('Start date is required');
    }
    if (endDate == null) {
      throw Exception('End date is required');
    }
    
    // Format dates to ISO8601 without 'Z' (to ensure local time handling)
    String formattedStartDate = startDate.toString();
    String formattedEndDate = endDate.toString();
    
    if (startDate is String && !startDate.contains('T')) {
      try {
        final parsedDate = DateTime.parse(startDate);
        formattedStartDate = parsedDate.toIso8601String();
      } catch (e) {
        debugPrint('⚠️ Warning: Could not parse start date, using as-is');
      }
    }
    
    if (endDate is String && !endDate.contains('T')) {
      try {
        final parsedDate = DateTime.parse(endDate);
        formattedEndDate = parsedDate.toIso8601String();
      } catch (e) {
        debugPrint('⚠️ Warning: Could not parse end date, using as-is');
      }
    }

    if (formattedStartDate.endsWith('Z')) {
      formattedStartDate = formattedStartDate.substring(0, formattedStartDate.length - 1);
    }
    if (formattedEndDate.endsWith('Z')) {
      formattedEndDate = formattedEndDate.substring(0, formattedEndDate.length - 1);
    }
    
    final payload = {
      'Description': description,
      'StartDate': formattedStartDate,
      'EndDate': formattedEndDate,
      'TrainerId': trainerId,
    };
    
    debugPrint('📤 Sending editSession payload: $payload');
    
    try {
      await _dio.put('/Session/Edit/$id', data: payload);
      debugPrint('✅ Session updated successfully');
    } catch (e) {
      debugPrint('❌ editSession error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // DELETE /api/Session/Delete/{id}
  Future<void> deleteSession(int id) async {
    if (id <= 0) {
      throw Exception('Invalid session ID');
    }
    
    debugPrint('📤 Deleting session with ID: $id');
    
    try {
      final response = await _dio.delete('/Session/Delete/$id');
      debugPrint('✅ Session deleted successfully: ${response.data}');
    } catch (e) {
      debugPrint('❌ deleteSession error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
        
        // Extract error message from backend
        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          String errorMsg = errorData['message'] ?? 'Unknown error';
          if (errorData['details'] != null) {
            errorMsg += '\n${errorData['details']}';
          }
          throw Exception(errorMsg);
        }
      }
      rethrow;
    }
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
    // Map specialization string to enum value
    final specMap = {
      'Yoga': 1,
      'Cardio': 2,
      'Strength Training': 3,
      'StrengthTraining': 3,
      'Pilates': 4,
      'Cross Fit': 5,
      'CrossFit': 5,
      'Zumba': 6,
      'Martial Arts': 7,
      'MartialArts': 7,
      'Dance Fitness': 8,
      'DanceFitness': 8,
    };

    // Map gender string to enum value (1=Male, 2=Female)
    final genderMap = {'Male': 1, 'Female': 2};
    
    String? specStr = data['specialization'] ?? data['Specialization'];
    int specialtyValue = 1; // Default to Yoga
    if (specStr != null && specStr.isNotEmpty) {
      final firstSpec = specStr.split(',').first.trim();
      specialtyValue = specMap[firstSpec] ?? 1;
    }

    // Parse address if it's a single string
    String address = data['address'] ?? '';
    List<String> addressParts = address.split(' ');
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
    }

    final payload = {
      'Name': data['name'] ?? data['Name'] ?? '',
      'Email': data['email'] ?? data['Email'] ?? '',
      'Phone': data['phoneNumber'] ?? data['Phone'] ?? '',
      'DateOfBirth': data['dateOfBirth'] ?? data['DateOfBirth'] ?? '2000-01-01',
      'Gender': data['gender'] ?? genderMap[data['Gender']] ?? 1,
      'BuildingNumber': data['buildingNumber'] ?? data['BuildingNumber'] ?? buildingNumber,
      'Street': data['street'] ?? data['Street'] ?? street,
      'City': data['city'] ?? data['City'] ?? city,
      'Specialties': data['specialties'] ?? data['Specialties'] ?? specialtyValue,
    };

    await _dio.post('/Trainer/Create', data: payload);
  }

  // PUT /api/Trainer/Edit/{id}
  Future<void> editTrainer(int id, Map<String, dynamic> data) async {
    // Backend expects: Name, Email, Phone, BuildingNumber, Street, City, Specialties
    // TrainerToUpdateViewModel validation:
    // - Name: required
    // - Email: required, valid email format
    // - Phone: required, Egyptian format (010/011/012/015 + 8 digits)
    // - BuildingNumber: required, > 0
    // - City: required, 2-100 chars, letters only
    // - Street: required, 2-150 chars, alphanumeric
    // - Specialties: required, enum 1-8
    
    final name = (data['name'] ?? data['Name'] ?? '').toString().trim();
    final email = (data['email'] ?? data['Email'] ?? '').toString().trim();
    final phone = (data['phone'] ?? data['Phone'] ?? '').toString().trim();
    final buildingNumber = data['buildingNumber'] ?? data['BuildingNumber'] ?? 0;
    final street = (data['street'] ?? data['Street'] ?? '').toString().trim();
    final city = (data['city'] ?? data['City'] ?? '').toString().trim();
    final specialization = data['specialization'] ?? data['Specialization'];
    
    // Validate required fields
    if (name.isEmpty) throw Exception('Name is required');
    if (email.isEmpty) throw Exception('Email is required');
    if (phone.isEmpty) throw Exception('Phone is required');
    if (street.isEmpty) throw Exception('Street is required');
    if (city.isEmpty) throw Exception('City is required');
    
    // Validate email format
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Invalid email format');
    }
    
    // Validate Egyptian phone format
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      throw Exception('Phone must be a valid Egyptian mobile number (010/011/012/015 + 8 digits)');
    }
    
    // Validate building number
    if (buildingNumber <= 0) {
      throw Exception('Building number must be greater than 0');
    }
    
    // Validate city
    if (city.length < 2 || city.length > 100) {
      throw Exception('City must be between 2 and 100 characters');
    }
    final cityRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!cityRegex.hasMatch(city)) {
      throw Exception('City can only contain letters and spaces');
    }
    
    // Validate street
    if (street.length < 2 || street.length > 150) {
      throw Exception('Street must be between 2 and 150 characters');
    }
    final streetRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!streetRegex.hasMatch(street)) {
      throw Exception('Street can only contain letters, numbers, and spaces');
    }
    
    // Map specialization to enum
    final specMap = {
      'Yoga': 1,
      'Cardio': 2,
      'Strength Training': 3,
      'StrengthTraining': 3,
      'Pilates': 4,
      'Cross Fit': 5,
      'CrossFit': 5,
      'Zumba': 6,
      'Martial Arts': 7,
      'MartialArts': 7,
      'Dance Fitness': 8,
      'DanceFitness': 8,
    };
    
    int specialtyValue = 1;
    if (specialization != null) {
      if (specialization is String) {
        final specStr = specialization.toString().split(',').first.trim();
        specialtyValue = specMap[specStr] ?? 1;
      } else if (specialization is int) {
        specialtyValue = specialization;
      }
    } else if (data['specialties'] != null) {
      specialtyValue = data['specialties'] as int;
    }
    
    final payload = {
      'Name': name,
      'Email': email,
      'Phone': phone,
      'BuildingNumber': buildingNumber,
      'Street': street,
      'City': city,
      'Specialties': specialtyValue,
    };
    
    debugPrint('📤 Sending editTrainer payload: $payload');
    
    try {
      await _dio.put('/Trainer/Edit/$id', data: payload);
      debugPrint('✅ Trainer updated successfully');
    } catch (e) {
      debugPrint('❌ editTrainer error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // DELETE /api/Trainer/Delete/{id}
  Future<void> deleteTrainer(int id) async {
    if (id <= 0) {
      throw Exception('Invalid trainer ID');
    }
    
    debugPrint('📤 Deleting trainer with ID: $id');
    
    try {
      final response = await _dio.delete('/Trainer/Delete/$id');
      debugPrint('✅ Trainer deleted successfully: ${response.data}');
    } catch (e) {
      debugPrint('❌ deleteTrainer error: $e');
      if (e is DioException && e.response != null) {
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
        
        // Extract error message from backend
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          throw Exception(e.response?.data['message']);
        }
      }
      rethrow;
    }
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
    try {
      await _dio.post('/Booking/Create', data: {
        'SessionId': data['sessionId'] ?? data['SessionId'],
        'MemberId': data['memberId'] ?? data['MemberId'],
      });
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? 'Failed to Create Booking');
      }
      rethrow;
    }
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
