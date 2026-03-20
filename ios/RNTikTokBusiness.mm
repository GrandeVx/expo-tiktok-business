#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNTikTokBusiness, NSObject)

RCT_EXTERN_METHOD(initializeSdk:(NSString *)appId
                  tiktokAppId:(NSString *)tiktokAppId
                  accessToken:(NSString *)accessToken
                  debug:(BOOL)debug
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(identify:(NSString *)externalId
                  externalUserName:(NSString *)externalUserName
                  phoneNumber:(NSString *)phoneNumber
                  email:(NSString *)email
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(logout:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(flush:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trackEvent:(NSString *)eventName
                  eventId:(NSString *)eventId
                  properties:(NSString *)properties
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trackContentEvent:(NSString *)eventType
                  properties:(NSString *)properties
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trackCustomEvent:(NSString *)eventName
                  properties:(NSString *)properties
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(trackAdRevenueEvent:(NSString *)adRevenueJson
                  eventId:(NSString *)eventId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
