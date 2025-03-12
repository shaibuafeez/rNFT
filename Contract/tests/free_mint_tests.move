#[test_only]
module rnfts::main_tests {
    use rnfts::main::{
        Self,
        WalletArt,
        WalletArtRegistry,
        ECOUNT_OVERFLOW
    };
    use sui::{
        test_scenario::{Self as ts},
        random::{Self, Random}
    };
    use std::string;

    // ======== Constants =======
    const SYSTEM: address = @0x0;
    const ADMIN: address = @0xA; 
    const USER: address = @0xB; 

    /*
    Initialization Tests
    Objective: Verify the initialization of the module and objects
    */
    #[test]
    public fun test_module_initialization() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val; 

        main::test_init(ts::ctx(scenario));

        // Verify the registry was created
        ts::next_tx(scenario, ADMIN);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            assert!(main::get_registry_count(&registry) == 0, 0);
            ts::return_shared(registry);
        }

        ts::end(scenario_val);
    }

    /*
    NFT Minting Tests
    Objective: Validate the new function for minting NFTs.
    */
    #[test]
    public fun test_mint_nft() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Create random object
        ts::next_tx(scenario, SYSTEM); 
        {
            random::create_for_testing(ts::ctx(scenario));
        }

        // Mint an NFT
        ts::next_tx(scenario, USER);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            let random_state = ts::take_shared<Random>(scenario);

            main::new(
                &mut registry,
                &random_state,
                ts::ctx(scenario)
            );

            // Check the registry count
            assert!(main::get_registry_count(&registry) == 1, 1);
            
            ts::return_shared(random_state);
            ts::return_shared(registry);
        }

        // Check the NFT properties
        ts::next_tx(scenario, USER);
        {
            let nft = ts::take_from_sender<WalletArt>(scenario);

            // Verify NFT properties
            assert!(main::get_nft_size(&nft) == 1024, 2); // 32x32 = 1024
            assert!(main::get_nft_owner(&nft) == USER, 3);
            assert!(main::get_nft_number(&nft) == 1, 4);
            assert!(string::length(main::get_nft_data_url(&nft)) > 0, 5);
            
            ts::return_to_sender(scenario, nft);
        }
        
        ts::end(scenario_val);
    }

    /*
    Multiple NFT Minting Test
    Objective: Test minting multiple NFTs and verify their properties
    */
    #[test]
    public fun test_multiple_nft_minting() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Create random object
        ts::next_tx(scenario, SYSTEM); 
        {
            random::create_for_testing(ts::ctx(scenario));
        }

        // Mint first NFT
        ts::next_tx(scenario, USER);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            let random_state = ts::take_shared<Random>(scenario);
            
            main::new(
                &mut registry,
                &random_state,
                ts::ctx(scenario)
            );
            
            ts::return_shared(random_state);
            ts::return_shared(registry);
        }

        // Verify first NFT
        ts::next_tx(scenario, USER);
        {
            let nft1 = ts::take_from_sender<WalletArt>(scenario);
            assert!(main::get_nft_number(&nft1) == 1, 1);
            ts::return_to_sender(scenario, nft1);
        }

        // Mint second NFT
        ts::next_tx(scenario, USER);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            let random_state = ts::take_shared<Random>(scenario);
            
            main::new(
                &mut registry,
                &random_state,
                ts::ctx(scenario)
            );
            
            // Verify registry count
            assert!(main::get_registry_count(&registry) == 2, 3);
            
            ts::return_shared(random_state);
            ts::return_shared(registry);
        }

        // Verify second NFT
        ts::next_tx(scenario, USER);
        {
            let nft2 = ts::take_from_sender<WalletArt>(scenario);
            assert!(main::get_nft_number(&nft2) == 2, 2);
            ts::return_to_sender(scenario, nft2);
        }

        ts::end(scenario_val);
    }

    /*
    Data URL Generation Test
    Objective: Verify the data URL format and content
    */
    #[test]
    public fun test_data_url_generation() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Create random object
        ts::next_tx(scenario, SYSTEM); 
        {
            random::create_for_testing(ts::ctx(scenario));
        }

        // Mint NFT
        ts::next_tx(scenario, USER);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            let random_state = ts::take_shared<Random>(scenario);
            
            main::new(
                &mut registry,
                &random_state,
                ts::ctx(scenario)
            );
            
            ts::return_shared(random_state);
            ts::return_shared(registry);
        }

        // Check the data URL
        ts::next_tx(scenario, USER);
        {
            let nft = ts::take_from_sender<WalletArt>(scenario);
            
            let data_url = main::get_nft_data_url(&nft);
            
            // Check data URL format
            let data_url_prefix = b"data:image/svg+xml;base64,";
            let prefix_len = string::length(&string::utf8(data_url_prefix));
            
            // Verify the data URL starts with the correct prefix
            let actual_prefix = string::substring(data_url, 0, prefix_len);
            assert!(actual_prefix == string::utf8(data_url_prefix), 1);
            
            // Verify the data URL has content after the prefix
            assert!(string::length(data_url) > prefix_len, 2);
            
            ts::return_to_sender(scenario, nft);
        }
        
        ts::end(scenario_val);
    }

    /*
    Registry Overflow Test
    Objective: Test the registry overflow protection
    */
    #[test, expected_failure(abort_code = ECOUNT_OVERFLOW)]
    public fun test_registry_overflow() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Create random object
        ts::next_tx(scenario, SYSTEM); 
        {
            random::create_for_testing(ts::ctx(scenario));
        }

        // Set the registry count to MAX_U64 - 1
        ts::next_tx(scenario, ADMIN);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            main::test_set_registry_count(&mut registry, 0xFFFFFFFFFFFFFFFF - 1);
            ts::return_shared(registry);
        }

        // Mint an NFT (should fail with ECOUNT_OVERFLOW)
        ts::next_tx(scenario, USER);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            let random_state = ts::take_shared<Random>(scenario);
            
            main::new(
                &mut registry,
                &random_state,
                ts::ctx(scenario)
            );
            
            ts::return_shared(random_state);
            ts::return_shared(registry);
        }

        ts::end(scenario_val);
    }

    /*
    Direct Registry Overflow Check Test
    Objective: Test the test_check_registry_overflow function
    */
    #[test]
    public fun test_check_registry_overflow_function() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Take the registry
        ts::next_tx(scenario, ADMIN);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            
            // This should pass
            main::test_check_registry_overflow(&registry);
            
            // Set the registry count to MAX_U64 - 2
            main::test_set_registry_count(&mut registry, 0xFFFFFFFFFFFFFFFF - 2);
            
            // This should still pass
            main::test_check_registry_overflow(&registry);
            
            ts::return_shared(registry);
        }
        
        ts::end(scenario_val);
    }

    /*
    Direct Registry Overflow Check Failure Test
    Objective: Test the test_check_registry_overflow function fails when expected
    */
    #[test, expected_failure(abort_code = ECOUNT_OVERFLOW)]
    public fun test_check_registry_overflow_function_failure() {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        main::test_init(ts::ctx(scenario)); 

        // Take the registry
        ts::next_tx(scenario, ADMIN);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            
            // Set the registry count to MAX_U64
            main::test_set_registry_count(&mut registry, 0xFFFFFFFFFFFFFFFF);
            
            // This should fail with ECOUNT_OVERFLOW
            main::test_check_registry_overflow(&registry);
            
            ts::return_shared(registry);
        }
        
        ts::end(scenario_val);
    }
}