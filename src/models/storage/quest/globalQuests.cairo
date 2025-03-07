use game::models::storage::quest::rewardType::RewardType;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GlobalQuests {
    #[key]
    pub map: u16,
    #[key]
    pub mapProgressRequired: u16,
    pub rewardType: RewardType,
    pub rewardQuantity: u32,
}
