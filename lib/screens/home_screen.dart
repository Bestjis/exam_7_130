import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'display_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _dark = Color.fromARGB(255, 0, 0, 255);

  // กล่องยืนยันก่อนออกจากระบบ
  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.logout, color: _dark, size: 44),
        title: const Text('ออกจากระบบ'),
        content: const Text(
          'ต้องการออกจากระบบใช่หรือไม่?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _dark),
            icon: const Icon(Icons.logout),
            label: const Text('ออกจากระบบ'),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.signOut();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<String>(
      stream: auth.roleStream(user.uid),
      builder: (context, snap) {
        final role = snap.data ?? 'Operator';
        final isAdmin = role == 'Admin';

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: _dark,
              foregroundColor: Colors.white,
              title: Text('EnviroSense ($role)',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () => _confirmLogout(context, auth),
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.edit_note), text: 'บันทึกข้อมูล'),
                  Tab(icon: Icon(Icons.dashboard), text: 'กระดานเฝ้าระวัง'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const FormScreen(),
                DisplayScreen(isAdmin: isAdmin),
              ],
            ),
          ),
        );
      },
    );
  }
}