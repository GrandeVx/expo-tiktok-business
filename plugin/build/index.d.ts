import { ConfigPlugin } from '@expo/config-plugins';
interface TikTokPluginProps {
    trackingDescription?: string;
    addProguardRules?: boolean;
}
declare const withTikTokBusiness: ConfigPlugin<TikTokPluginProps | void>;
export default withTikTokBusiness;
