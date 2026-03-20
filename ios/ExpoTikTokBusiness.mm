#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ExpoTikTokBusiness, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)appId
                  tiktokAppId:(NSString *)tiktokAppId
                  accessToken:(NSString *)accessToken
                  debug:(BOOL)debug
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trackEvent:(NSString *)eventName
                  params:(NSString *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(identify:(NSString *)externalId
                  externalUserName:(NSString *)externalUserName
                  phoneNumber:(NSString *)phoneNumber
                  email:(NSString *)email)

RCT_EXTERN_METHOD(logout)

RCT_EXTERN_METHOD(setTrackingEnabled:(BOOL)enabled)

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

@end
