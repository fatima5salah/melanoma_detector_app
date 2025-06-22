import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // <-- مهم للتحقق من منصة الويب
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MelanomaDetectorApp());
}

class MelanomaDetectorApp extends StatelessWidget {
  const MelanomaDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Melanoma Detector',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.cairoTextTheme(textTheme),
      ),
      home: const SplashHomePage(),
    );
  }
}

// ------------------- الصفحة الرئيسية -------------------
class SplashHomePage extends StatefulWidget {
  const SplashHomePage({super.key});

  @override
  State<SplashHomePage> createState() => _SplashHomePageState();
}

class _SplashHomePageState extends State<SplashHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToScan() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showInstructions = prefs.getBool('show_instructions') ?? true;

    if (!mounted) return;

    if (showInstructions) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const InstructionsPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DetectionPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 120, height: 120),
                  const SizedBox(height: 20),
                  const Text('Melanoma Detector', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  const Text('كشف مبكر باستخدام الذكاء الاصطناعي', style: TextStyle(color: Colors.white70, fontSize: 18), textAlign: TextAlign.center),
                  const SizedBox(height: 50),
                  _buildHomePageButton(text: 'ابدأ الفحص', onPressed: _navigateToScan, isPrimary: true),
                  const SizedBox(height: 20),
                  _buildHomePageButton(text: 'معلومات وإرشادات', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoPage()))),
                  const SizedBox(height: 20),
                  _buildHomePageButton(text: 'حول التطبيق', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePageButton({required String text, required VoidCallback onPressed, bool isPrimary = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.deepPurple.shade100.withOpacity(0.8),
        foregroundColor: isPrimary ? Colors.deepPurple : Colors.deepPurple.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        textStyle: TextStyle(fontSize: 18, fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// ------------------- صفحة الفحص (نسخة الويب التجريبية) -------------------
class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _predictionResult;
  double? _confidence;
  bool? _isPredictionMalignant;
  bool _isLoading = false;
  bool _isPickerActive = false; 

  // تم حذف initState و dispose لأنهما لم يعودا ضروريين في نسخة الويب
  // بعد إزالة النموذج (Interpreter).

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('حدث خطأ'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // هذه الدالة تم إزالتها لأننا لا نقوم بمعالجة متقدمة في نسخة الويب
  // Future<Uint8List> _preprocessImage(File imageFile) async { ... }

  // دالة المحاكاة التي تعطي نتيجة وهمية
  Future<void> _runInference() async {
    if (_imageFile == null) return;
    
    if (!mounted) return;
    setState(() => _isLoading = true);

    // --- قسم المحاكاة ---
    // سننتظر ثانيتين لكي يبدو وكأنه يقوم بالتحليل
    await Future.delayed(const Duration(seconds: 2));

    // سنقوم بتوليد نتيجة عشوائية في كل مرة
    final isMalignant = (DateTime.now().second % 2) == 0;
    final confidence = 0.85 + (DateTime.now().millisecond % 10) / 100.0; // رقم بين 85% و 95%

    if(mounted) {
      setState(() {
        if (isMalignant) {
          _predictionResult = "خبيث";
          _confidence = confidence;
          _isPredictionMalignant = true;
        } else {
          _predictionResult = "حميد";
          _confidence = confidence;
          _isPredictionMalignant = false;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndPredict(ImageSource source) async {
    if (_isPickerActive) return;

    // على الويب، لا نحتاج إلى طلب أذونات
    if (!kIsWeb) {
      PermissionStatus status = source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();
      if (!status.isGranted) {
        _showErrorDialog('نحتاج إلى إذن للوصول إلى ${source == ImageSource.camera ? "الكاميرا" : "الصور"}.');
        if (status.isPermanentlyDenied) openAppSettings();
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isPickerActive = true);
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          // على الويب، لا يوجد مسار حقيقي للملف، لذلك نستخدم pickedFile.path
          _imageFile = File(pickedFile.path);
          _predictionResult = null;
          _confidence = null;
          _isPredictionMalignant = null;
        });
        await _runInference(); 
      }
    } finally {
      if (mounted) { setState(() => _isPickerActive = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('فحص الميلانوما (نسخة تجريبية)'), backgroundColor: Colors.deepPurple.shade400, ),
      body: Container(
        decoration: BoxDecoration( gradient: LinearGradient( colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade400], begin: Alignment.topCenter, end: Alignment.bottomCenter, ), ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack( alignment: Alignment.center, children: [
                  Container(
                    width: 310, height: 310,
                    decoration: BoxDecoration( color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), ),
                    child: Center(
                      child: _imageFile == null
                          ? Column( mainAxisAlignment: MainAxisAlignment.center, children: const [ Icon(Icons.image_search, size: 80, color: Colors.white70), SizedBox(height: 16), Text('اختر صورة للتحليل', style: TextStyle(color: Colors.white, fontSize: 16)), ], )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              // تعديل بسيط لعرض الصورة على الويب
                              child: kIsWeb 
                                ? Image.network(_imageFile!.path, fit: BoxFit.cover, width: 310, height: 310) 
                                : Image.file(_imageFile!, fit: BoxFit.cover, width: 310, height: 310),
                            ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      width: 310, height: 310,
                      decoration: BoxDecoration( color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20), ),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                ], ),
                const SizedBox(height: 30),
                Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildActionButton( icon: Icons.photo_library_outlined, label: 'المعرض', isEnabled: !_isLoading && !_isPickerActive, onPressed: () => _pickAndPredict(ImageSource.gallery), ),
                  if (!kIsWeb) // الكاميرا لا تعمل بنفس الطريقة على كل المتصفحات، يمكن إخفاؤها في الويب
                    const SizedBox(width: 20),
                  if (!kIsWeb)
                    _buildActionButton( icon: Icons.camera_alt_outlined, label: 'الكاميرا', isEnabled: !_isLoading && !_isPickerActive, onPressed: () => _pickAndPredict(ImageSource.camera), ),
                ], ),
                const SizedBox(height: 40),
                if (_predictionResult != null && _confidence != null && _isPredictionMalignant != null)
                  _buildResultCard(_predictionResult!, _confidence!, _isPredictionMalignant!),
                
                const SizedBox(height: 40),
                const Text(
                  'إخلاء مسؤولية: هذه نسخة تجريبية للويب والنتائج للتوضيح فقط. استشر الطبيب للحصول على أي نصيحة طبية.', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed, required bool isEnabled}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300, elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
  
  Widget _buildResultCard(String result, double confidence, bool isMalignant) {
    Color resultColor = isMalignant ? Colors.red.shade700 : Colors.green.shade700;
    IconData resultIcon = isMalignant ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(resultIcon, color: resultColor, size: 35),
              const SizedBox(width: 12),
              Text(result, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: resultColor)),
            ], ),
            const SizedBox(height: 12),
            Text( 'بنسبة ثقة: ${(confidence * 100).toStringAsFixed(2)}%', style: TextStyle(fontSize: 18, color: Colors.grey.shade700), ),
          ],
        ),
      ),
    );
  }
}

// ------------------- صفحة التعليمات -------------------
class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  bool _dontShowAgain = false;

  Future<void> _onContinue() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_instructions', false);
    }
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DetectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعليمات التصوير'),
        backgroundColor: Colors.deepPurple.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 150), // زيادة الحاشية السفلية للزر
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('للحصول على أفضل نتيجة ممكنة', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800)),
            const SizedBox(height: 8),
            const Text('يرجى اتباع الإرشادات التالية لضمان دقة التحليل:', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const Divider(height: 32, thickness: 1),
            _buildInstructionItem(context, Icons.lightbulb_outline, Colors.amber.shade700, 'استخدم إضاءة جيدة وطبيعية. تجنب الظلال على المنطقة المصورة.'),
            _buildInstructionItem(context, Icons.center_focus_strong, Colors.blue.shade700, 'اجعل الشامة في منتصف الصورة بالضبط وتأكد من وضوحها.'),
            _buildInstructionItem(context, Icons.zoom_in_map_outlined, Colors.green.shade700, 'صور الجلد فقط. تأكد من عدم ظهور أي جزء من الملابس أو أي شيء آخر.'),
            _buildInstructionItem(context, Icons.flash_off_outlined, Colors.red.shade700, 'تجنب استخدام الفلاش لأنه يسبب انعكاسات ضوئية.'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPhotoExample(context, 'assets/good_photo_example.png', 'مثال جيد', Colors.green.shade700),
                _buildPhotoExample(context, 'assets/bad_photo_example.png', 'مثال سيء', Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('عدم إظهار هذه الرسالة مرة أخرى'),
              value: _dontShowAgain,
              onChanged: (bool? value) {
                setState(() {
                  _dontShowAgain = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.deepPurple,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('فهمت، متابعة للفحص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(BuildContext context, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5))),
        ],
      ),
    );
  }
  
  Widget _buildPhotoExample(BuildContext context, String assetPath, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(border: Border.all(color: color, width: 2), borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(assetPath, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ------------------- صفحة حول التطبيق -------------------
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text( title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700), ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.deepPurple.shade700),
        ],
      ),
    );
  }

  Widget _buildSectionContent(String text) {
    return Text( text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15.5, height: 1.6, color: Colors.black87), );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar( title: const Text('حول التطبيق'), backgroundColor: Colors.deepPurple.shade400, ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar( backgroundImage: const AssetImage('assets/logo.png'), radius: 50, backgroundColor: Colors.deepPurple.shade100, ),
                const SizedBox(height: 16),
                const Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Text('🧬', style: TextStyle(fontSize: 24)), SizedBox(width: 8), Text( 'Melanoma Detector', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), ), ], ),
                
                _buildSectionTitle('الرؤية والهدف', Icons.track_changes),
                _buildSectionContent('انطلق هذا المشروع من فكرتنا كفريق طلابي، إيمانًا منا بأهمية تسخير قوة الذكاء الاصطناعي لخدمة المجتمع في المجال الصحي. هدفنا هو تقديم أداة مساعدة بسيطة تساهم في زيادة الوعي حول سرطان الجلد (الميلانوما) وتشجع على الكشف المبكر.'),

                _buildSectionTitle('التقنيات المستخدمة', Icons.build_circle_outlined),
                _buildSectionContent('• Flutter & Dart\n• TensorFlow Lite\n• OpenCV\n• نموذج CNN مخصص'),
                
                _buildSectionTitle('شكر وتقدير', Icons.favorite_border),
                _buildSectionContent('يتقدم فريق العمل بخالص الشكر والتقدير إلى مشرفة المشروع، الأستاذة أمينة عبدو، على توجيهاتها القيمة ودعمها الأكاديمي المستمر.'),

                _buildSectionTitle('فريق التطوير', Icons.group_outlined),
                _buildSectionContent('• فاطمة الزهراء صلاح خليل\n• رونده رأفت أحمد\n• مريم صفي الدين صالح'),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),

                const Center( child: Text( 'امسح الكود لزيارة صفحة المطورين', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), ), ),
                const SizedBox(height: 12),
                Center( child: Container( padding: const EdgeInsets.all(8), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, ) ] ), child: Image.asset( 'assets/team_qrcode.png', width: 140, height: 140, ), ), ),

                const SizedBox(height: 30),
                const Text( 'الإصدار 1.0.0\n📅 تم تطوير التطبيق في عام 2025 ضمن مشروع التخرج بكل فخر', style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center, ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- صفحة المعلومات والإرشادات -------------------
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('إرشادات ومعلومات'), backgroundColor: Colors.deepPurple.shade400, ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard( title: 'ما هو سرطان الجلد (الميلانوما)؟', icon: Icons.info_outline, content: const Text( 'الميلانوما هو أخطر أنواع سرطان الجلد. يتطور في الخلايا المسؤولة عن إنتاج الميلانين (الصبغة التي تعطي الجلد لونه). يمكن أن يظهر في أي مكان على الجسم، ولكنه أكثر شيوعًا في المناطق التي تتعرض لأشعة الشمس.', style: TextStyle(fontSize: 16, height: 1.5), ), ),
              const SizedBox(height: 20),
              _buildSectionCard( title: 'قاعدة ABCDE للكشف المبكر', icon: Icons.rule, content: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text('استخدم هذه القاعدة البسيطة لفحص الشامات أو البقع الجلدية المشبوهة:', style: TextStyle(fontSize: 16, height: 1.5),), const SizedBox(height: 16), _buildAbcdeRuleItem('A', 'Asymmetry (عدم التماثل)', 'الشامة الحميدة تكون متماثلة، بينما الميلانوما تكون غير متماثلة الشكل.', context), _buildAbcdeRuleItem('B', 'Border (الحواف)', 'حواف الشامة الحميدة تكون منتظمة، بينما حواف الميلانوما تكون غير منتظمة أو متعرجة.', context), _buildAbcdeRuleItem('C', 'Color (اللون)', 'الشامة الحميدة لها لون واحد، بينما الميلانوما قد تحتوي على عدة ألوان (بني, أسود, أحمر, أزرق).', context), _buildAbcdeRuleItem('D', 'Diameter (القطر)', 'الشامة الحميدة قطرها أصغر من 6 ملم، بينما الميلانوما غالباً ما تكون أكبر.', context), _buildAbcdeRuleItem('E', 'Evolving (التطور)', 'أي تغيير في حجم أو شكل أو لون الشامة مع مرور الوقت هو علامة تحذيرية.', context), ], ), ),
              const SizedBox(height: 20),
              _buildSectionCard( title: 'نصائح للوقاية من الشمس', icon: Icons.wb_sunny_outlined, content: Column( children: [ _buildTipItem('استخدم واقي الشمس بعامل حماية (SPF) 30 أو أعلى.'), _buildTipItem('تجنب التعرض للشمس في ساعات الذروة (10 صباحًا - 4 مساءً).'), _buildTipItem('ارتدِ ملابس واقية, قبعات, ونظارات شمسية.'), _buildTipItem('قم بإجراء فحص ذاتي لجلدك بانتظام.'), ], ), ),
              const SizedBox(height: 20),
              Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200), ), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28), const SizedBox(width: 12), const Expanded( child: Text( 'تنبيه هام: هذا التطبيق هو أداة مساعدة لأغراض تعليمية فقط ضمن مشروع التخرج، ولا يغني إطلاقاً عن استشارة طبيب مختص. التشخيص النهائي يجب أن يتم من قبل متخصص طبي.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87), ), ), ], ), ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) { return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: Padding( padding: const EdgeInsets.all(16.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Row( children: [ Icon(icon, color: Colors.deepPurple, size: 28), const SizedBox(width: 10), Expanded( child: Text( title, style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple, ), ), ), ], ), const Divider(height: 24, thickness: 1), content, ], ), ), ); }
  Widget _buildAbcdeRuleItem(String letter, String title, String description, BuildContext context) { return Padding( padding: const EdgeInsets.only(bottom: 16.0), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Container( width: 60, height: 60, decoration: BoxDecoration( color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.deepPurple.shade100), ), child: Center( child: Text( letter, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple), ), ), ), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), ), const SizedBox(height: 4), Text( description, style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7)), ), ], ), ), ], ), ); }
  Widget _buildTipItem(String text) { return Padding( padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Icon(Icons.check_circle_outline, size: 20, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 15.5))), ], ), ); }
}
