package io.agora.hack.believe.utils;

import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Debug;
import android.util.Log;

import java.net.NetworkInterface;
import java.util.Enumeration;

public class DeviceUtils {
    private static final String TAG = "AIKIT_DeviceUtils";

    /**
     * 获取Wifi Mac 默认值空字符串
     *
     * @param paramContext
     * @return
     */
    public static String getWifiMac(Context paramContext) {

        String result = "";

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
                while (interfaces != null && interfaces.hasMoreElements()) {
                    NetworkInterface iF = interfaces.nextElement();
                    byte[] addr = iF.getHardwareAddress();
                    if (addr == null || addr.length == 0) {
                        continue;
                    }
                    //其他网卡（如rmnet0）的MAC，跳过
                    if ("wlan0".equalsIgnoreCase(iF.getName()) || "eth0".equalsIgnoreCase(iF.getName())) {
                        StringBuilder buf = new StringBuilder();
                        for (byte b : addr) {
                            buf.append(String.format("%02X:", b));
                        }
                        if (buf.length() > 0) {
                            buf.deleteCharAt(buf.length() - 1);
                        }
                        String mac = buf.toString();
                        if (mac.length() > 0) {
                            result = mac;
                            return result;
                        }
                    }

                }
            } catch (Exception e) {
                Log.w(TAG, e.toString());
            }

        } else {
            try {
                // MAC地址
                WifiManager wifi = (WifiManager) paramContext.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                if (wifi != null) {
                    WifiInfo wiinfo = wifi.getConnectionInfo();
                    result = wiinfo.getMacAddress();
                }
            } catch (Throwable e) {
                Log.w(TAG, "Failed to get mac Info");
            }
        }
        return result;
    }

    public static int getMemory() {

        Debug.MemoryInfo memoryInfo = new Debug.MemoryInfo();

        Debug.getMemoryInfo(memoryInfo);

// dalvikPrivateClean + nativePrivateClean + otherPrivateClean;

        int totalPrivateClean = memoryInfo.getTotalPrivateClean();

// dalvikPrivateDirty + nativePrivateDirty + otherPrivateDirty;

        int totalPrivateDirty = memoryInfo.getTotalPrivateDirty();

// dalvikPss + nativePss + otherPss;

        int totalPss = memoryInfo.getTotalPss();

// dalvikSharedClean + nativeSharedClean + otherSharedClean;

        int totalSharedClean = memoryInfo.getTotalSharedClean();

// dalvikSharedDirty + nativeSharedDirty + otherSharedDirty;

        int totalSharedDirty = memoryInfo.getTotalSharedDirty();

// dalvikSwappablePss + nativeSwappablePss + otherSwappablePss;

        int totalSwappablePss = memoryInfo.getTotalSwappablePss();

        int total = totalPrivateClean + totalPrivateDirty + totalPss + totalSharedClean + totalSharedDirty + totalSwappablePss;

        return total;

    }
}
