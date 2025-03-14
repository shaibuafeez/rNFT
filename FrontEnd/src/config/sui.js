import { getFullnodeUrl, SuiClient } from '@mysten/sui.js/client'; 

// ===== Define Network RPC URLs =====
const devnetRpcUrl = getFullnodeUrl('devnet');
const mainnetRpcUrl = getFullnodeUrl('mainnet');

// ===== Connect =====
export const providerSuiTestnet = () => {
    const client = new SuiClient({ url: devnetRpcUrl }); 
    return client;
}
export const providerSuiMainnet = () => {
    const client = new SuiClient({ url: mainnetRpcUrl }); 
    return client;
}

// Default provider - set to mainnet
export const defaultProvider = () => {
    return providerSuiMainnet();
}