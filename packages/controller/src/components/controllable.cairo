#[starknet::component]
mod ControllableComponent {
    // Dojo imports

    use dojo::world::WorldStorage;

    // Internal imports

    use controller::store::{Store, StoreTrait};
    use controller::models::account::{Account, AccountTrait, AccountAssert};
    use controller::models::controller::{Controller, ControllerTrait, ControllerAssert};
    use controller::models::signer::{Signer, SignerTrait, SignerAssert};

    // Storage

    #[storage]
    struct Storage {}

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>,
    > of InternalTrait<TContractState> {}
}
