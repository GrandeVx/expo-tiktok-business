package com.craftstudiodev.tiktokbusiness

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.tiktok.appevents.TikTokBusinessSdk
import com.tiktok.appevents.base.EventName
import com.tiktok.appevents.base.TikTokBaseEvent
import com.tiktok.appevents.contents.AddToCartEvent
import com.tiktok.appevents.contents.AddToWishlistEvent
import com.tiktok.appevents.contents.CheckoutEvent
import com.tiktok.appevents.contents.PurchaseEvent
import com.tiktok.appevents.contents.ViewContentEvent
import com.tiktok.appevents.contents.TikTokContentParams
import com.tiktok.appevents.TikTokAdRevenueEvent
import org.json.JSONObject
import org.json.JSONArray

class RNTikTokBusinessModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String = NAME

  // MARK: - Initialize SDK

  @ReactMethod
  fun initializeSdk(
    appId: String,
    tiktokAppId: String,
    accessToken: String,
    debug: Boolean,
    promise: Promise
  ) {
    try {
      val activity = currentActivity ?: run {
        promise.reject("NO_ACTIVITY", "Current activity is null")
        return
      }

      val appIds = tiktokAppId.split(",").map { it.trim() }
      val primaryAppId = appIds.first()

      val config = TikTokBusinessSdk.TTConfig(activity.application)
        .setAppId(appId)
        .setTTAppId(primaryAppId)
        .setAccessToken(accessToken)

      if (debug) {
        config.openDebugMode()
      }

      // Add additional TikTok App IDs
      for (id in appIds.drop(1)) {
        config.addTTAppId(id)
      }

      TikTokBusinessSdk.initializeSdk(config, object : TikTokBusinessSdk.TTInitCallback {
        override fun success() {
          TikTokBusinessSdk.startTrack()
          promise.resolve("TikTok SDK initialized successfully")
        }

        override fun fail(code: Int, msg: String?) {
          promise.reject("INIT_ERROR", "Failed to initialize TikTok SDK: $msg (code: $code)")
        }
      })
    } catch (e: Exception) {
      promise.reject("INIT_ERROR", "Failed to initialize TikTok SDK: ${e.message}", e)
    }
  }

  // MARK: - Identify

  @ReactMethod
  fun identify(
    externalId: String,
    externalUserName: String,
    phoneNumber: String,
    email: String,
    promise: Promise
  ) {
    try {
      TikTokBusinessSdk.identify(
        externalId,
        externalUserName.ifEmpty { null },
        phoneNumber.ifEmpty { null },
        email.ifEmpty { null }
      )
      promise.resolve("User identified successfully")
    } catch (e: Exception) {
      promise.reject("IDENTIFY_ERROR", "Failed to identify user: ${e.message}", e)
    }
  }

  // MARK: - Logout

  @ReactMethod
  fun logout(promise: Promise) {
    try {
      TikTokBusinessSdk.logout()
      promise.resolve("User logged out successfully")
    } catch (e: Exception) {
      promise.reject("LOGOUT_ERROR", "Failed to logout: ${e.message}", e)
    }
  }

  // MARK: - Flush

  @ReactMethod
  fun flush(promise: Promise) {
    try {
      TikTokBusinessSdk.flush()
      promise.resolve("Events flushed successfully")
    } catch (e: Exception) {
      promise.reject("FLUSH_ERROR", "Failed to flush events: ${e.message}", e)
    }
  }

  // MARK: - Track Event

  @ReactMethod
  fun trackEvent(
    eventName: String,
    eventId: String,
    properties: String,
    promise: Promise
  ) {
    try {
      val props = PropertiesHelper.parse(properties)
      val mappedEventName = EventNameMapper.map(eventName)
      val event = TikTokBaseEvent(mappedEventName)

      if (eventId.isNotEmpty()) {
        event.setEventId(eventId)
      }

      PropertiesHelper.addProperties(props, event)
      TikTokBusinessSdk.trackEvent(event)
      promise.resolve("Event tracked: $eventName")
    } catch (e: Exception) {
      promise.reject("TRACK_ERROR", "Failed to track event: ${e.message}", e)
    }
  }

  // MARK: - Track Content Event

  @ReactMethod
  fun trackContentEvent(
    eventType: String,
    properties: String,
    promise: Promise
  ) {
    try {
      val props = PropertiesHelper.parse(properties)
      val event = ContentEventFactory.create(eventType)
        ?: throw IllegalArgumentException("Unknown content event type: $eventType")

      ContentEventFactory.applyProperties(props, event)
      ContentEventFactory.applyContents(props, event)
      TikTokBusinessSdk.trackEvent(event)
      promise.resolve("Content event tracked: $eventType")
    } catch (e: Exception) {
      promise.reject("TRACK_ERROR", "Failed to track content event: ${e.message}", e)
    }
  }

  // MARK: - Track Custom Event

  @ReactMethod
  fun trackCustomEvent(
    eventName: String,
    properties: String,
    promise: Promise
  ) {
    try {
      val props = PropertiesHelper.parse(properties)
      val event = TikTokBaseEvent(eventName)
      PropertiesHelper.addProperties(props, event)
      TikTokBusinessSdk.trackEvent(event)
      promise.resolve("Custom event tracked: $eventName")
    } catch (e: Exception) {
      promise.reject("TRACK_ERROR", "Failed to track custom event: ${e.message}", e)
    }
  }

  // MARK: - Track Ad Revenue Event

  @ReactMethod
  fun trackAdRevenueEvent(
    adRevenueJson: String,
    eventId: String,
    promise: Promise
  ) {
    try {
      val props = PropertiesHelper.parse(adRevenueJson)
      val event = TikTokAdRevenueEvent()

      if (eventId.isNotEmpty()) {
        event.setEventId(eventId)
      }

      PropertiesHelper.addProperties(props, event)
      TikTokBusinessSdk.trackEvent(event)
      promise.resolve("Ad revenue event tracked")
    } catch (e: Exception) {
      promise.reject("TRACK_ERROR", "Failed to track ad revenue event: ${e.message}", e)
    }
  }

  companion object {
    const val NAME = "RNTikTokBusiness"
  }
}

