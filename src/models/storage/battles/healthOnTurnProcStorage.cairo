use starknet::ContractAddress;
use game::models::battle::entity::healthOnTurnProc::HealthOnTurnProc;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct HealthOnTurnProcStorage {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    #[key]
    pub entityIndex: u32,
    #[key]
    pub index: u32,
    pub healthOnTurnProc: HealthOnTurnProc,
}
