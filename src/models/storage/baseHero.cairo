const decimals: u64 = 100;
const statsBonusPerLevel: u64 = 10;
const attackBonusPerLevel: u64 = 20;

use game::models::storage::{statistics, statistics::Statistics};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct BaseHero {
    #[key]
    pub heroName: felt252,
    pub rank: u16,
    pub statistics: Statistics,
    pub skillsCount: u8,
}

pub fn new(
    heroName: felt252, rank: u16, health: u64, attack: u64, defense: u64, speed: u64, criticalRate: u64, criticalDamage: u64, skillsCount: u8
) -> BaseHero {
    return BaseHero {
        heroName: heroName,
        rank: rank,
        statistics: statistics::new(health, attack, defense, speed, criticalRate, criticalDamage),
        skillsCount: skillsCount,
    };
}

pub trait BaseHeroTrait {
    fn computeHealth(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeAttack(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeDefense(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeSpeed(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeCriticalRate(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeCriticalDamage(self: BaseHero, level: u16, rank: u16) -> u64;
    fn computeAllStatistics(
        self: BaseHero, level: u16, rank: u16
    ) -> Statistics;
}

pub impl BaseHeroImpl of BaseHeroTrait {
    fn computeHealth(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.health + (self.statistics.health * (level.into() - 1) * statsBonusPerLevel / decimals);
    }
    fn computeAttack(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.attack + (self.statistics.attack * (level.into() - 1) * attackBonusPerLevel / decimals);
    }
    fn computeDefense(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.defense + (self.statistics.defense * (level.into() - 1) * statsBonusPerLevel / decimals);
    }
    fn computeSpeed(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.speed + (self.statistics.speed * (level.into() - 1) * statsBonusPerLevel / decimals);
    }
    fn computeCriticalRate(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.criticalRate;
    }
    fn computeCriticalDamage(self: BaseHero, level: u16, rank: u16) -> u64 {
        return self.statistics.criticalDamage;
    }
    fn computeAllStatistics(
        self: BaseHero, level: u16, rank: u16
    ) -> Statistics {
        return statistics::new(
            self.computeHealth(level, rank),
            self.computeAttack(level, rank),
            self.computeDefense(level, rank),
            self.computeSpeed(level, rank),
            self.computeCriticalRate(level, rank),
            self.computeCriticalDamage(level, rank)
        );
    }
}

