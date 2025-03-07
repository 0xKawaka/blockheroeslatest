use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct DailyQuests {
    #[key]
    pub owner: ContractAddress,
    pub arenaFightsCount: u32,
    pub campaignFightsCount: u32,
    pub upgradeRunesCount: u32,
    pub lastClaimedRewards: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct DailyQuestsSetttings {
    #[key]
    pub index: u16,
    pub arenaFightsRequired: u32,
    pub campaignFightsRequired: u32,
    pub upgradeRunesRequired: u32,
}