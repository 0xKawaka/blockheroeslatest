use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct MapProgress {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub map: u16,
    pub level: u16,
}