import type { TurboModule } from 'react-native';
export interface Spec extends TurboModule {
    initialize(appId: string, tiktokAppId: string, accessToken: string, debug: boolean): Promise<void>;
    trackEvent(eventName: string, params: string): Promise<void>;
    identify(externalId: string, externalUserName: string, phoneNumber: string, email: string): void;
    logout(): void;
    setTrackingEnabled(enabled: boolean): void;
}
declare const _default: Spec;
export default _default;
//# sourceMappingURL=NativeExpoTikTokBusiness.d.ts.map