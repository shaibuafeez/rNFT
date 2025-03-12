#[test_only]
#[allow(unused_let_mut)]
module rnfts::main_tests {
    use rnfts::main::{
        Self,
        WalletArtRegistry,
        ECOUNT_OVERFLOW
    };
    use sui::test_scenario::{Self as ts};

    // ======== Constants =======
    const ADMIN: address = @0xA; 

    // Maximum value for u64 (copied from main module)
    const MAX_U64: u64 = 18446744073709551615;

    /*
    Initialization Tests
    Objective: Verify the initialization of the module and objects
    */
    #[test]
    public fun test_module_initialization() {
        let mut scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val; 

        test_init(ts::ctx(scenario));

        // Verify the registry was created
        ts::next_tx(scenario, ADMIN);
        {
            let registry = ts::take_shared<WalletArtRegistry>(scenario);
            assert!(main::get_registry_count(&registry) == 0, 0);
            ts::return_shared(registry);
        };

        ts::end(scenario_val);
    }

    /*
    Registry Overflow Test
    Objective: Verify the registry overflow protection
    */
    #[test]
    #[expected_failure(abort_code = ECOUNT_OVERFLOW)]
    public fun test_registry_overflow() {
        let mut scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        
        // Initialize the module
        test_init(ts::ctx(scenario)); 

        // Set registry count to MAX_U64 - 1 using the test helper
        ts::next_tx(scenario, ADMIN);
        {
            let mut registry = ts::take_shared<WalletArtRegistry>(scenario);
            
            // Set the registry count to MAX_U64 - 1
            main::test_set_registry_count(&mut registry, MAX_U64 - 1);
            
            // This should fail with ECOUNT_OVERFLOW
            main::test_check_registry_overflow(&registry);
            
            ts::return_shared(registry);
        };
        
        ts::end(scenario_val);
    }

    // ======== Test Helper Functions ========

    #[test_only]
    public fun test_init(ctx: &mut sui::tx_context::TxContext) {
        main::test_init(ctx)
    }
}
