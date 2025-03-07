use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct ArenaTeam {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub index: u32,
    pub heroIndex: u32,
}