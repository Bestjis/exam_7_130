import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/station_controller.dart';
import '../models/station_model.dart';

class EditScreen extends StatefulWidget {
  final Station station;
  const EditScreen({super.key, required this.station});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  static const _dark = Color.fromARGB(255, 0, 26, 255);
  static const _light = Color.fromARGB(255, 0, 26, 255);

  final _key = GlobalKey<FormState>();
  late final TextEditingController _id;
  late final TextEditingController _zone;
  late final TextEditingController _email;
  late final TextEditingController _aqi;
  late final TextEditingController _pm;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.station;
    _id = TextEditingController(text: s.stationId);
    _zone = TextEditingController(text: s.zone);
    _email = TextEditingController(text: s.officerEmail);
    _aqi = TextEditingController(text: s.aqi.toString());
    _pm = TextEditingController(text: s.pm25.toString());
  }

  @override
  void dispose() {
    for (final c in [_id, _zone, _email, _aqi, _pm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _aqiCheck(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกค่า AQI';
    final n = int.tryParse(v.trim());
    if (n == null) return 'กรอกเป็นตัวเลขเท่านั้น';
    if (n < 0 || n > 500) return 'AQI ต้องอยู่ระหว่าง 0-500';
    return null;
  }

  // กล่องถามยืนยันก่อนบันทึก
  Future<bool> _confirmSave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.save_outlined, color: _dark, size: 48),
        title: const Text('ยืนยันการบันทึก'),
        content: Text(
          'บันทึกการแก้ไขสถานี "${_id.text.trim()}" ใช่หรือไม่?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _dark),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (!await _confirmSave()) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _id.text.trim();
    try {
      await StationController().update(
        widget.station.id!,
        Station(
          stationId: name,
          zone: _zone.text.trim(),
          officerEmail: _email.text.trim(),
          aqi: int.parse(_aqi.text.trim()),
          pm25: double.parse(_pm.text.trim()),
        ),
      );
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _dark,
        content: Text('แก้ไขสถานี $name เรียบร้อยแล้ว'),
      ));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
        content: const Text('บันทึกไม่สำเร็จ กรุณาลองใหม่'),
      ));
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        title: const Text('แก้ไขข้อมูลสถานี',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_dark, _light]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.tune, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ปรับปรุงข้อมูลสถานี',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('กำลังแก้ไข: ${widget.station.stationId}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
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
                        decoration: _deco('รหัสสถานีตรวจวัด',
                            Icons.confirmation_number_outlined),
                        validator: RequiredValidator(
                            errorText: 'กรุณากรอกรหัสสถานี'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _zone,
                        textInputAction: TextInputAction.next,
                        decoration: _deco('บริเวณที่ตั้งในโรงงาน (Zone)',
                            Icons.factory_outlined),
                        validator:
                            RequiredValidator(errorText: 'กรุณากรอกบริเวณ'),
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
                        ]),
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
                        ]),
                      ),
                      const SizedBox(height: 24),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed:
                                  _saving ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _dark,
                                side: const BorderSide(color: _dark),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('ยกเลิก',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
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
                                          strokeWidth: 2.5,
                                          color: Colors.white))
                                  : const Icon(Icons.save_outlined),
                              label: const Text('บันทึกการแก้ไข',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}