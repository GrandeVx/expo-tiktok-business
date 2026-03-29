"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TikTokBusiness = exports.TikTokEventName = void 0;
const NativeExpoTikTokBusiness_1 = __importDefault(require("./NativeExpoTikTokBusiness"));
const types_1 = require("./types");
Object.defineProperty(exports, "TikTokEventName", { enumerable: true, get: function () { return types_1.TikTokEventName; } });
class TikTokBusiness {
    static instance;
    initialized = false;
    constructor() { }
    static getInstance() {
        if (!TikTokBusiness.instance) {
            TikTokBusiness.instance = new TikTokBusiness();
        }
        return TikTokBusiness.instance;
    }
    async initialize(config) {
        if (this.initialized) {
            console.warn('[TikTokBusiness] Already initialized');
            return;
        }
        await NativeExpoTikTokBusiness_1.default.initialize(config.appId, config.tiktokAppId, config.accessToken, config.debug ?? false);
        this.initialized = true;
    }
    async trackEvent(eventName, params) {
        if (!this.initialized) {
            console.warn('[TikTokBusiness] Not initialized. Call initialize() first.');
            return;
        }
        await NativeExpoTikTokBusiness_1.default.trackEvent(eventName, JSON.stringify(params ?? {}));
    }
    identify(identity) {
        if (!this.initialized) {
            console.warn('[TikTokBusiness] Not initialized. Call initialize() first.');
            return;
        }
        NativeExpoTikTokBusiness_1.default.identify(identity.externalId ?? '', identity.externalUserName ?? '', identity.phoneNumber ?? '', identity.email ?? '');
    }
    logout() {
        if (!this.initialized)
            return;
        NativeExpoTikTokBusiness_1.default.logout();
    }
    setTrackingEnabled(enabled) {
        NativeExpoTikTokBusiness_1.default.setTrackingEnabled(enabled);
    }
    isInitialized() {
        return this.initialized;
    }
}
exports.TikTokBusiness = TikTokBusiness;
exports.default = TikTokBusiness;
//# sourceMappingURL=index.js.map