// MARK: - Event Name Mapper

private object EventNameMapper {
  private val mapping = mapOf(
    "AchieveLevel" to EventName.ACHIEVE_LEVEL,
    "AddPaymentInfo" to EventName.ADD_PAYMENT_INFO,
    "CompleteTutorial" to EventName.COMPLETE_TUTORIAL,
    "CreateGroup" to EventName.CREATE_GROUP,
    "CreateRole" to EventName.CREATE_ROLE,
    "GenerateLead" to EventName.GENERATE_LEAD,
    "InAppADClick" to EventName.IN_APP_AD_CLICK,
    "InAppADImpr" to EventName.IN_APP_AD_IMPR,
    "InstallApp" to EventName.INSTALL_APP,
    "JoinGroup" to EventName.JOIN_GROUP,
    "LaunchAPP" to EventName.LAUNCH_APP,
    "Login" to EventName.LOGIN,
    "Rate" to EventName.RATE,
    "Registration" to EventName.REGISTRATION,
    "Search" to EventName.SEARCH,
    "SpendCredits" to EventName.SPEND_CREDITS,
    "StartTrial" to EventName.START_TRIAL,
    "Subscribe" to EventName.SUBSCRIBE,
    "UnlockAchievement" to EventName.UNLOCK_ACHIEVEMENT,
  )

  fun map(eventName: String): EventName {
    return mapping[eventName]
      ?: throw IllegalArgumentException("Unknown event name: $eventName")
  }
}

// MARK: - Properties Helper

private object PropertiesHelper {
  private val contentKeys = setOf(
    "contents", "content_type", "content_id",
    "description", "currency", "value", "order_id"
  )

  fun parse(jsonString: String): JSONObject {
    return JSONObject(jsonString)
  }

  fun addProperties(props: JSONObject, event: TikTokBaseEvent) {
    val keys = props.keys()
    while (keys.hasNext()) {
      val key = keys.next()
      if (key in contentKeys) continue
      val value = props.get(key)
      event.addProperty(key, value)
    }
  }
}

// MARK: - Content Event Factory

private object ContentEventFactory {
  fun create(eventType: String): TikTokBaseEvent? {
    return when (eventType) {
      "AddToCart" -> AddToCartEvent()
      "AddToWishlist" -> AddToWishlistEvent()
      "Checkout" -> CheckoutEvent()
      "Purchase" -> PurchaseEvent()
      "ViewContent" -> ViewContentEvent()
      else -> null
    }
  }

  fun applyProperties(props: JSONObject, event: TikTokBaseEvent) {
    if (props.has("content_type")) event.addProperty("content_type", props.getString("content_type"))
    if (props.has("content_id")) event.addProperty("content_id", props.getString("content_id"))
    if (props.has("description")) event.addProperty("description", props.getString("description"))
    if (props.has("currency")) event.addProperty("currency", props.getString("currency"))
    if (props.has("value")) event.addProperty("value", props.getDouble("value"))
    if (props.has("order_id")) event.addProperty("order_id", props.getString("order_id"))
  }

  fun applyContents(props: JSONObject, event: TikTokBaseEvent) {
    if (!props.has("contents")) return

    val contentsArray: JSONArray = props.getJSONArray("contents")
    for (i in 0 until contentsArray.length()) {
      val item = contentsArray.getJSONObject(i)
      val contentParams = TikTokContentParams()

      if (item.has("content_id")) contentParams.contentId = item.getString("content_id")
      if (item.has("content_name")) contentParams.contentName = item.getString("content_name")
      if (item.has("content_category")) contentParams.contentCategory = item.getString("content_category")
      if (item.has("brand")) contentParams.brand = item.getString("brand")
      if (item.has("price")) contentParams.price = item.getDouble("price")
      if (item.has("quantity")) contentParams.quantity = item.getInt("quantity")

      event.addContents(contentParams)
    }
  }
}
