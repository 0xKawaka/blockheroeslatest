use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Usernames {
    #[key]
    pub username: felt252,
    pub owner: ContractAddress,
}