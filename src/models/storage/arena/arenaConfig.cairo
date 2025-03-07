#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct ArenaConfig {
    #[key]
    pub id: u8,
    pub enemyRangesByRankLength: u32,
    pub gemsRewardsLength: u32,
}