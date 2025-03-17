pub mod battleStatistic;
pub mod statModifier;

use game::models::battle::entity::battleStatistics::battleStatistic::{BattleStatisticTrait, BattleStatisticImpl};
use game::models::battle::entity::skill::buff::BuffType;


#[derive(Copy, Drop, Serde, Introspect)]
pub struct BattleStatistics {
    pub maxHealth: u64,
    pub health: i64,
    pub attack: battleStatistic::BattleStatistic,
    pub defense: battleStatistic::BattleStatistic,
    pub speed: battleStatistic::BattleStatistic,
    pub criticalChance: battleStatistic::BattleStatistic,
    pub criticalDamage: battleStatistic::BattleStatistic,
}

pub fn new(
    health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage: u64
) -> BattleStatistics {
    BattleStatistics {
        maxHealth: health,
        health: health.try_into().unwrap(),
        attack: battleStatistic::new(attack),
        defense: battleStatistic::new(defense),
        speed: battleStatistic::new(speed),
        criticalChance: battleStatistic::new(criticalChance),
        criticalDamage: battleStatistic::new(criticalDamage),
    }
}

pub trait BattleStatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: BattleStatistics);
    fn applyStatModifier(
        ref self: BattleStatistics, buffType: BuffType, statModifierValue: u64, statModifierDuration: u8,
    );
    fn resetBonusMalus(ref self: BattleStatistics);
    fn getAttack(self: @BattleStatistics) -> u64;
    fn getDefense(self: @BattleStatistics) -> u64;
    fn getSpeed(self: @BattleStatistics) -> u64;
    fn getCriticalChance(self: @BattleStatistics) -> u64;
    fn getCriticalDamage(self: @BattleStatistics) -> u64;
    fn getHealth(self: @BattleStatistics) -> i64;
    fn getMaxHealth(self: @BattleStatistics) -> u64;
    fn print(self: @BattleStatistics);
}

pub impl BattleStatisticsImpl of BattleStatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: BattleStatistics) {
        self.attack.reduceDuration();
        self.defense.reduceDuration();
        self.speed.reduceDuration();
        // self.criticalChance.reduceDuration();
        // self.criticalDamage.reduceDuration();
    }
    fn applyStatModifier(
        ref self: BattleStatistics, buffType: BuffType, statModifierValue: u64, statModifierDuration: u8
    ) {
        if(buffType == BuffType::SpeedUp) {
            self.speed.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::SpeedDown) {
            self.speed.setMalus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::AttackUp) {
            self.attack.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::AttackDown) {
            self.attack.setMalus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::DefenseUp) {
            self.defense.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::DefenseDown) {
            self.defense.setMalus(statModifierValue, statModifierDuration);
        }      
    }
    fn resetBonusMalus(ref self: BattleStatistics) {
        self.attack.resetBonusMalus();
        self.defense.resetBonusMalus();
        self.speed.resetBonusMalus();
        self.criticalChance.resetBonusMalus();
        self.criticalDamage.resetBonusMalus();
    }
    fn getAttack(self: @BattleStatistics) -> u64 {
        return self.attack.getModifiedValue();
    }
    fn getDefense(self: @BattleStatistics) -> u64 {
        return self.defense.getModifiedValue();
    }
    fn getSpeed(self: @BattleStatistics) -> u64 {
        return self.speed.getModifiedValue();
    }
    fn getCriticalChance(self: @BattleStatistics) -> u64 {
        return self.criticalChance.getModifiedValue();
    }
    fn getCriticalDamage(self: @BattleStatistics) -> u64 {
        return self.criticalDamage.getModifiedValue();
    }
    fn getHealth(self: @BattleStatistics) -> i64 {
        return *self.health;
    }
    fn getMaxHealth(self: @BattleStatistics) -> u64 {
        return *self.maxHealth;
    }
    fn print(self: @BattleStatistics) {
        println!("Health: {}", self.health);
        println!("Attack: {}", self.attack.getModifiedValue());
        println!("Defense: {}", self.defense.getModifiedValue());
        println!("Speed: {}", self.speed.getModifiedValue());
        println!("Critical chance: {}", self.criticalChance.getModifiedValue());
        println!("Critical damage: {}", self.criticalDamage.getModifiedValue());
    }
}
