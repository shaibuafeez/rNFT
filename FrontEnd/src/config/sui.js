import { getFullnodeUrl, SuiClient } from '@mysten/sui.js/client'; 

// ===== Define Devnet RPC =====
const rpcUrl = getFullnodeUrl('devnet'); 

// ===== Connect =====
export const providerSuiTestnet = () => {
    const client = new SuiClient({ url: rpcUrl }); 
    return client;
}
export const providerSuiMainnet = () => {
    const client = new SuiClient({ url: rpcUrl }); 
    return client;
}