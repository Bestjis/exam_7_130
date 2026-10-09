import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/station_controller.dart';
import '../models/station_model.dart';
import 'edit_screen.dart';

class DisplayScreen extends StatelessWidget {
  final bool isAdmin;
  const DisplayScreen({super.key, required this.isAdmin});

  static const _dark = Color.fromARGB(255, 34, 0, 255);

  Color _aqiColor(int a) {
    if (a <= 50) return const Color(0xFF2E9E4F);
    if (a <= 100) return const Color(0xFFF2B01E);
    if (a <= 150) return const Color(0xFFF57C00);
    if (a <= 200) return const Color(0xFFE53935);
    if (a <= 300) return const Color(0xFF8E24AA);
    return const Color(0xFF7B1F2B);
  }

  String _aqiLabel(int a) {
    if (a <= 50) return 'อากาศดี';
    if (a <= 100) return 'ปานกลาง';
    if (a <= 150) return 'เริ่มมีผลต่อกลุ่มเสี่ยง';
    if (a <= 200) return 'มีผลต่อสุขภาพ';
    if (a <= 300) return 'มีผลต่อสุขภาพมาก';
    return 'อันตราย';
  }

  // ---------- กล่องถามยืนยัน (ใช้ร่วมกันทุกปุ่ม) ----------
  Future<bool> _ask(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(icon, color: color, size: 48),
        title: Text(title),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  // ---------- Delete: ถามก่อนลบเสมอ ----------
  Future<void> _confirmDelete(BuildContext context, Station s) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _ask(
      context,
      icon: Icons.warning_amber_rounded,
      color: Colors.red.shade500,
      title: 'ยืนยันการลบ',
      message:
          'ต้องการลบสถานี "${s.stationId}"\n(สถานีที่หยุดซ่อมบำรุงชั่วคราว) ใช่หรือไม่?\n\nการลบไม่สามารถกู้คืนได้',
      confirmLabel: 'ลบ',
    );
    if (!ok) return;
    await StationController().delete(s.id!);
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('ลบสถานี ${s.stationId} แล้ว'),
    ));
  }

  // ---------- Edit: ถามก่อน แล้วสลับไปหน้า EditScreen ----------
  Future<void> _confirmEdit(BuildContext context, Station s) async {
    final ok = await _ask(
      context,
      icon: Icons.tune,
      color: _dark,
      title: 'ปรับปรุงค่าเซนเซอร์',
      message: 'ต้องการแก้ไขค่า Calibrate ของสถานี\n"${s.stationId}" ใช่หรือไม่?',
      confirmLabel: 'แก้ไข',
    );
    if (!ok || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditScreen(station: s)),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(children: [
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
          ),
        ]),
      );

  Widget _header(int total, int danger) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_dark, Color(0xFF26A69A)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.monitor_heart_outlined,
                  color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('กระดานเฝ้าระวังมลพิษ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    Text('ทั้งหมด $total สถานี | AQI เกิน 100: $danger สถานี',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ]),
            if (!isAdmin) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('สิทธิ์ Operator: ดูและเพิ่มข้อมูลเท่านั้น',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: StationController().stream(),
      builder: (c, snap) {
        if (snap.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stations = snap.data!.docs.map(Station.fromDoc).toList();
        if (stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('ยังไม่มีข้อมูลสถานี',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        final danger = stations.where((s) => s.aqi > 100).length;

        return Column(
          children: [
            _header(stations.length, danger),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: stations.length,
                itemBuilder: (_, i) {
                  final s = stations[i];
                  final color = _aqiColor(s.aqi);
                  return Card(
                    margin: const EdgeInsets.only(top: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: color.withOpacity(0.35)),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.fromLTRB(14, 10, 8, 10),
                      leading: CircleAvatar(
                        radius: 29,
                        backgroundColor: color,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('AQI',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 9)),
                            Text('${s.aqi}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      title: Text(s.stationId,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(Icons.factory_outlined, 'โซน: ${s.zone}'),
                          _infoRow(Icons.grain, 'PM2.5: ${s.pm25} µg/m³'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_aqiLabel(s.aqi),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      // Admin เท่านั้นที่เห็นปุ่ม Edit / Delete
                      trailing: isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Calibrate เซนเซอร์',
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _confirmEdit(context, s),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: 'ลบสถานี',
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _confirmDelete(context, s),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}