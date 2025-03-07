#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct EnemyRanges {
    #[key]
    pub index: u32,
    pub minRank: u64,
    pub range: u64,
}