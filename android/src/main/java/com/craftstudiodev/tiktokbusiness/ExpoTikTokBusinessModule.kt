package com.craftstudiodev.tiktokbusiness

import com.facebook.react.bridge.*
import com.tiktok.appevents.TikTokBusinessSdk
import com.tiktok.appevents.base.EventName
import org.json.JSONObject

class ExpoTikTokBusinessModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = "ExpoTikTokBusiness"

    @ReactMethod
    fun initialize(
        appId: String,
        tiktokAppId: String,
        accessToken: String,
        debug: Boolean,
        promise: Promise
    ) {
        try {
            val activity = currentActivity
            if (activity == null) {
                promise.reject("INIT_ERROR", "Activity is null")
                return
            }

            val config = TikTokBusinessSdk.TTConfig(activity.application)
                .setAppId(tiktokAppId)
                .setAccessToken(accessToken)

            if (debug) {
                config.openDebugMode()
            }

            TikTokBusinessSdk.initializeSdk(config)
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("INIT_ERROR", e.message, e)
        }
    }

    @ReactMethod
    fun trackEvent(eventName: String, params: String, promise: Promise) {
        try {
            val props = JSONObject(params)
            TikTokBusinessSdk.trackEvent(eventName, props)
            promise.resolve(null)
        } catch (e: Exception) {
            TikTokBusinessSdk.trackEvent(eventName)
            promise.resolve(null)
        }
    }

    @ReactMethod
    fun identify(
        externalId: String,
        externalUserName: String,
        phoneNumber: String,
        email: String
    ) {
        TikTokBusinessSdk.identify(
            if (externalId.isEmpty()) null else externalId,
            if (phoneNumber.isEmpty()) null else phoneNumber,
            if (email.isEmpty()) null else email
        )
    }

    @ReactMethod
    fun logout() {
        TikTokBusinessSdk.logout()
    }

    @ReactMethod
    fun setTrackingEnabled(enabled: Boolean) {
        TikTokBusinessSdk.setTrackingEnabled(enabled)
    }

}
