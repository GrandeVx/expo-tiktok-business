import { ConfigPlugin, withInfoPlist, withAndroidManifest, withDangerousMod } from '@expo/config-plugins';
import * as fs from 'fs';
import * as path from 'path';

interface TikTokPluginProps {
  trackingDescription?: string;
  addProguardRules?: boolean;
}

const withTikTokBusiness: ConfigPlugin<TikTokPluginProps | void> = (config, props) => {
  const {
    trackingDescription = 'We use this to measure ad performance and show you relevant ads.',
    addProguardRules = true,
  } = props ?? {};

  // iOS: Add ATT usage description
  config = withInfoPlist(config, (config) => {
    config.modResults.NSUserTrackingUsageDescription = trackingDescription;
    return config;
  });

  // iOS: Add modular_headers for TikTokBusinessSDK in Podfile
  config = withDangerousMod(config, [
    'ios',
    (config) => {
      const podfilePath = path.join(
        config.modRequest.platformProjectRoot,
        'Podfile'
      );

      if (fs.existsSync(podfilePath)) {
        let podfileContent = fs.readFileSync(podfilePath, 'utf8');
        const modularHeadersLine = "pod 'TikTokBusinessSDK', :modular_headers => true";
        if (!podfileContent.includes(modularHeadersLine)) {
          // Insert after "use_react_native!" or at the end of the target block
          podfileContent = podfileContent.replace(
            /use_react_native!\([^)]*\)/,
            (match) => `${match}\n    ${modularHeadersLine}`
          );
          fs.writeFileSync(podfilePath, podfileContent);
        }
      }

      return config;
    },
  ]);

  // Android: Add ProGuard rules
  if (addProguardRules) {
    config = withDangerousMod(config, [
      'android',
      (config) => {
        const proguardFile = path.join(
          config.modRequest.platformProjectRoot,
          'app',
          'proguard-rules.pro'
        );

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
        } else {
          fs.writeFileSync(proguardFile, rules);
        }

        return config;
      },
    ]);
  }

  return config;
};

export default withTikTokBusiness;
