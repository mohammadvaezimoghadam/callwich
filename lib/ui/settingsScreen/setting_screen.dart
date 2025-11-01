import 'package:callwich/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:callwich/di/di.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _cloudBackup = true;
  String _lastSync = '۱۴۰۲/۱۱/۰۱ ۱۴:۳۰';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F7),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'تنظیمات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () {
                        getIt<IAuthRepository>().singOut();
                      },
                      icon: Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Management
                        const Text(
                          'مدیریت کاربران',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _userTile(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCwPOxysyxhw9t__LS9ai0wQWpFfhRG7bwgn4zfpjF6xbmfH2RecpX7PjWPSxlWsytNR5iHT43NS-HAH8M1OVGg16LOxwspp9SRnNO_Pl9kQFnabsv7ryf3zCAw9YpsHakTdqJVR9oLZyIhcfLTeDa_vu8PvjkVVYYfDGhEipsh1THFizza8XpXiwJuZRux4FP1vUcz7fRrqQfyizkOT6NuO2oX21fLwvZqTh8fJyz6iBc9AjoI07i-eqtes8LofVNdsXrG-A2ET5g',
                                'اتان کارتر',
                                'مدیر',
                              ),
                              const Divider(
                                height: 24,
                                color: Color(0xFFE5E5E5),
                              ),
                              _userTile(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDpyDKJJ-WpigkCZ_baps5gRB9am_m7LysnXT4JQEbn1ZC2Ih5LxG8rJY71_wNS5KFyPdbioAL-0UNQvAPnfAfXTZFp8DA_p6ycwIYim6xKtSPVCIc_p8RNPkw-QsgG1HY1INSFnaso_r3kJL4L1Mi7EtDxeAaYKaD5MlHeIrxqlBQOkxsiOFTsMRNgb1wxqh1-tOkuqx-4i1yj54PSEEcsgSlljJdIR_TEoXuhFBHD0rybiBILOjPO1Uej1sfBPXIBr36sNw194N0',
                                'سوفیا کلارک',
                                'کارمند',
                              ),
                              const Divider(
                                height: 24,
                                color: Color(0xFFE5E5E5),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFed7c2c),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'افزودن کاربر',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Data Settings
                        const Text(
                          'تنظیمات داده',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'آخرین همگام‌سازی',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _lastSync,
                                    style: const TextStyle(
                                      color: Color(0xFF757575),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),
                                child: const Text('همگام‌سازی'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Backup Options
                        const Text(
                          'گزینه‌های پشتیبان‌گیری',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'پشتیبان‌گیری ابری',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Switch(
                                    value: _cloudBackup,
                                    activeColor: const Color(0xFFed7c2c),
                                    onChanged:
                                        (val) =>
                                            setState(() => _cloudBackup = val),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 24,
                                color: Color(0xFFE5E5E5),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFE5E5E5),
                                    ),
                                  ),
                                  child: const Text(
                                    'خروجی گرفتن از داده‌ها',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // About
                        const Text(
                          'درباره',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'نسخه برنامه',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '1.2.3',
                                    style: TextStyle(color: Color(0xFF757575)),
                                  ),
                                ],
                              ),
                              Divider(height: 24, color: Color(0xFFE5E5E5)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'تماس با توسعه‌دهنده',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'support@example.com',
                                    style: TextStyle(color: Color(0xFF757575)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userTile(String image, String name, String role) {
    return Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(baseUrlImg + image), radius: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              role,
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
          ],
        ),
      ],
    );
  }
}
