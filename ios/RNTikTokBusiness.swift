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
      config?.setAccessToken(accessToken)

      if debug {
        config?.enableDebugMode()
      }

      // Support multiple TikTok App IDs (comma-separated)
      let appIds = tiktokAppId.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
      if appIds.count > 1 {
        for id in appIds.dropFirst() {
          config?.addTikTokAppId(id)
        }
      }

      TikTokBusiness.initializeSdk(config) { success, error in
        if success {
          resolve("TikTok SDK initialized successfully")
        } else {
          reject("INIT_ERROR", "Failed to initialize TikTok SDK: \(error?.localizedDescription ?? "Unknown error")", error)
        }
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
    guard let props = JSONHelper.parse(properties) else {
      reject("PARSE_ERROR", "Failed to parse event properties", nil)
      return
    }

    let event = TikTokBaseEvent(eventName: eventName)
    if !eventId.isEmpty {
      event.setEventId(eventId)
    }
    JSONHelper.addProperties(props, to: event)
    TikTokBusiness.trackEvent(event)
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
    guard let props = JSONHelper.parse(properties) else {
      reject("PARSE_ERROR", "Failed to parse content event properties", nil)
      return
    }

    guard let event = ContentEventFactory.create(eventType: eventType) else {
      reject("INVALID_EVENT", "Unknown content event type: \(eventType)", nil)
      return
    }

    ContentEventFactory.applyProperties(props, to: event)
    ContentEventFactory.applyContents(props, to: event)
    TikTokBusiness.trackEvent(event)
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
    guard let props = JSONHelper.parse(properties) else {
      reject("PARSE_ERROR", "Failed to parse custom event properties", nil)
      return
    }

    let event = TikTokBaseEvent(eventName: eventName)
    JSONHelper.addProperties(props, to: event)
    TikTokBusiness.trackEvent(event)
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
    guard let props = JSONHelper.parse(adRevenueJson) else {
      reject("PARSE_ERROR", "Failed to parse ad revenue data", nil)
      return
    }

    let event = TikTokAdRevenueEvent()
    if !eventId.isEmpty {
      event.setEventId(eventId)
    }
    JSONHelper.addProperties(props, to: event)
    TikTokBusiness.trackEvent(event)
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
      if key == "contents" || key == "content_type" || key == "content_id" ||
         key == "description" || key == "currency" || key == "value" || key == "order_id" {
        continue
      }
      event.addProperty(withKey: key, value: value)
    }
  }
}

// MARK: - Content Event Factory

private enum ContentEventFactory {
  static func create(eventType: String) -> TikTokBaseEvent? {
    switch eventType {
    case "AddToCart":
      return TikTokAddToCartEvent()
    case "AddToWishlist":
      return TikTokAddToWishlistEvent()
    case "Checkout":
      return TikTokCheckoutEvent()
    case "Purchase":
      return TikTokPurchaseEvent()
    case "ViewContent":
      return TikTokViewContentEvent()
    default:
      return nil
    }
  }

  static func applyProperties(_ properties: [String: Any], to event: TikTokBaseEvent) {
    if let contentType = properties["content_type"] as? String {
      event.addProperty(withKey: "content_type", value: contentType)
    }
    if let contentId = properties["content_id"] as? String {
      event.addProperty(withKey: "content_id", value: contentId)
    }
    if let description = properties["description"] as? String {
      event.addProperty(withKey: "description", value: description)
    }
    if let currency = properties["currency"] as? String {
      event.addProperty(withKey: "currency", value: currency)
    }
    if let value = properties["value"] as? NSNumber {
      event.addProperty(withKey: "value", value: value)
    }
    if let orderId = properties["order_id"] as? String {
      event.addProperty(withKey: "order_id", value: orderId)
    }
  }

  static func applyContents(_ properties: [String: Any], to event: TikTokBaseEvent) {
    guard let contentsArray = properties["contents"] as? [[String: Any]] else { return }

    for item in contentsArray {
      let contentParams = TikTokContentParams()
      if let contentId = item["content_id"] as? String {
        contentParams.contentId = contentId
      }
      if let contentName = item["content_name"] as? String {
        contentParams.contentName = contentName
      }
      if let contentCategory = item["content_category"] as? String {
        contentParams.contentCategory = contentCategory
      }
      if let brand = item["brand"] as? String {
        contentParams.brand = brand
      }
      if let price = item["price"] as? NSNumber {
        contentParams.price = price
      }
      if let quantity = item["quantity"] as? NSNumber {
        contentParams.quantity = quantity
      }
      event.addContents(contentParams)
    }
  }
}
