import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  static const _dark = Color.fromARGB(255, 0, 29, 249);
  static const _light = Color.fromARGB(255, 6, 61, 224);

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthController()
          .signIn(_email.text.trim(), _pw.text)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      if (!mounted) return;
      _showError(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // แปลง error เป็นข้อความที่บอกสาเหตุจริง
  String _errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'network-request-failed':
          return 'ไม่มีอินเทอร์เน็ต หรือเชื่อมต่อเซิร์ฟเวอร์ไม่ได้\nกรุณาตรวจสอบการเชื่อมต่อ';
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-disabled':
          return 'บัญชีนี้ถูกระงับการใช้งาน';
        case 'too-many-requests':
          return 'ลองเข้าสู่ระบบหลายครั้งเกินไป กรุณารอสักครู่';
        case 'operation-not-allowed':
          return 'ยังไม่ได้เปิดใช้ Email/Password ใน Firebase Authentication';
        default:
          return 'เกิดข้อผิดพลาด: ${e.code}';
      }
    }
    if (e is TimeoutException) {
      return 'หมดเวลาเชื่อมต่อ (เครือข่ายช้าหรือไม่มีอินเทอร์เน็ต)';
    }
    return 'เกิดข้อผิดพลาด: $e';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 5),
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
      ),
    );
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _dark),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _light, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 40, 24, 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_dark, _light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(70),
          bottomRight: Radius.circular(70),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.wind_power, size: 60, color: _dark),
          ),
          const SizedBox(height: 18),
          const Text(
            'EnviroSense',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Industrial AQI & Emission Monitor',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ยินดีต้อนรับ',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _dark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เข้าสู่ระบบเพื่อใช้งานระบบเฝ้าระวังมลพิษ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _deco('อีเมล', Icons.email_outlined),
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                        EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                      ]).call,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _pw,
                      obscureText: _hide,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: _deco(
                        'รหัสผ่าน',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _hide ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator:
                          RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน').call,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dark,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: const StadiumBorder(),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
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
}