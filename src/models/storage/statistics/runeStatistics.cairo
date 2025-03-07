use game::models::hero::{rune::RuneImpl, rune::RuneRarity, rune::RuneStatistic};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct RuneStatistics {
    #[key]
    pub statistic: RuneStatistic,
    #[key]
    pub rarity: RuneRarity,
    #[key]
    pub isPercent: bool,
    pub value: u32,
}

pub fn new(statistic: RuneStatistic, rarity: RuneRarity, isPercent: bool, value: u32) -> RuneStatistics {
    RuneStatistics {
        statistic,
        rarity,
        isPercent,
        value,
    }
}