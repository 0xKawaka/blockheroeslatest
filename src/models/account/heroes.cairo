use game::models::hero::Hero;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Heroes {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub index: u32,
    pub hero: Hero,
}