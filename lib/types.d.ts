export interface TikTokConfig {
    appId: string;
    tiktokAppId: string;
    accessToken: string;
    debug?: boolean;
}
export interface TikTokIdentity {
    externalId?: string;
    externalUserName?: string;
    phoneNumber?: string;
    email?: string;
}
export type TikTokEventParams = Record<string, string | number | boolean>;
export declare enum TikTokEventName {
    ADD_TO_CART = "AddToCart",
    ADD_TO_WISHLIST = "AddToWishlist",
    CHECKOUT = "Checkout",
    PURCHASE = "Purchase",
    VIEW_CONTENT = "ViewContent",
    LAUNCH_APP = "LaunchAPP",
    INSTALL_APP = "InstallApp",
    COMPLETE_REGISTRATION = "CompleteRegistration",
    ADD_PAYMENT_INFO = "AddPaymentInfo",
    COMPLETE_TUTORIAL = "CompleteTutorial",
    ACHIEVE_LEVEL = "AchieveLevel",
    CREATE_GROUP = "CreateGroup",
    CREATE_ROLE = "CreateRole",
    GENERATE_LEAD = "GenerateLead",
    IN_APP_AD_CLICK = "InAppADClick",
    IN_APP_AD_IMPRESSION = "InAppADImpr",
    JOIN_GROUP = "JoinGroup",
    LOGIN = "Login",
    RATE = "Rate",
    SEARCH = "Search",
    SPEND_CREDITS = "SpendCredits",
    START_TRIAL = "StartTrial",
    SUBSCRIBE = "Subscribe",
    UNLOCK_ACHIEVEMENT = "UnlockAchievement"
}
//# sourceMappingURL=types.d.ts.map