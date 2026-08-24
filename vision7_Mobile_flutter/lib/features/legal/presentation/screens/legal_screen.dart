import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';

enum LegalDocument { terms, privacy }

/// Current accepted version of each document — bump when the copy changes
/// materially. Sent to the backend on acceptance so consent stays auditable
/// against a specific revision.
class LegalVersions {
  static const terms = '1.0';
  static const privacy = '2.0';
}

class LegalScreen extends StatelessWidget {
  final LegalDocument document;
  const LegalScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final t = lang.t;
    final isAcademy = context.watch<ModeProvider>().isAcademy;
    final isTerms = document == LegalDocument.terms;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios, color: isAcademy ? AppColors.cream : AppColors.black),
                  ),
                  Expanded(
                    child: Text(
                      isTerms
                          ? t('profile.termsOfService', fallback: 'Terms of Service')
                          : t('profile.privacyPolicy', fallback: 'Privacy Policy'),
                      style: Theme.of(context).textTheme.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version ${isTerms ? LegalVersions.terms : LegalVersions.privacy} · Last updated August 2026',
                      style: TextStyle(
                        color: isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      isTerms
                          ? (lang.isArabic ? _termsBodyAr : _termsBody)
                          : (lang.isArabic ? _privacyBodyAr : _privacyBody),
                      style: Theme.of(context).textTheme.body.copyWith(height: 1.6),
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

const _termsBody = '''
1. Acceptance of Terms

By creating a Vision7 account or using the Vision7 app, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.

2. Facility Bookings & Memberships

Bookings, membership purchases and cancellations made through the app are subject to Vision7's facility rules, refund policy and pricing shown at time of purchase.

3. Account Responsibility

You are responsible for keeping your login credentials secure and for all activity under your account.

4. Conduct

Users must follow facility safety rules and staff instructions at all Vision7 Academy and Vision7 Leisure locations.

5. Changes to These Terms

Vision7 may update these terms from time to time. Continued use of the app after changes take effect constitutes acceptance of the revised terms.

6. Contact

Questions about these terms can be directed to Vision7 support.
''';

// Machine-translated by Claude — needs legal/compliance review before being
// treated as the authoritative Arabic text (PDPL-specific terminology in
// particular should be checked against counsel-reviewed language).
const _termsBodyAr = '''
1. قبول الشروط

بإنشاء حساب في فيجن7 أو استخدام تطبيق فيجن7، فإنك توافق على الالتزام بشروط الخدمة هذه. إذا كنت لا توافق، فيرجى عدم استخدام التطبيق.

2. حجوزات المرافق والعضويات

تخضع الحجوزات وعمليات شراء العضويات وإلغائها التي تتم عبر التطبيق لقواعد مرافق فيجن7، وسياسة الاسترداد، والأسعار المعروضة وقت الشراء.

3. مسؤولية الحساب

أنت مسؤول عن الحفاظ على سرية بيانات تسجيل الدخول الخاصة بك وعن جميع الأنشطة التي تتم تحت حسابك.

4. السلوك

يجب على المستخدمين اتباع قواعد السلامة الخاصة بالمرافق وتعليمات الموظفين في جميع مواقع أكاديمية فيجن7 وفيجن7 للترفيه.

5. التغييرات على هذه الشروط

يجوز لفيجن7 تحديث هذه الشروط من وقت لآخر. يُعد استمرار استخدام التطبيق بعد سريان التغييرات بمثابة قبول للشروط المعدَّلة.

6. التواصل

يمكن توجيه الأسئلة حول هذه الشروط إلى فريق دعم فيجن7.
''';

const _privacyBody = '''
1. Who We Are

VA 7 Company (Vision7 Academy) is the data controller. We operate sports facilities and academies in Saudi Arabia.

2. What We Collect

We collect: your name, email, phone number, date of birth, account credentials, booking and membership activity, payment information, and images you upload. We also collect device and usage data to operate the app.

3. Why We Use Your Data

Your data is used to create and manage your account, process bookings and payments, deliver academy and facility services, send booking reminders and notifications, and — where you have consented — for marketing communications.

4. Children & Guardians

Players under 18 must be registered by a parent or legal guardian. Guardian consent is required for health-related data and marketing communications.

5. How We Share Data

We do not sell your personal data. We share it only with service providers needed to operate Vision7 — payment processors (Tabby, Tamara, Visa, MasterCard), cloud hosting providers, and authorities when required by law.

6. Data Hosting

All data is hosted in Saudi Arabia. Cross-border data transfers follow applicable data protection safeguards.

7. How Long We Keep Data

Your account data is retained while your account is active plus five years. CCTV footage is retained for 30–90 days.

8. Your Rights

You may request access to, correction of, or deletion of your personal data. You may withdraw consent for marketing at any time. Requests can be made by contacting privacy@vision7.sa.

9. Marketing Communications

You can opt out of marketing communications at any time via the app settings, unsubscribe links in emails, or by contacting our support team.

10. Security

We use encrypted servers, firewalls, role-based access controls, and staff training to protect your data.

11. Contact

Questions about this policy? Email privacy@vision7.sa or call +966 9200 19777.
''';

// Machine-translated by Claude — needs legal/compliance review before being
// treated as the authoritative Arabic text (PDPL-specific terminology in
// particular should be checked against counsel-reviewed language).
const _privacyBodyAr = '''
1. من نحن

شركة VA 7 (أكاديمية فيجن7) هي جهة التحكم في البيانات. نُدير مرافق وأكاديميات رياضية في المملكة العربية السعودية.

2. ما نجمعه

نجمع: اسمك، بريدك الإلكتروني، رقم هاتفك، تاريخ ميلادك، بيانات اعتماد الحساب، نشاط الحجوزات والعضوية، معلومات الدفع، والصور التي ترفعها. كما نجمع بيانات الجهاز والاستخدام لتشغيل التطبيق.

3. سبب استخدامنا لبياناتك

تُستخدم بياناتك لإنشاء حسابك وإدارته، ومعالجة الحجوزات والمدفوعات، وتقديم خدمات الأكاديمية والمرافق، وإرسال تذكيرات وإشعارات الحجز، وللاتصالات التسويقية — حيثما وافقت على ذلك.

4. الأطفال وأولياء الأمور

يجب تسجيل اللاعبين دون سن 18 عامًا من قِبل أحد الوالدين أو ولي الأمر الشرعي. موافقة ولي الأمر مطلوبة للبيانات المتعلقة بالصحة والاتصالات التسويقية.

5. كيف نشارك البيانات

نحن لا نبيع بياناتك الشخصية. نشاركها فقط مع مزودي الخدمات اللازمة لتشغيل فيجن7 — معالجات الدفع (تابي، تمارا، فيزا، ماستركارد)، مزودي الاستضافة السحابية، والجهات الرسمية عند الاقتضاء القانوني.

6. استضافة البيانات

تُستضاف جميع البيانات داخل المملكة العربية السعودية. تخضع عمليات نقل البيانات عبر الحدود لضمانات حماية البيانات المعمول بها.

7. مدة الاحتفاظ بالبيانات

يتم الاحتفاظ ببيانات حسابك طوال فترة نشاط الحساب بالإضافة إلى خمس سنوات. يتم الاحتفاظ بتسجيلات كاميرات المراقبة لمدة 30 إلى 90 يومًا.

8. حقوقك

يمكنك طلب الوصول إلى بياناتك الشخصية أو تصحيحها أو حذفها. يمكنك سحب موافقتك على التسويق في أي وقت. يمكن تقديم الطلبات عبر التواصل مع privacy@vision7.sa.

9. الاتصالات التسويقية

يمكنك إلغاء الاشتراك في الاتصالات التسويقية في أي وقت عبر إعدادات التطبيق، أو روابط إلغاء الاشتراك في الرسائل الإلكترونية، أو بالتواصل مع فريق الدعم لدينا.

10. الأمان

نستخدم خوادم مشفّرة وجدران حماية وضوابط وصول قائمة على الأدوار وتدريب الموظفين لحماية بياناتك.

11. التواصل

هل لديك أسئلة حول هذه السياسة؟ راسلنا عبر privacy@vision7.sa أو اتصل على 19777 9200 966+.
''';
