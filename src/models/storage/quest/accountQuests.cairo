use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct AccountQuests {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    #[key]
    pub mapProgressRequired: u16,
    pub hasClaimedRewards: bool,
}