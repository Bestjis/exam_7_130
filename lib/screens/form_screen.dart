import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/station_controller.dart';
import '../models/station_model.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  static const _dark = Color.fromARGB(255, 0, 110, 255);
  static const _light = Color.fromARGB(255, 0, 110, 255);

  final _key = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _zone = TextEditingController();
  final _email = TextEditingController();
  final _aqi = TextEditingController();
  final _pm = TextEditingController();
  bool _saving = false;

  String? _aqiCheck(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกค่า AQI';
    final n = int.tryParse(v.trim());
    if (n == null) return 'กรอกเป็นตัวเลขเท่านั้น';
    if (n < 0 || n > 500) return 'AQI ต้องอยู่ระหว่าง 0-500';
    return null;
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await StationController().add(Station(
        stationId: _id.text.trim(),
        zone: _zone.text.trim(),
        officerEmail: _email.text.trim(),
        aqi: int.parse(_aqi.text.trim()),
        pm25: double.parse(_pm.text.trim()),
      ));
      for (final c in [_id, _zone, _email, _aqi, _pm]) {
        c.clear();
      }
      _key.currentState!.reset();
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _dark,
        content: const Text('บันทึกข้อมูลสถานีสำเร็จ'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
        content: const Text('บันทึกไม่สำเร็จ กรุณาลองใหม่'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _deco(String label, IconData icon, {String? hint}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _dark),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_light, 2),
      errorBorder: border(Colors.red.shade300),
      focusedErrorBorder: border(Colors.red.shade400, 2),
    );
  }

  Widget _sectionTitle(String text, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 12),
        child: Row(children: [
          Icon(icon, color: _dark, size: 20),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _dark)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_dark, _light]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.sensors, color: Colors.white, size: 40),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('รับค่าจากสถานีตรวจวัดปลายทาง',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('กรอกข้อมูลสถานีและค่าคุณภาพอากาศล่าสุด',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('ข้อมูลสถานี', Icons.location_on_outlined),
                    TextFormField(
                      controller: _id,
                      textInputAction: TextInputAction.next,
                      decoration: _deco(
                          'รหัสสถานีตรวจวัด', Icons.confirmation_number_outlined,
                          hint: 'เช่น STATION-IND-EAST'),
                      validator: RequiredValidator(
                          errorText: 'กรุณากรอกรหัสสถานี').call,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _zone,
                      textInputAction: TextInputAction.next,
                      decoration: _deco(
                          'บริเวณที่ตั้งในโรงงาน (Zone)', Icons.factory_outlined),
                      validator:
                          RequiredValidator(errorText: 'กรุณากรอกบริเวณ').call,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _deco('อีเมลเจ้าหน้าที่ความปลอดภัย (จป.)',
                          Icons.email_outlined),
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                        EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                      ]).call,
                    ),
                    const SizedBox(height: 10),
                    _sectionTitle('ค่าที่วัดได้', Icons.air),
                    TextFormField(
                      controller: _aqi,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: _deco('ดัชนีคุณภาพอากาศ (AQI)', Icons.speed,
                          hint: '0 - 500'),
                      validator: _aqiCheck,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pm,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.done,
                      decoration: _deco(
                          'ความเข้มข้น PM2.5 (µg/m³)', Icons.grain),
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'กรุณากรอกค่า PM2.5'),
                        PatternValidator(r'^\d+(\.\d+)?$',
                            errorText: 'กรอกเป็นตัวเลขเท่านั้น'),
                      ]).call,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dark,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Icon(Icons.save_outlined),
                        label: const Text('บันทึกข้อมูล',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}