mod setup {
    // Core imports

    use core::debug::PrintTrait;

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing;
    use starknet::testing::{set_contract_address, set_block_timestamp};

    // Dojo imports

    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, ContractDef, TestResource, ContractDefTrait,
        WorldStorageTestTrait,
    };

    // Internal imports

    use achievement::events::{index as events};
    use achievement::tests::mocks::achiever::{Achiever, IAchiever, IAchieverDispatcher};

    // Constant

    fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<'OWNER'>()
    }

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[derive(Copy, Drop)]
    struct Systems {
        achiever: IAchieverDispatcher,
    }

    #[derive(Copy, Drop)]
    struct Context {
        player_id: felt252,
    }

    /// Drop all events from the given contract address
    pub fn clear_events(address: ContractAddress) {
        loop {
            match starknet::testing::pop_log_raw(address) {
                core::option::Option::Some(_) => {},
                core::option::Option::None => { break; },
            };
        }
    }

    #[inline]
    fn setup_namespace() -> NamespaceDef {
        NamespaceDef {
            namespace: "namespace",
            resources: [
                TestResource::Event(events::e_TrophyCreation::TEST_CLASS_HASH),
                TestResource::Event(events::e_TrophyProgression::TEST_CLASS_HASH),
                TestResource::Event(events::e_TrophyPinning::TEST_CLASS_HASH),
                TestResource::Contract(Achiever::TEST_CLASS_HASH),
            ]
                .span(),
        }
    }

    fn setup_contracts() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"namespace", @"Achiever")
                .with_writer_of([dojo::utils::bytearray_hash(@"namespace")].span()),
        ]
            .span()
    }

    #[inline]
    fn spawn_game() -> (WorldStorage, Systems, Context) {
        // [Setup] World
        set_contract_address(OWNER());
        let namespace_def = setup_namespace();
        let world = spawn_test_world([namespace_def].span());
        world.sync_perms_and_inits(setup_contracts());
        // [Setup] Systems
        let (achiever_address, _) = world.dns(@"Achiever").unwrap();
        let systems = Systems {
            achiever: IAchieverDispatcher { contract_address: achiever_address },
        };

        // [Setup] Context
        let context = Context { player_id: PLAYER().into() };

        // [Return]
        (world, systems, context)
    }
}
