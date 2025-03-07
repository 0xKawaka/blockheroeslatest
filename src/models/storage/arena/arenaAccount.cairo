use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct ArenaAccount {
    #[key]
    pub owner: ContractAddress,
    pub rank: u64,
    pub lastClaimedRewards: u64,
    teamSize: u32,
}