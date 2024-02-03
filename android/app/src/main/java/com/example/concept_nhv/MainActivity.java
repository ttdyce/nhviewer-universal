package com.example.concept_nhv;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.webkit.CookieManager;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/cookies";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread.
                            if (call.method.equals("receiveCookies")) {
                                String cookies = receiveCookies();

                                if (cookies != "") {
                                    result.success(cookies);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    private String receiveCookies() {
        return CookieManager.getInstance().getCookie("https://nhentai.net");
        
        // int batteryLevel = -1;
        // if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
        //     BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
        //     batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        // } else {
        //     Intent intent = new ContextWrapper(getApplicationContext()).registerReceiver(null,
        //             new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        //     batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
        //             intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        // }

        // return batteryLevel;
    }
}