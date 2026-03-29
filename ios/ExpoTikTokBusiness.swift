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
            let config = TikTokConfig(appId: tiktokAppId, tiktokAppId: tiktokAppId)
            config?.setAccessToken(accessToken)
            
            if debug {
                config?.setLogLevel(.debug)
            }
            
            if let config = config {
                TikTokBusiness.initializeSdk(config)
                resolve(nil)
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
        guard let data = params.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let event = TikTokBaseEvent(eventName: eventName)
            TikTokBusiness.trackEvent(event)
            resolve(nil)
            return
        }
        
        let event = TikTokBaseEvent(eventName: eventName)
        for (key, value) in dict {
            event.addProperty(withKey: key, value: String(describing: value))
        }
        TikTokBusiness.trackEvent(event)
        resolve(nil)
    }
    
    @objc
    func identify(_ externalId: String,
                   externalUserName: String,
                   phoneNumber: String,
                   email: String) {
        TikTokBusiness.identify(withExternalID: externalId.isEmpty ? nil : externalId,
                                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                                email: email.isEmpty ? nil : email)
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
