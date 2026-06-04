package com.jworks.kanjijourney.android

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.jworks.kanjijourney.android.service.ForceUpgradeChecker
import com.jworks.kanjijourney.android.service.UpgradeCheckState
import com.jworks.kanjijourney.android.ui.forceupgrade.ForceUpgradeScreen
import com.jworks.kanjijourney.android.ui.navigation.KanjiJourneyNavHost
import com.jworks.kanjijourney.android.ui.theme.KanjiJourneyTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val deepLinkUri = mutableStateOf<Uri?>(null)
    private var upgradeState by mutableStateOf<UpgradeCheckState>(UpgradeCheckState.Checking)

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        splashScreen.setKeepOnScreenCondition { upgradeState is UpgradeCheckState.Checking }
        super.onCreate(savedInstanceState)
        handleDeepLink(intent)
        enableEdgeToEdge()
        setContent {
            KanjiJourneyTheme {
                LaunchedEffect(Unit) {
                    upgradeState = ForceUpgradeChecker.check(BuildConfig.VERSION_NAME)
                }

                when (val state = upgradeState) {
                    is UpgradeCheckState.Checking -> {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.Black)
                        )
                    }
                    is UpgradeCheckState.UpdateRequired -> {
                        ForceUpgradeScreen(
                            message = state.message,
                            storeUrl = state.storeUrl
                        )
                    }
                    is UpgradeCheckState.UpToDate -> {
                        KanjiJourneyNavHost(
                            deepLinkUri = deepLinkUri.value,
                            onDeepLinkConsumed = { deepLinkUri.value = null }
                        )
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        if (uri.scheme == "kanjijourney") {
            deepLinkUri.value = uri
        }
    }
}
