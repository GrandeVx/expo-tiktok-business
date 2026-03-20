import NativeExpoTikTokBusiness from './NativeExpoTikTokBusiness';
import type { TikTokConfig, TikTokIdentity, TikTokEventParams } from './types';
import { TikTokEventName } from './types';

export { TikTokEventName };
export type { TikTokConfig, TikTokIdentity, TikTokEventParams };

class TikTokBusiness {
  private static instance: TikTokBusiness;
  private initialized = false;

  private constructor() {}

  static getInstance(): TikTokBusiness {
    if (!TikTokBusiness.instance) {
      TikTokBusiness.instance = new TikTokBusiness();
    }
    return TikTokBusiness.instance;
  }

  async initialize(config: TikTokConfig): Promise<void> {
    if (this.initialized) {
      console.warn('[TikTokBusiness] Already initialized');
      return;
    }

    await NativeExpoTikTokBusiness.initialize(
      config.appId,
      config.tiktokAppId,
      config.accessToken,
      config.debug ?? false,
    );

    this.initialized = true;
  }

  async trackEvent(eventName: TikTokEventName | string, params?: TikTokEventParams): Promise<void> {
    if (!this.initialized) {
      console.warn('[TikTokBusiness] Not initialized. Call initialize() first.');
      return;
    }

    await NativeExpoTikTokBusiness.trackEvent(
      eventName,
      JSON.stringify(params ?? {}),
    );
  }

  identify(identity: TikTokIdentity): void {
    if (!this.initialized) {
      console.warn('[TikTokBusiness] Not initialized. Call initialize() first.');
      return;
    }

    NativeExpoTikTokBusiness.identify(
      identity.externalId ?? '',
      identity.externalUserName ?? '',
      identity.phoneNumber ?? '',
      identity.email ?? '',
    );
  }

  logout(): void {
    if (!this.initialized) return;
    NativeExpoTikTokBusiness.logout();
  }

  setTrackingEnabled(enabled: boolean): void {
    NativeExpoTikTokBusiness.setTrackingEnabled(enabled);
  }

  isInitialized(): boolean {
    return this.initialized;
  }
}

export { TikTokBusiness };
export default TikTokBusiness;
