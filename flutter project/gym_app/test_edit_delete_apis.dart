import 'package:gym_app/api_service.dart';

/// 🧪 اختبار شامل لجميع APIs الخاصة بـ Edit و Delete
/// 
/// هذا الملف يختبر:
/// 1. editMember - تعديل بيانات عضو
/// 2. editTrainer - تعديل بيانات مدرب
/// 3. editPlan - تعديل خطة اشتراك
/// 4. editSession - تعديل جلسة تدريب
/// 5. deleteMember - حذف عضو
/// 6. deleteTrainer - حذف مدرب
/// 7. deleteSession - حذف جلسة
///
/// كيفية الاستخدام:
/// 1. قم بتشغيل الـ Backend على http://192.168.1.11:7165
/// 2. قم بتسجيل الدخول كـ Admin للحصول على Token
/// 3. قم بتشغيل هذا الملف: dart test_edit_delete_apis.dart
/// 4. راقب الـ Console لرؤية نتائج الاختبارات

void main() async {
  print('═══════════════════════════════════════════════════════════════');
  print('🧪 بدء اختبار Edit & Delete APIs');
  print('═══════════════════════════════════════════════════════════════\n');

  final api = ApiService();

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 1: تسجيل الدخول كـ Admin
  // ─────────────────────────────────────────────────────────────────
  print('📝 الخطوة 1: تسجيل الدخول كـ Admin...');
  try {
    // استخدم بيانات Admin الحقيقية من الـ Backend
    final token = await api.login('admin@gym.com', 'Admin@123');
    print('✅ تم تسجيل الدخول بنجاح');
    print('🔑 Token: ${token.substring(0, 20)}...\n');
  } catch (e) {
    print('❌ فشل تسجيل الدخول: $e');
    print('⚠️ تأكد من:');
    print('   1. الـ Backend يعمل على http://192.168.1.11:7165');
    print('   2. بيانات Admin صحيحة (admin@gym.com / Admin@123)');
    return;
  }

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 2: اختبار editMember
  // ─────────────────────────────────────────────────────────────────
  print('═══════════════════════════════════════════════════════════════');
  print('🧪 اختبار 1: editMember');
  print('═══════════════════════════════════════════════════════════════');
  
  // اختبار بيانات صحيحة
  print('\n✅ اختبار بيانات صحيحة:');
  try {
    await api.editMember(1, {
      'Name': 'Ahmed Mohamed Updated',
      'Phone': '01012345678',
      'Email': 'ahmed.updated@example.com',
      'BuildingNumber': 123,
      'Street': 'Main Street',
      'City': 'Cairo',
    });
    print('✅ تم تحديث العضو بنجاح');
  } catch (e) {
    print('❌ خطأ: $e');
  }

  // اختبار رقم هاتف غير صحيح
  print('\n❌ اختبار رقم هاتف غير صحيح:');
  try {
    await api.editMember(1, {
      'Name': 'Ahmed Mohamed',
      'Phone': '0123456789', // رقم خاطئ (يبدأ بـ 012 بدلاً من 010/011/012/015)
      'Email': 'ahmed@example.com',
      'BuildingNumber': 123,
      'Street': 'Main Street',
      'City': 'Cairo',
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // اختبار email غير صحيح
  print('\n❌ اختبار email غير صحيح:');
  try {
    await api.editMember(1, {
      'Name': 'Ahmed Mohamed',
      'Phone': '01012345678',
      'Email': 'invalid-email', // email غير صحيح
      'BuildingNumber': 123,
      'Street': 'Main Street',
      'City': 'Cairo',
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 3: اختبار editTrainer
  // ─────────────────────────────────────────────────────────────────
  print('\n═══════════════════════════════════════════════════════════════');
  print('🧪 اختبار 2: editTrainer');
  print('═══════════════════════════════════════════════════════════════');
  
  // اختبار بيانات صحيحة
  print('\n✅ اختبار بيانات صحيحة:');
  try {
    await api.editTrainer(1, {
      'Name': 'Mohamed Ali Updated',
      'Email': 'mohamed.updated@example.com',
      'Phone': '01112345678',
      'BuildingNumber': 456,
      'Street': 'Trainer Street',
      'City': 'Alexandria',
      'Specialization': 'Yoga',
    });
    print('✅ تم تحديث المدرب بنجاح');
  } catch (e) {
    print('❌ خطأ: $e');
  }

  // اختبار city يحتوي على أرقام
  print('\n❌ اختبار city يحتوي على أرقام:');
  try {
    await api.editTrainer(1, {
      'Name': 'Mohamed Ali',
      'Email': 'mohamed@example.com',
      'Phone': '01112345678',
      'BuildingNumber': 456,
      'Street': 'Trainer Street',
      'City': 'Cairo123', // city يحتوي على أرقام
      'Specialization': 'Yoga',
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 4: اختبار editPlan
  // ─────────────────────────────────────────────────────────────────
  print('\n═══════════════════════════════════════════════════════════════');
  print('🧪 اختبار 3: editPlan');
  print('═══════════════════════════════════════════════════════════════');
  
  // اختبار بيانات صحيحة
  print('\n✅ اختبار بيانات صحيحة:');
  try {
    await api.editPlan(1, {
      'PlanName': 'Premium Plan Updated',
      'Description': 'This is an updated premium plan with all features',
      'DurationDays': 90,
      'Price': 1500.0,
    });
    print('✅ تم تحديث الخطة بنجاح');
  } catch (e) {
    print('❌ خطأ: $e');
  }

  // اختبار description قصير جداً
  print('\n❌ اختبار description قصير جداً:');
  try {
    await api.editPlan(1, {
      'PlanName': 'Premium Plan',
      'Description': 'Hi', // أقل من 5 أحرف
      'DurationDays': 90,
      'Price': 1500.0,
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // اختبار price خارج النطاق
  print('\n❌ اختبار price خارج النطاق:');
  try {
    await api.editPlan(1, {
      'PlanName': 'Premium Plan',
      'Description': 'Valid description here',
      'DurationDays': 90,
      'Price': 15000.0, // أكبر من 10000
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 5: اختبار editSession
  // ─────────────────────────────────────────────────────────────────
  print('\n═══════════════════════════════════════════════════════════════');
  print('🧪 اختبار 4: editSession');
  print('═══════════════════════════════════════════════════════════════');
  
  // اختبار بيانات صحيحة
  print('\n✅ اختبار بيانات صحيحة:');
  try {
    await api.editSession(1, {
      'Description': 'Updated morning yoga session for beginners',
      'StartDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'EndDate': DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
      'TrainerId': 1,
    });
    print('✅ تم تحديث الجلسة بنجاح');
  } catch (e) {
    print('❌ خطأ: $e');
  }

  // اختبار description قصير جداً
  print('\n❌ اختبار description قصير جداً:');
  try {
    await api.editSession(1, {
      'Description': 'Short', // أقل من 10 أحرف
      'StartDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'EndDate': DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
      'TrainerId': 1,
    });
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // ─────────────────────────────────────────────────────────────────
  // الخطوة 6: اختبار Delete APIs
  // ─────────────────────────────────────────────────────────────────
  print('\n═══════════════════════════════════════════════════════════════');
  print('🧪 اختبار 5: Delete APIs');
  print('═══════════════════════════════════════════════════════════════');
  
  // اختبار deleteMember بـ ID غير صحيح
  print('\n❌ اختبار deleteMember بـ ID غير صحيح:');
  try {
    await api.deleteMember(0); // ID غير صحيح
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // اختبار deleteTrainer بـ ID غير صحيح
  print('\n❌ اختبار deleteTrainer بـ ID غير صحيح:');
  try {
    await api.deleteTrainer(-1); // ID غير صحيح
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // اختبار deleteSession بـ ID غير صحيح
  print('\n❌ اختبار deleteSession بـ ID غير صحيح:');
  try {
    await api.deleteSession(0); // ID غير صحيح
    print('⚠️ لم يتم اكتشاف الخطأ!');
  } catch (e) {
    print('✅ تم اكتشاف الخطأ بنجاح: $e');
  }

  // ─────────────────────────────────────────────────────────────────
  // النتيجة النهائية
  // ─────────────────────────────────────────────────────────────────
  print('\n═══════════════════════════════════════════════════════════════');
  print('✅ انتهى الاختبار!');
  print('═══════════════════════════════════════════════════════════════');
  print('\n📋 ملخص الاختبار:');
  print('   ✅ تم اختبار جميع Edit APIs (Member, Trainer, Plan, Session)');
  print('   ✅ تم اختبار جميع Delete APIs (Member, Trainer, Session)');
  print('   ✅ تم اختبار Validation للبيانات الصحيحة والخاطئة');
  print('\n💡 ملاحظات:');
  print('   • راجع الـ Console أعلاه لرؤية تفاصيل كل اختبار');
  print('   • إذا ظهرت أخطاء 400، تحقق من الـ Backend logs');
  print('   • تأكد من وجود بيانات في الـ Database (Members, Trainers, Plans, Sessions)');
  print('\n');
}
