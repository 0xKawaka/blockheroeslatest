pub mod runeBonus;

use starknet::{get_block_timestamp};

use game::models::hero::rune::runeBonus::{RuneBonus, RuneBonusTrait, RuneBonusImpl};
use game::models::account::{Account, AccountImpl};
use game::models::events::{RuneBonusEvent, RuneUpgraded};

use dojo::event::EventStorage;
use dojo::world::WorldStorage;


use game::utils::random::rand32;


#[derive(Copy, Drop, Serde, Introspect)]
pub enum RuneType {
    First,
    Second,
    Third,
    Fourth,
    Fifth,
    Sixth,
}

// #[derive(Copy, Drop, Serde, hash::LegacyHash, Introspect)]
#[derive(Copy, Drop, Serde, Introspect)]
pub enum RuneRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(Copy, Drop, Serde, Introspect)]
pub enum RuneStatistic {
    Health,
    Attack,
    Defense,
    Speed,
    // CriticalRate,
    // CriticalDamage,
}

#[derive(Introspect, Copy, Drop, Serde)]
pub struct Rune {
    pub id: u32,
    pub statistic: RuneStatistic,
    pub isPercent: bool,
    pub rank: u32,
    pub rarity: RuneRarity,
    pub runeType: RuneType,
    pub isEquipped: bool,
    pub heroEquipped: u32,
    pub rank4Bonus: RuneBonus,
    pub rank8Bonus: RuneBonus,
    pub rank12Bonus: RuneBonus,
    pub rank16Bonus: RuneBonus,
}

const RUNE_STAT_COUNT: u32 = 4;
const RUNE_RARITY_COUNT: u32 = 5;
const RUNE_TYPE_COUNT: u32 = 6;

pub fn new(id: u32) -> Rune {
    let seed = get_block_timestamp();
    let statistic = getRandomStat(seed);
    let isPercent = getRandomIsPercent(seed);
    let rarity = getRandomRarity(seed);
    let runeType = getRandomType(seed);

    Rune {
        id: id,
        statistic: statistic,
        isPercent: isPercent,
        rank: 0,
        rarity: rarity,
        runeType: runeType,
        isEquipped: false,
        heroEquipped: 0,
        rank4Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank8Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank12Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank16Bonus: runeBonus::new(RuneStatistic::Attack, false),
    }
}

pub fn newDeterministic(id: u32, statistic: RuneStatistic, isPercent: bool, rarity: RuneRarity, runeType: RuneType) -> Rune {
    Rune {
        id: id,
        statistic: statistic,
        isPercent: isPercent,
        rank: 0,
        rarity: rarity,
        runeType: runeType,
        isEquipped: false,
        heroEquipped: 0,
        rank4Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank8Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank12Bonus: runeBonus::new(RuneStatistic::Attack, false),
        rank16Bonus: runeBonus::new(RuneStatistic::Attack, false),
    }
}

pub fn getRandomStat(seed: u64) -> RuneStatistic {
    let rand = rand32(seed, RUNE_STAT_COUNT);
    if rand == 0 {
        return RuneStatistic::Attack;
    } else if rand == 1 {
        return RuneStatistic::Defense;
    } else if rand == 2 {
        return RuneStatistic::Health;
    } else if rand == 3 {
        return RuneStatistic::Speed;
    }
    return RuneStatistic::Attack;
}
pub fn getRandomRarity(seed: u64) -> RuneRarity {
    return RuneRarity::Common;
    // let rand = rand32(seed, RUNE_RARITY_COUNT);
    // if rand == 0 {
    //     return RuneRarity::Common;
    // } else if rand == 1 {
    //     return RuneRarity::Uncommon;
    // } else if rand == 2 {
    //     return RuneRarity::Rare;
    // } else if rand == 3 {
    //     return RuneRarity::Epic;
    // } else if rand == 4 {
    //     return RuneRarity::Legendary;
    // }
    // return RuneRarity::Common;
}

pub fn getRandomType(seed: u64) ->  RuneType {
    let rand = rand32(seed, RUNE_TYPE_COUNT);
    if rand == 0 {
        return RuneType::First;
    } else if rand == 1 {
        return RuneType::Second;
    } else if rand == 2 {
        return RuneType::Third;
    } else if rand == 3 {
        return RuneType::Fourth;
    } else if rand == 4 {
        return RuneType::Fifth;
    } else if rand == 5 {
        return RuneType::Sixth;
    }
    return RuneType::First;
}

pub fn getRandomIsPercent(seed: u64) -> bool {
    return true;
    // let rand = rand32(seed, 2);
    // if rand == 0 {
    //     return true;
    // }
    // return false;
}

