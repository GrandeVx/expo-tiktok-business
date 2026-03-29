"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const config_plugins_1 = require("@expo/config-plugins");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const withTikTokBusiness = (config, props) => {
    const { trackingDescription = 'We use this to measure ad performance and show you relevant ads.', addProguardRules = true, } = props !== null && props !== void 0 ? props : {};
    // iOS: Add ATT usage description
    config = (0, config_plugins_1.withInfoPlist)(config, (config) => {
        config.modResults.NSUserTrackingUsageDescription = trackingDescription;
        return config;
    });
    // Android: Add ProGuard rules
    if (addProguardRules) {
        config = (0, config_plugins_1.withDangerousMod)(config, [
            'android',
            (config) => {
                const proguardFile = path.join(config.modRequest.platformProjectRoot, 'app', 'proguard-rules.pro');
                const rules = `
# TikTok Business SDK
-keep class com.tiktok.** { *; }
-keep class com.bytedance.** { *; }
`;
                if (fs.existsSync(proguardFile)) {
                    const existing = fs.readFileSync(proguardFile, 'utf8');
                    if (!existing.includes('com.tiktok.**')) {
                        fs.appendFileSync(proguardFile, rules);
                    }
                }
                else {
                    fs.writeFileSync(proguardFile, rules);
                }
                return config;
            },
        ]);
    }
    return config;
};
exports.default = withTikTokBusiness;
