import React, { useState, useEffect } from "react";
import { SuiLogo } from "../assets/icons";
import "@fontsource/cormorant-infant";
import "@fontsource/courier-prime";
import "@fontsource/inter";
import Images from "../assets/images";
import ColorButtons from "../assets/images/Group 26.png";
import { WalletProvider, ConnectButton, useWallet } from "@suiet/wallet-kit";
import "@suiet/wallet-kit/style.css";
import { useMintNFT } from "../moveCalls/useWalletArt";
import "../assets/styles/CreateArt.css";
import ShareLink from 'react-twitter-share-link';

function CreateArt() {
    const wallet = useWallet();
    const { mintNFT } = useMintNFT();

    // Wallet's connection status
    const isConnected = wallet.connected;

    // No need to track previous connection state with our current implementation

    // Add a local state to wait for wallet initialization to settle.
    const [isInitialized, setIsInitialized] = useState(false);

    // Wait 1.5 seconds after the first render to assume wallet-state is stable.
    useEffect(() => {
        const timer = setTimeout(() => setIsInitialized(true), 1500);
        return () => clearTimeout(timer);
    }, []);

    // Refresh effect: reloading only once per state change
    useEffect(() => {
        if (!isInitialized) return; // Don't act until wallet state has (hopefully) stabilized

        const walletStateKey = "walletConnectionState";
        const attemptsKey = "walletRefreshedAttempts";
        const storedState = sessionStorage.getItem(walletStateKey);
        const currentState = isConnected ? "connected" : "disconnected";
        let attempts = parseInt(sessionStorage.getItem(attemptsKey)) || 0;

        if (!storedState) {
            // First load: store the current wallet state so we don't trigger a refresh.
            sessionStorage.setItem(walletStateKey, currentState);
            console.log("Initial wallet state stored:", currentState);
        } else if (storedState !== currentState) {
            // Wallet state has changed (either connected or disconnected)
            if (attempts < 1) {
                console.log("Wallet state changed from", storedState, "to", currentState, ". Refreshing page once.");
                sessionStorage.setItem(walletStateKey, currentState);
                sessionStorage.setItem(attemptsKey, attempts + 1); // record that we reloaded once for this change
                window.location.reload();
            } else {
                console.log("Wallet state changed but already refreshed once, skipping reload.");
            }
        } else {
            // If the state matches, clear any reload attempt count so that future changes can reload again.
            sessionStorage.removeItem(attemptsKey);
            console.log("Wallet state unchanged:", currentState);
        }
    }, [isConnected, isInitialized]);

    const handleMint = async () => {
        if (!isConnected) {
            console.error("Wallet not connected. Please connect your wallet.");
            return;
        }

        try {
            // Call the mintNFT function without any payment parameters
            await mintNFT();
            console.log("Free NFT minting initiated");
        } catch (error) {
            console.error("Error minting NFT:", error);
        }
    };

    const renderImage = () => {
        // Always use 16x16 image
        const key = "0x16";
        const imageSrc = Images[key];
        if (imageSrc) {
            return <img src={imageSrc} alt="16x16 Art" />;
        } else {
            console.error("Image source is not valid");
            return null;
        }
    };

    const handleShare = () => {
        return `https://rnft.art/16x16.png`;
    };

    return (
        <WalletProvider>
            <div className={`flex flex-col items-center ${isConnected ? "bg-connected" : "bg-disconnected"}`}>
                {/* Header / Logo */}
                <div className="py-6">
                    <div className="flex items-center justify-center gap-[2px]">
                        <SuiLogo />
                        <p className="font-inter font-bold text-xl text-black">rNFT</p>
                    </div>
                </div>

                {/* Title & Connect Button */}
                <div className="py-6">
                    <div className="max-w-[513px]">
                        <div className="flex flex-col items-center">
                            <h1 className="font-cormorant text-[44px] mb-[7px]">
                                Create art on chain
                            </h1>
                            <p className="mb-[21px] font-inter text-center">
                                Generate & mint beautiful dynamic 16x16 soul-bound NFT art based on
                                your SUI wallet hexadecimal address with gas-optimized minting.
                            </p>
                            <ConnectButton
                                className={isConnected ? "my-connect-button connected" : "my-connect-button"}
                                label="Connect Wallet"
                            />
                        </div>
                    </div>
                </div>

                {/* Main content */}
                <div className="md:max-w-[459px] max-w-full md:mx-0 mx-4 md:pb-20 pb-6">
                    <div className="md:p-8 p-4 bg-white border-[#DBDBDB] rounded-[10px] border-[0.5px]">
                        <div className="p-4 flex flex-col gap-3">
                            <p className="font-inter font-[800]">Instructions</p>
                            <p className="font-inter text-sm">
                                Connect your SUI wallet and verify the address is correct. 
                                Tap Mint to generate your free 16x16 rNFT with our gas-optimized algorithm.
                            </p>
                        </div>

                        <div className="p-4 flex flex-col gap-3">
                            {/* Example art preview */}
                            <div>{renderImage()}</div>

                            {/* Mint button & color buttons */}
                            <div className="flex justify-between items-center">
                                <button
                                    onClick={handleMint}
                                    disabled={!isConnected}
                                    className={`py-[10px] px-8 rounded-[5px] min-w-[120px] ${
                                        isConnected ? "bg-black" : "bg-gray-400 cursor-not-allowed"
                                    }`}
                                >
                                    <p className="font-inter font-medium text-white">
                                        Mint
                                    </p>
                                </button>
                                <img src={ColorButtons} alt="Color Buttons" width="99" height="44" />
                            </div>

                            {/* Share on Twitter */}
                            <div className="mt-4 flex justify-center">
                                <ShareLink
                                    link={handleShare()}
                                    text={`Check out my new 16x16 rNFT!\n\nGet yours at rnft.art!\n\n`}
                                    hashtags="NFT,Art"
                                >
                                    {(link) => (
                                        <a
                                            href={link}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="my-connect-button"
                                        >
                                            Share on X
                                        </a>
                                    )}
                                </ShareLink>
                            </div>

                            <p className="font-inter font-medium text-[12px] text-center">
                                rNFTs are non-transferable. To regenerate, mint again.
                                Only gas fees apply.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </WalletProvider>
    );
}

export default CreateArt;