#[test_only]
module rnfts::main_free_tests;

use rnfts::main::{
    Self,
    WalletArtRegistry,
    ECOUNT_OVERFLOW
};
use sui::test_scenario::{Self as ts}; 
use sui::random::{Self, Random};

// ======== Constants =======
const ADMIN: address = @0xA; 
const USER: address = @0xB;
const SYSTEM: address = @0x0;

/*
Initialization Tests
Objective: Verify the initialization of the module and objects, including WalletArtRegistry.
*/

#[test]
public fun test_module_initialization() {
    let mut scenario_val = ts::begin(ADMIN);
    let scenario = &mut scenario_val; 

    // Initialize the module
    {
        rnfts::main::test_init(ts::ctx(scenario));
    };

    // Verify the registry was created with count = 0
    ts::next_tx(scenario, ADMIN);
    {
        let registry = ts::take_shared<WalletArtRegistry>(scenario);
        assert!(rnfts::main::get_registry_count(&registry) == 0, 1);
        ts::return_shared(registry);
    };

    ts::end(scenario_val);
}

/*
Registry Overflow Test - Direct Test
Objective: Directly test the overflow condition without going through the full minting process
*/
#[test, expected_failure(abort_code = ECOUNT_OVERFLOW)]
public fun test_registry_overflow_direct() {
    let mut scenario_val = ts::begin(ADMIN);
    let scenario = &mut scenario_val;
    
    // Initialize the module
    {
        rnfts::main::test_init(ts::ctx(scenario)); 
    };

    // Set the registry count to MAX_U64 - 1
    ts::next_tx(scenario, ADMIN);
    {
        let mut registry = ts::take_shared<WalletArtRegistry>(scenario);
        
        // Set the count to MAX_U64 - 1
        rnfts::main::test_set_registry_count(&mut registry, 18446744073709551614); // MAX_U64 - 1
        
        // This should abort with ECOUNT_OVERFLOW
        rnfts::main::test_check_registry_overflow(&registry);
        
        ts::return_shared(registry);
    };

    ts::end(scenario_val);
}

/*
Registry Overflow Test with Full Minting Process
Objective: Verify that the contract correctly handles the case when the registry count approaches the maximum value.
*/
#[test, expected_failure(abort_code = ECOUNT_OVERFLOW)]
public fun test_registry_overflow_on_minting() {
    let mut scenario_val = ts::begin(ADMIN);
    let scenario = &mut scenario_val;
    
    // Initialize the module
    {
        rnfts::main::test_init(ts::ctx(scenario)); 
    };

    // Create Random object for testing
    ts::next_tx(scenario, SYSTEM); 
    {
        random::create_for_testing(ts::ctx(scenario));
    };

    // Set the registry count to MAX_U64 - 1 (exactly at our check limit)
    ts::next_tx(scenario, ADMIN);
    {
        let mut registry = ts::take_shared<WalletArtRegistry>(scenario);
        
        // Set the count to MAX_U64 - 1
        rnfts::main::test_set_registry_count(&mut registry, 18446744073709551614); // MAX_U64 - 1
        
        ts::return_shared(registry);
    };

    // Try to mint which should cause overflow
    ts::next_tx(scenario, USER);
    {
        let mut registry = ts::take_shared<WalletArtRegistry>(scenario);
        let random_state = ts::take_shared<Random>(scenario);

        // This should abort with ECOUNT_OVERFLOW
        rnfts::main::new(
            &mut registry,
            &random_state,
            ts::ctx(scenario)
        );
        
        ts::return_shared(random_state);
        ts::return_shared(registry);
    };

    ts::end(scenario_val);
}
