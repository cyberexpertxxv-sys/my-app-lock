import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Application> apps = [];
  List<Application> filtered = [];
  Set<String> lockedApps = {};
  bool masterOn = true;
  bool loading = true;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: false,
      includeAppIcons: true,
    );

    list.sort((a, b) =>
        a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    lockedApps = (prefs.getStringList('locked_apps') ?? []).toSet();
    masterOn = prefs.getBool('master_on') ?? true;

    if (mounted) {
      setState(() {
        apps = list;
        filtered = list;
        loading = false;
      });
    }
  }

  Future<void> _toggleApp(String pkg, bool val) async {
    setState(() {
      if (val) {
        lockedApps.add(pkg);
      } else {
        lockedApps.remove(pkg);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locked_apps', lockedApps.toList());
  }

  Future<void> _masterToggle(bool val) async {
    setState(() {
      masterOn = val;
      if (!val) lockedApps.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('master_on', val);
    await prefs.setStringList('locked_apps', lockedApps.toList());
  }

  void _search(String q) {
    setState(() {
      filtered = apps
          .where((a) => a.appName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _openAccessibilitySettings() async {
    const platform = MethodChannel('app_lock/control');
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("APP LOCK",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openAccessibilitySettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield, color: Colors.greenAccent),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Lock All Apps",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                Switch(
                  value: masterOn,
                  activeColor: Colors.greenAccent,
                  onChanged: _masterToggle,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchCtrl,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search apps...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final app = filtered[i];
                final isLocked = lockedApps.contains(app.packageName);
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ListTile(
                    leading: app is ApplicationWithIcon
                        ? Image.memory(app.icon, width: 40, height: 40)
                        : const Icon(Icons.apps, color: Colors.white54),
                    title: Text(app.appName,
                        style: const TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: masterOn && isLocked,
                      activeColor: Colors.greenAccent,
                      onChanged: masterOn
                          ? (val) => _toggleApp(app.packageName, val)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
