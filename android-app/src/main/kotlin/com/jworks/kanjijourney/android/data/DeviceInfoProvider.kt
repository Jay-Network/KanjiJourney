package com.jworks.kanjijourney.android.data

import android.os.Build
import com.jworks.kanjijourney.android.BuildConfig
import com.jworks.kanjijourney.core.data.sync.DeviceInfo

object DeviceInfoProvider {
    fun get(): DeviceInfo = DeviceInfo(
        deviceName = "${Build.MANUFACTURER} ${Build.MODEL}",
        platform = "android",
        appVersion = BuildConfig.VERSION_NAME
    )
}
