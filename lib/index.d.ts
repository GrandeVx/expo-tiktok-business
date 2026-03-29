import type { TikTokConfig, TikTokIdentity, TikTokEventParams } from './types';
import { TikTokEventName } from './types';
export { TikTokEventName };
export type { TikTokConfig, TikTokIdentity, TikTokEventParams };
declare class TikTokBusiness {
    private static instance;
    private initialized;
    private constructor();
    static getInstance(): TikTokBusiness;
    initialize(config: TikTokConfig): Promise<void>;
    trackEvent(eventName: TikTokEventName | string, params?: TikTokEventParams): Promise<void>;
    identify(identity: TikTokIdentity): void;
    logout(): void;
    setTrackingEnabled(enabled: boolean): void;
    isInitialized(): boolean;
}
export { TikTokBusiness };
export default TikTokBusiness;
//# sourceMappingURL=index.d.ts.map