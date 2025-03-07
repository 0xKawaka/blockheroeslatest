use game::models::hero::rune::Rune;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Runes {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub index: u32,
    pub rune: Rune,
}