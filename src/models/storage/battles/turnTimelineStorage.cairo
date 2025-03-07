use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct TurnTimelineStorage {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    #[key]
    pub index: u16,
    pub entityIndex: u16,
}