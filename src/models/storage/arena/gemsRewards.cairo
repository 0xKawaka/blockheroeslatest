#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GemsRewards {
    #[key]
    pub index: u32,
    pub minRank: u64,
    pub gems: u64,
}