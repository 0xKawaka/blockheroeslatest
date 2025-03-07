use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct ArenaBattleStorage {
    #[key]
    pub owner: ContractAddress,
    pub enemyOwner: ContractAddress,
}