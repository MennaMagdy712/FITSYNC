import 'lib/api_service.dart';

void main() async {
  final api = ApiService();
  
  print('🧪 Testing API Service...\n');
  
  // Test 1: Login
  print('📝 Test 1: Login');
  try {
    final token = await api.login('admin@admin.com', 'Admin@123');
    print('✅ Login successful: ${token.substring(0, 20)}...\n');
  } catch (e) {
    print('❌ Login failed: $e\n');
  }
  
  // Test 2: Get Members
  print('📝 Test 2: Get Members');
  try {
    final members = await api.getMembers();
    print('✅ Got ${members.length} members\n');
  } catch (e) {
    print('❌ Get members failed: $e\n');
  }
  
  // Test 3: Get Trainers
  print('📝 Test 3: Get Trainers');
  try {
    final trainers = await api.getTrainers();
    print('✅ Got ${trainers.length} trainers\n');
  } catch (e) {
    print('❌ Get trainers failed: $e\n');
  }
  
  // Test 4: Get Plans
  print('📝 Test 4: Get Plans');
  try {
    final plans = await api.getPlans();
    print('✅ Got ${plans.length} plans\n');
  } catch (e) {
    print('❌ Get plans failed: $e\n');
  }
  
  // Test 5: Get Sessions
  print('📝 Test 5: Get Sessions');
  try {
    final sessions = await api.getSessions();
    print('✅ Got ${sessions.length} sessions\n');
  } catch (e) {
    print('❌ Get sessions failed: $e\n');
  }
  
  // Test 6: Edit Member (if exists)
  print('📝 Test 6: Edit Member');
  try {
    await api.editMember(1, {
      'name': 'Test Member Updated',
      'phone': '01012345678',
      'email': 'test@example.com',
      'buildingNumber': 123,
      'street': 'Test Street',
      'city': 'Cairo',
    });
    print('✅ Member edited successfully\n');
  } catch (e) {
    print('❌ Edit member failed: $e\n');
  }
  
  // Test 7: Edit Trainer (if exists)
  print('📝 Test 7: Edit Trainer');
  try {
    await api.editTrainer(1, {
      'name': 'Test Trainer Updated',
      'email': 'trainer@example.com',
      'phone': '01098765432',
      'buildingNumber': 456,
      'street': 'Trainer Street',
      'city': 'Alexandria',
      'specialization': 'Yoga',
    });
    print('✅ Trainer edited successfully\n');
  } catch (e) {
    print('❌ Edit trainer failed: $e\n');
  }
  
  // Test 8: Edit Plan (if exists)
  print('📝 Test 8: Edit Plan');
  try {
    await api.editPlan(1, {
      'name': 'Test Plan Updated',
      'description': 'This is a test plan with updated description',
      'durationDays': 30,
      'price': 500.0,
    });
    print('✅ Plan edited successfully\n');
  } catch (e) {
    print('❌ Edit plan failed: $e\n');
  }
  
  // Test 9: Edit Session (if exists)
  print('📝 Test 9: Edit Session');
  try {
    await api.editSession(1, {
      'description': 'Updated session description with more details about the workout',
      'trainerId': 1,
      'startDate': '2024-05-01T10:00:00',
      'endDate': '2024-05-01T11:00:00',
    });
    print('✅ Session edited successfully\n');
  } catch (e) {
    print('❌ Edit session failed: $e\n');
  }
  
  print('🎉 All tests completed!');
}
