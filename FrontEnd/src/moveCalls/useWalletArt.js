import { PACKAGE_ID, REGISTRY, NETWORK } from '../config/constants';
import { useWallet } from '@suiet/wallet-kit';
import { TransactionBlock } from '@mysten/sui.js/transactions';

/**
 * Hook to create a transaction for minting an NFT
 * @returns A function to execute a mint NFT transaction.
 */
export function useMintNFT() {
    const wallet = useWallet();

    const mintNFT = async () => {
        if (!wallet.connected || !wallet.account) {
            console.error('Wallet not connected');
            return;
        }

        try {
            console.log("Starting transaction creation");
            console.log("Package ID:", PACKAGE_ID);
            console.log("Registry:", REGISTRY);
            console.log("Network:", NETWORK);
            
            // Create a new transaction block using the Sui SDK
            const tx = new TransactionBlock();
            
            // Get the current network from the wallet or use the configured network
            const network = wallet.chain?.name || NETWORK;
            console.log("Current network:", network);
            
            // Define the Random object properly as a shared object
            // The Random object is a system object with a well-known ID
            const randomObjectId = "0x0000000000000000000000000000000000000000000000000000000000000008";
            console.log("Using Random object ID:", randomObjectId);
            
            // Add the moveCall to the transaction block with the correct arguments
            tx.moveCall({
                target: `${PACKAGE_ID}::main::mint_optimized`,
                arguments: [
                    tx.object(REGISTRY)
                ],
            });
            
            // Set gas budget
            tx.setGasBudget(1000000000); // 1 SUI for gas budget (typical transaction uses 0.7-0.8 SUI)
            
            console.log("Executing transaction...");
            console.log("Transaction details:", tx);
            
            // Execute the transaction using the wallet
            const result = await wallet.signAndExecuteTransactionBlock({
                transactionBlock: tx,
                options: {
                    showEffects: true,
                    showEvents: true
                }
            });
            
            console.log("Transaction result:", result);
            
            if (result && result.digest) {
                console.log('Transaction successful:', `https://explorer.sui.io/txblock/${result.digest}?network=${network}`);
                alert('NFT minted successfully! Transaction: ' + result.digest);
                return result;
            } else {
                console.error('Transaction failed or result is unexpected:', result);
                throw new Error('Transaction failed or returned unexpected result');
            }
        } catch (error) {
            console.error('Error in mintNFT:', error);
            alert('Error minting NFT: ' + error.message);
            throw error;
        }
    };

    return { mintNFT };
}
