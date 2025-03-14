# rNFTs - Regenerative NFTs on Sui

This project allows users to create unique, algorithmically generated NFT art based on their Sui wallet address. The NFTs are "soulbound" (non-transferable) to the wallet that mints them.

## Project Structure

- **Contract/** - Contains the Move smart contract code
  - Deployed Package ID: `0xa6225c6b13a2190832c0afd29421dd6accd95f785529cb1030625f8e45153ee7`
  - Registry Object ID: `0x55cfb1a9785c4e799ecc76c2d1afae8ac90d000dccf2e56931b4ba87975665c6`

- **FrontEnd/** - Contains the React web application

## Running the Frontend

1. Navigate to the FrontEnd directory:
   ```
   cd FrontEnd
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npm start
   ```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Switching Between Networks

The application is configured to work with both devnet and mainnet. To switch between networks:

1. Update the `NETWORK` constant in `FrontEnd/src/config/constants.js`:
   ```javascript
   // Set to 'mainnet' for production or 'devnet' for testing
   export const NETWORK = 'mainnet'; 
   ```

2. Update the contract details in the same file with the appropriate Package ID and Registry ID for the selected network:
   ```javascript
   // Replace with your network-specific values
   export const PACKAGE_ID = '0x...'; 
   export const REGISTRY = '0x...';
   ```

3. If you're deploying to mainnet, make sure to publish your contract using:
   ```
   sui client switch --env mainnet
   sui client publish --gas-budget 100000000 ./Contract
   ```

## Minting an NFT

1. Connect your Sui wallet using the "Connect Wallet" button
2. Click "Mint" to create your unique 16x16 NFT
3. Approve the transaction in your wallet
4. Your NFT will be minted for FREE (you only pay gas fees)

## Technical Details

- The NFT generation algorithm takes your wallet address and converts it to a set of colors
- The smart contract generates a unique 16x16 pixel art pattern based on your wallet address
- The image is stored on-chain as an SVG
- Minting is FREE (you only pay gas fees)
- The contract is gas-optimized for efficient minting

## Contract Deployment

The contract has been deployed to the Sui mainnet with the following details:
- Package ID: `0xc6ea8188930e251f1e8b239d7530aba6577a4a8a4c5f17eff8ed288eb7d463fb`
- Registry: `0x25371cd529b8a939d357f3c3dc582bf8826bbbc1c192ca5dbfa8b625352448d5`

## Frontend Integration

The frontend has been configured to interact with the deployed contract. The integration is handled through:
- Sui JavaScript SDK for transaction creation
- Suiet Wallet Kit for wallet connection and transaction signing
