use game::models::hero::rune::RuneStatistic;

#[derive(Copy, Drop, Serde, Introspect)]
pub struct RuneBonus {
    pub statistic: RuneStatistic,
    pub isPercent: bool,
}

pub fn new(statistic: RuneStatistic, isPercent: bool) -> RuneBonus {
    RuneBonus {
        statistic,
        isPercent,
    }
}

pub trait RuneBonusTrait {
    fn print(self: RuneBonus);
    fn statisticToString(self: RuneBonus)-> felt252;
}

pub impl RuneBonusImpl of RuneBonusTrait {
    fn print(self: RuneBonus) {
        println!("{}", self.statisticToString());
    }
    fn statisticToString(self: RuneBonus)-> felt252 {
        let mut statisticStr: felt252 = '';
        match self.statistic {
            RuneStatistic::Health => statisticStr = 'health',
            RuneStatistic::Attack => statisticStr = 'attack',
            RuneStatistic::Defense => statisticStr = 'defense',
            RuneStatistic::Speed => statisticStr = 'speed',
        }
        return statisticStr;
    }
}