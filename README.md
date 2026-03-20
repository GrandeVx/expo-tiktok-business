# @craftstudiodev/expo-tiktok-business

TikTok Business SDK bridge for React Native — built as a **Turbo Module** for the New Architecture, with an **Expo config plugin** for zero-config setup.

> React Native 0.73+ · iOS 13+ · Android API 23+ · Expo SDK 50+

---

## Why this package?

The official TikTok Business SDK only ships native iOS/Android libraries. This package bridges them to React Native using a **Turbo Module** (not the legacy NativeModules bridge), so it works natively with the New Architecture without any interop layer overhead.

- **Turbo Module with Codegen** — type-safe, synchronous-capable native bridge
- **Expo config plugin** — handles ATT permissions, ProGuard rules automatically
- **Singleton pattern** — initialize once, use anywhere
- **Fully typed** — every event name, property, and config is typed

---

## Installation

```bash
# npm
npm install @craftstudiodev/expo-tiktok-business

# yarn
yarn add @craftstudiodev/expo-tiktok-business
```

### Bare React Native (CLI)

```bash
cd ios && pod install
```

**Android**: Add TikTok's Maven repository to your project-level `android/build.gradle`:

```gradle
allprojects {
  repositories {
    maven { url "https://artifact.bytedance.com/repository/pangle" }
  }
}
```

**iOS**: Add `NSUserTrackingUsageDescription` to your `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this to measure ad performance and show you relevant ads.</string>
```

### Expo

Add the plugin to your `app.json`:

```json
{
  "expo": {
    "plugins": [
      ["@craftstudiodev/expo-tiktok-business"]
    ]
  }
}
```

With custom ATT description:

```json
{
  "expo": {
    "plugins": [
      [
        "@craftstudiodev/expo-tiktok-business",
        {
          "trackingDescription": "Your custom tracking permission message."
        }
      ]
    ]
  }
}
```

Then run `npx expo prebuild` to apply the native changes.

---

## Usage

### Initialize

Call this once at app startup (e.g., in your root component or service initializer):

```typescript
import { TikTokBusiness } from '@craftstudiodev/expo-tiktok-business';

const tiktok = TikTokBusiness.getInstance();

await tiktok.initialize({
  appId: 'com.yourcompany.yourapp',
  tiktokAppId: 'YOUR_TIKTOK_APP_ID',
  accessToken: 'YOUR_ACCESS_TOKEN',
  debug: __DEV__,
});
```

### Track events

Use built-in event names for standard events, or pass custom strings:

```typescript
import { TikTokBusiness, TikTokEventName } from '@craftstudiodev/expo-tiktok-business';

const tiktok = TikTokBusiness.getInstance();

// Standard event — no params
await tiktok.trackEvent(TikTokEventName.LAUNCH_APP);

// Standard event — with params
await tiktok.trackEvent(TikTokEventName.PURCHASE, {
  value: 29.99,
  currency: 'USD',
  content_id: 'premium_monthly',
});

// Custom event
await tiktok.trackEvent('button_click', {
  button_name: 'signup',
  screen: 'onboarding',
});
```

### Available standard events

| Event Name | Constant |
|---|---|
| AddToCart | `TikTokEventName.ADD_TO_CART` |
| AddToWishlist | `TikTokEventName.ADD_TO_WISHLIST` |
| Checkout | `TikTokEventName.CHECKOUT` |
| Purchase | `TikTokEventName.PURCHASE` |
| ViewContent | `TikTokEventName.VIEW_CONTENT` |
| LaunchAPP | `TikTokEventName.LAUNCH_APP` |
| InstallApp | `TikTokEventName.INSTALL_APP` |
| CompleteRegistration | `TikTokEventName.COMPLETE_REGISTRATION` |
| AddPaymentInfo | `TikTokEventName.ADD_PAYMENT_INFO` |
| CompleteTutorial | `TikTokEventName.COMPLETE_TUTORIAL` |
| AchieveLevel | `TikTokEventName.ACHIEVE_LEVEL` |
| CreateGroup | `TikTokEventName.CREATE_GROUP` |
| CreateRole | `TikTokEventName.CREATE_ROLE` |
| GenerateLead | `TikTokEventName.GENERATE_LEAD` |
| InAppADClick | `TikTokEventName.IN_APP_AD_CLICK` |
| InAppADImpr | `TikTokEventName.IN_APP_AD_IMPRESSION` |
| JoinGroup | `TikTokEventName.JOIN_GROUP` |
| Login | `TikTokEventName.LOGIN` |
| Rate | `TikTokEventName.RATE` |
| Search | `TikTokEventName.SEARCH` |
| SpendCredits | `TikTokEventName.SPEND_CREDITS` |
| StartTrial | `TikTokEventName.START_TRIAL` |
| Subscribe | `TikTokEventName.SUBSCRIBE` |
| UnlockAchievement | `TikTokEventName.UNLOCK_ACHIEVEMENT` |

### Identify users

```typescript
tiktok.identify({
  externalId: 'user_123',
  email: 'user@example.com',
  phoneNumber: '+1234567890',
});
```

### Logout

```typescript
tiktok.logout();
```

### Enable/disable tracking

ATT (App Tracking Transparency) should be handled at the **app level** — not inside this SDK. Use `expo-tracking-transparency` or your own ATT flow, then pass the result:

```typescript
// After your ATT prompt resolves:
tiktok.setTrackingEnabled(userGrantedTracking); // true or false
```

---

## Full example

```typescript
import { useEffect } from 'react';
import { TikTokBusiness, TikTokEventName } from '@craftstudiodev/expo-tiktok-business';

export default function App() {
  useEffect(() => {
    const init = async () => {
      const tiktok = TikTokBusiness.getInstance();

      // Initialize SDK
      await tiktok.initialize({
        appId: 'com.yourcompany.app',
        tiktokAppId: 'YOUR_TIKTOK_APP_ID',
        accessToken: 'YOUR_ACCESS_TOKEN',
        debug: __DEV__,
      });

      // Track app launch
      await tiktok.trackEvent(TikTokEventName.LAUNCH_APP);
    };

    init();
  }, []);

  return <YourApp />;
}

// Later, anywhere in your app:
async function onPurchase(item: { id: string; price: number }) {
  const tiktok = TikTokBusiness.getInstance();
  await tiktok.trackEvent(TikTokEventName.PURCHASE, {
    content_id: item.id,
    value: item.price,
    currency: 'USD',
  });
}
```

---

## License

MIT
