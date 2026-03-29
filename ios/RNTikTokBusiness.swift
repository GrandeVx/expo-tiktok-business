import Foundation
import React
import TikTokBusinessSDK

@objc(RNTikTokBusiness)
final class RNTikTokBusiness: NSObject {

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }

  // MARK: - Initialize SDK

  @objc
  func initializeSdk(
    _ appId: String,
    tiktokAppId: String,
    accessToken: String,
    debug: Bool,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      let config = TikTokConfig(appId: appId, tiktokAppId: tiktokAppId)

      if debug {
        config?.enableDebugMode()
      }

      if let config = config {
        TikTokBusiness.initializeSdk(config)
        resolve("TikTok SDK initialized successfully")
      } else {
        reject("INIT_ERROR", "Failed to create TikTok config", nil)
      }
    }
  }

  // MARK: - Identify

  @objc
  func identify(
    _ externalId: String,
    externalUserName: String,
    phoneNumber: String,
    email: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    TikTokBusiness.identify(
      withExternalID: externalId,
      externalUserName: externalUserName.isEmpty ? nil : externalUserName,
      phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
      email: email.isEmpty ? nil : email
    )
    resolve("User identified successfully")
  }

  // MARK: - Logout

  @objc
  func logout(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    TikTokBusiness.logout()
    resolve("User logged out successfully")
  }

  // MARK: - Flush

  @objc
  func flush(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    TikTokBusiness.explicitlyFlush()
    resolve("Events flushed successfully")
  }

  // MARK: - Track Event

  @objc
  func trackEvent(
    _ eventName: String,
    eventId: String,
    properties: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let event = TikTokBaseEvent(eventName: eventName)

    if let props = JSONHelper.parse(properties) {
      JSONHelper.addProperties(props, to: event)
    }

    TikTokBusiness.trackTTEvent(event)
    resolve("Event tracked: \(eventName)")
  }

  // MARK: - Track Content Event

  @objc
  func trackContentEvent(
    _ eventType: String,
    properties: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let event = TikTokBaseEvent(eventName: eventType)

    if let props = JSONHelper.parse(properties) {
      JSONHelper.addProperties(props, to: event)
    }

    TikTokBusiness.trackTTEvent(event)
    resolve("Content event tracked: \(eventType)")
  }

  // MARK: - Track Custom Event

  @objc
  func trackCustomEvent(
    _ eventName: String,
    properties: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let event = TikTokBaseEvent(eventName: eventName)

    if let props = JSONHelper.parse(properties) {
      JSONHelper.addProperties(props, to: event)
    }

    TikTokBusiness.trackTTEvent(event)
    resolve("Custom event tracked: \(eventName)")
  }

  // MARK: - Track Ad Revenue Event

  @objc
  func trackAdRevenueEvent(
    _ adRevenueJson: String,
    eventId: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let event = TikTokBaseEvent(eventName: "ImpressionLevelAdRevenue")

    if let props = JSONHelper.parse(adRevenueJson) {
      JSONHelper.addProperties(props, to: event)
    }

    TikTokBusiness.trackTTEvent(event)
    resolve("Ad revenue event tracked")
  }
}

// MARK: - JSON Helper

private enum JSONHelper {
  static func parse(_ jsonString: String) -> [String: Any]? {
    guard let data = jsonString.data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  }

  static func addProperties(_ properties: [String: Any], to event: TikTokBaseEvent) {
    for (key, value) in properties {
      event.addProperty(withKey: key, value: value)
    }
  }
}
