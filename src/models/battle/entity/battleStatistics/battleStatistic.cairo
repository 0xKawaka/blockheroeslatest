use game::models::battle::entity::battleStatistics::{statModifier, statModifier::StatModifier, statModifier::StatModifierImpl};

#[derive(Drop, Copy, Serde, Introspect)]
pub struct BattleStatistic {
    pub value: u64,
    pub malus: StatModifier,
    pub bonus: StatModifier,
}

pub fn new(value: u64) -> BattleStatistic {
    BattleStatistic { value: value, malus: statModifier::new(0, 0), bonus: statModifier::new(0, 0), }
}

pub trait BattleStatisticTrait {
    fn reduceDuration(ref self: BattleStatistic);
    fn getModifiedValue(self: @BattleStatistic) -> u64;
    fn getBonusValue(self: @BattleStatistic) -> u64;
    fn getMalusValue(self: @BattleStatistic) -> u64;
    fn getBonusDuration(self: @BattleStatistic) -> u8;
    fn getMalusDuration(self: @BattleStatistic) -> u8;
    fn resetBonusMalus(ref self: BattleStatistic);
    fn setBonus(ref self: BattleStatistic, value: u64, duration: u8);
    fn setMalus(ref self: BattleStatistic, value: u64, duration: u8);
}

pub impl BattleStatisticImpl of BattleStatisticTrait {
    fn reduceDuration(ref self: BattleStatistic) {
        self.malus.reduceDuration();
        self.bonus.reduceDuration();
    }
    fn getModifiedValue(self: @BattleStatistic) -> u64 {
        (*self.value + self.getBonusValue()) - self.getMalusValue()
    }
    fn getBonusValue(self: @BattleStatistic) -> u64 {
        if *self.bonus.duration == 0 {
            return 0;
        }
        return (*self.value * *self.bonus.value) / 100;
    }
    fn getMalusValue(self: @BattleStatistic) -> u64 {
        if *self.malus.duration == 0 {
            return 0;
        }
        return (*self.value * *self.malus.value) / 100;
    }
    fn getBonusDuration(self: @BattleStatistic) -> u8 {
        return *self.bonus.duration;
    }
    fn getMalusDuration(self: @BattleStatistic) -> u8 {
        return *self.malus.duration;
    }
    fn resetBonusMalus(ref self: BattleStatistic) {
        self.malus.reset();
        self.bonus.reset();
    }
    fn setBonus(ref self: BattleStatistic, value: u64, duration: u8) {
        if(duration < self.bonus.duration && value < self.bonus.value) {
            return;
        }
        self.bonus.set(value, duration);
    }
    fn setMalus(ref self: BattleStatistic, value: u64, duration: u8) {
        assert(value < 100, 'Malus value greater than 100');
        if(duration < self.malus.duration && value < self.malus.value) {
            return;
        }
        self.malus.set(value, duration);
    }
}
