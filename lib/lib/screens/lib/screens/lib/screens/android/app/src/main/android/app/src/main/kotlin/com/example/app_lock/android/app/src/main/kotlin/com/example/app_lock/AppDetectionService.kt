package com.example.app_lock

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent

class AppDetectionService : AccessibilityService() {

    private lateinit var prefs: SharedPreferences

    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        if (packageName == this.packageName) return
        if (packageName == "com.android.systemui") return

        val masterOn = prefs.getBoolean("flutter.master_on", true)
        if (!masterOn) return

        val lockedApps = prefs.getStringSet("flutter.locked_apps", emptySet()) ?: emptySet()

        if (lockedApps.contains(packageName)) {
            val intent = Intent(this, OverlayActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION
                putExtra("locked_package", packageName)
            }
            startActivity(intent)
        }
    }

    override fun onInterrupt() {}
}
