import Foundation
import React
import TikTokBusinessSDK

@objc(ExpoTikTokBusiness)
class ExpoTikTokBusiness: NSObject {

    @objc
    func initialize(_ appId: String,
                     tiktokAppId: String,
                     accessToken: String,
                     debug: Bool,
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let config = TikTokConfig(appId: appId, tiktokAppId: tiktokAppId)

            if debug {
                config?.enableDebugMode()
            }

            if let config = config {
                TikTokBusiness.initializeSdk(config)
                resolve("TikTok SDK initialized")
            } else {
                reject("INIT_ERROR", "Failed to create TikTok config", nil)
            }
        }
    }

    @objc
    func trackEvent(_ eventName: String,
                     params: String,
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        let event = TikTokBaseEvent(eventName: eventName)

        if let data = params.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for (key, value) in dict {
                event.addProperty(withKey: key, value: value)
            }
        }

        TikTokBusiness.trackEvent(event)
        resolve("Event tracked: \(eventName)")
    }

    @objc
    func identify(_ externalId: String,
                   externalUserName: String,
                   phoneNumber: String,
                   email: String) {
        TikTokBusiness.identify(
            withExternalID: externalId.isEmpty ? nil : externalId,
            externalUserName: externalUserName.isEmpty ? nil : externalUserName,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            email: email.isEmpty ? nil : email
        )
    }

    @objc
    func logout() {
        TikTokBusiness.logout()
    }

    @objc
    func setTrackingEnabled(_ enabled: Bool) {
        TikTokBusiness.setTrackingEnabled(enabled)
    }
}