pub trait RuneTrait {
    fn upgrade(ref self: Rune, ref world: WorldStorage, ref account: Account);
    fn setEquippedBy(ref self: Rune, heroId: u32);
    fn unequip(ref self: Rune);
    fn isEquipped(self: Rune)-> bool;
    fn getHeroEquipped(self: Rune)-> u32;
    fn computeCrystalCostUpgrade(self: Rune)-> u32;
    fn print(self: Rune);
    fn printBonuses(self: Rune);
    fn statisticToString(self: Rune)-> felt252;
    fn typeToString(self: Rune)-> felt252;
}

const maxRank: u32 = 16;

pub impl RuneImpl of RuneTrait {
    fn upgrade(ref self: Rune, ref world: WorldStorage, ref account: Account) {
        assert(self.rank < maxRank, 'Rune already max rank');

        let crystalCost = self.computeCrystalCostUpgrade();
        account.decreaseCrystals(crystalCost);
        
        self.rank += 1;

        let seed = get_block_timestamp();
        if self.rank == 4 {
            self.rank4Bonus = runeBonus::new(getRandomStat(seed), getRandomIsPercent(seed));
            world.emit_event(@RuneBonusEvent {
                owner: account.owner,
                id: self.id,
                rank: self.rank,
                procStat: self.rank4Bonus.statisticToString(),
                isPercent: self.rank4Bonus.isPercent,
            });
        } else if self.rank == 8 {
            self.rank8Bonus = runeBonus::new(getRandomStat(seed), getRandomIsPercent(seed));
            world.emit_event(@RuneBonusEvent {
                owner: account.owner,
                id: self.id,
                rank: self.rank,
                procStat: self.rank8Bonus.statisticToString(),
                isPercent: self.rank8Bonus.isPercent,
            });
        } else if self.rank == 12 {
            self.rank12Bonus = runeBonus::new(getRandomStat(seed), getRandomIsPercent(seed));
            world.emit_event(@RuneBonusEvent {
                owner: account.owner,
                id: self.id,
                rank: self.rank,
                procStat: self.rank12Bonus.statisticToString(),
                isPercent: self.rank12Bonus.isPercent,
            });
        } else if self.rank == 16 {
            self.rank16Bonus = runeBonus::new(getRandomStat(seed), getRandomIsPercent(seed));
            world.emit_event(@RuneBonusEvent {
                owner: account.owner,
                id: self.id,
                rank: self.rank,
                procStat: self.rank16Bonus.statisticToString(),
                isPercent: self.rank16Bonus.isPercent,
            });
        }
        world.emit_event(@RuneUpgraded {
            owner: account.owner,
            id: self.id,
            rank: self.rank,
            crystalCost: crystalCost,
        });
    }
    fn setEquippedBy(ref self: Rune, heroId: u32) {
        assert(self.isEquipped() == false, 'Rune already equipped');
        self.isEquipped = true;
        self.heroEquipped = heroId;
    }
    fn unequip(ref self: Rune) {
        self.isEquipped = false;
    }
    fn isEquipped(self: Rune)-> bool {
        return self.isEquipped;
    }
    fn getHeroEquipped(self: Rune)-> u32 {
        return self.heroEquipped;
    }
    fn computeCrystalCostUpgrade(self: Rune)-> u32 {
        let mut crystalCost: u32 = 200 + self.rank * 200;
        return crystalCost;
    }
    fn print(self: Rune) {
        println!("Rune");
        println!("{}", self.id);
        println!("{}", self.statisticToString()); 
        println!("{}", self.typeToString());
        println!("{}", self.rank);
        self.printBonuses();
    }
    fn printBonuses(self: Rune) {
        if self.rank > 3 {
            self.rank4Bonus.print();
        }
        if self.rank > 7 {
            self.rank8Bonus.print();
        }
        if self.rank > 12 {
            self.rank12Bonus.print();
        }
        if self.rank > 16 {
            self.rank16Bonus.print();
        }
    }
    fn statisticToString(self: Rune)-> felt252 {
        let mut statisticStr: felt252 = '';
        match self.statistic {
            RuneStatistic::Health => statisticStr = 'health',
            RuneStatistic::Attack => statisticStr = 'attack',
            RuneStatistic::Defense => statisticStr = 'defense',
            RuneStatistic::Speed => statisticStr = 'speed',
        }
        return statisticStr;
    }
    fn typeToString(self: Rune)-> felt252 {
        let mut typeStr: felt252 = '';
        match self.runeType {
            RuneType::First => typeStr = 'First',
            RuneType::Second => typeStr = 'Second',
            RuneType::Third => typeStr = 'Third',
            RuneType::Fourth => typeStr = 'Fourth',
            RuneType::Fifth => typeStr = 'Fifth',
            RuneType::Sixth => typeStr = 'Sixth',
        }
        return typeStr;
    }
}