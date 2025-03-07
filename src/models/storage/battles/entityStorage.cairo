use starknet::ContractAddress;
use game::models::battle::entity::Entity;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct EntityStorage {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    #[key]
    pub entityIndex: u32,
    pub entityVal: Entity,
    pub healthOnTurnProcCount: u32,
}
