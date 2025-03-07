use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct BattleStorage {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    pub level: u16,
    pub entitiesCount: u32,
    pub aliveEntitiesCount: u32,
    pub isBattleOver: bool,
    pub isWaitingForPlayerAction: bool,
}