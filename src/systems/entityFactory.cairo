use game::models::battle::entity::{Entity, AllyOrEnemy};
use game::models::storage::{statistics, statistics::{Statistics, runeStatistics::RuneStatistics, bonusRuneStatistics::BonusRuneStatistics}};
use game::models::storage::baseHero::BaseHero;
use game::models::hero::{Hero, rune::Rune, rune::RuneStatistic};
use starknet::ContractAddress;
use dojo::world::{WorldStorageTrait, WorldStorage};

trait IEntityFactory {
    fn newEntities(ref world: WorldStorage, owner: ContractAddress, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity>;
    fn newEntity(ref world: WorldStorage, owner: ContractAddress, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity;
    fn computeRunesBonuses(ref world: WorldStorage, runes: Array<Rune>, baseStats: Statistics) -> Statistics;
    fn initBaseHeroesDict(ref world: WorldStorage);
    fn initRunesTable(ref world: WorldStorage);
    fn initBonusRunesTable(ref world: WorldStorage);
    fn initHeroesByRankDict(ref world: WorldStorage);
}

pub mod EntityFactory {
    use core::option::OptionTrait;
    use starknet::ContractAddress;

    use dojo::world::{WorldStorageTrait, WorldStorage};
    use game::models::hero::{HeroTrait, Hero, rune::Rune, rune::RuneImpl, rune::RuneRarity, rune::RuneStatistic};
    use game::models::battle::{entity, entity::Entity, entity::EntityImpl, entity::EntityTrait, entity::AllyOrEnemy, entity::cooldowns::CooldownsTrait};
    use game::models::battle::entity::{skill, skill::SkillImpl, skill::TargetType, skill::damage, skill::heal};
    use game::models::battle::entity::healthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::models::storage::{statistics, statistics::{runeStatistics, runeStatistics::RuneStatistics, bonusRuneStatistics, bonusRuneStatistics::BonusRuneStatistics}};
    use game::models::storage::{baseHero, baseHero::{BaseHero, BaseHeroImpl, Statistics}, heroesByRank::HeroesByRank };
    use game::systems::accounts::Accounts::AccountsImpl;

    impl EntityFactoryImpl of super::IEntityFactory {
        fn newEntities(ref world: WorldStorage, owner: ContractAddress, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity> {
            let mut entities: Array<Entity> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == heroes.len() {
                    break;
                }
                let entity = Self::newEntity(world, owner, startIndex + i, *heroes[i], allyOrEnemy);
                entities.append(entity);
                i += 1;
            };
            return entities;
        }
        fn newEntity(ref world: WorldStorage, owner: ContractAddress, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity {
            let baseHero: BaseHero = world.read_model(hero.name);
            let baseStatsValues = baseHero.computeAllStatistics(hero.level, hero.rank);
            let runesIndex = hero.getRunesIndexArray();
            let runes = AccountsImpl::getRunes(world, owner, runesIndex);
            let runesStatsValues = Self::computeRunesBonuses(world, runes, baseStatsValues);

            return entity::new(
                index,
                hero.id,
                hero.name,
                baseStatsValues.health + runesStatsValues.health,
                baseStatsValues.attack + runesStatsValues.attack,
                baseStatsValues.defense + runesStatsValues.defense,
                baseStatsValues.speed + runesStatsValues.speed,
                baseStatsValues.criticalRate + runesStatsValues.criticalRate,
                baseStatsValues.criticalDamage + runesStatsValues.criticalDamage,
                allyOrEnemy,
            );
        }

        fn computeRunesBonuses(ref world: WorldStorage, runes: Array<Rune>, baseStats: Statistics) -> Statistics {
            let mut runesTotalBonusStats = statistics::new(0, 0, 0, 0, 0, 0);
            let mut i: u32 = 0;
            loop {
                if i == runes.len() {
                    break;
                }
                let rune: Rune = *runes[i];
                let runeStatWithoutRank: RuneStatistics = world.read_model((rune.statistic, rune.rarity, rune.isPercent));
                let runeStat = runeStatWithoutRank.value + ((runeStatWithoutRank.value * rune.rank) / 10);
                matchAndAddStat(ref runesTotalBonusStats, rune.statistic, runeStat.into(), rune.isPercent, baseStats);
                if (rune.rank > 3) {
                    let bonusRank4 = rune.rank4Bonus;
                    let runeBonusStat: BonusRuneStatistics = world.read_model((bonusRank4.statistic, rune.rarity, bonusRank4.isPercent));
                    matchAndAddStat(ref runesTotalBonusStats, bonusRank4.statistic, runeBonusStat.value.into(), bonusRank4.isPercent, baseStats);
                }
                if (rune.rank > 7) {
                    let bonusRank8 = rune.rank8Bonus;
                    let runeBonusStat: BonusRuneStatistics = world.read_model((bonusRank8.statistic, rune.rarity, bonusRank8.isPercent));
                    matchAndAddStat(ref runesTotalBonusStats, bonusRank8.statistic, runeBonusStat.value.into(), bonusRank8.isPercent, baseStats);
                }
                if (rune.rank > 11) {
                    let bonusRank12 = rune.rank12Bonus;
                    let runeBonusStat: BonusRuneStatistics = world.read_model((bonusRank12.statistic, rune.rarity, bonusRank12.isPercent));
                    matchAndAddStat(ref runesTotalBonusStats, bonusRank12.statistic, runeBonusStat.value.into(), bonusRank12.isPercent, baseStats);
                }
                if (rune.rank > 15) {
                    let bonusRank16 = rune.rank16Bonus;
                    let runeBonusStat: BonusRuneStatistics = world.read_model((bonusRank16.statistic, rune.rarity, bonusRank16.isPercent));
                    matchAndAddStat(ref runesTotalBonusStats, bonusRank16.statistic, runeBonusStat.value.into(), bonusRank16.isPercent, baseStats);
                }
                i += 1;
            };
            return runesTotalBonusStats;
        }

        fn initBaseHeroesDict(ref world: WorldStorage) {
            world.write_model(BaseHero { heroName: 'sirocco', rank: 0, statistics: statistics::new(1500, 190, 120, 190, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'wellan', rank: 0, statistics: statistics::new(1500, 165, 160, 175, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'marella', rank: 0, statistics: statistics::new(1500, 150, 170, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'elandor', rank: 0, statistics: statistics::new(1500, 185, 130, 185, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'diana', rank: 0, statistics: statistics::new(1500, 185, 124, 191, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'elric', rank: 0, statistics: statistics::new(1500, 170, 160, 170, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'nereus', rank: 0, statistics: statistics::new(1500, 185, 135, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'rex', rank: 0, statistics: statistics::new(1500, 180, 160, 160, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'celeste', rank: 0, statistics: statistics::new(1500, 185, 130, 185, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'oakheart', rank: 0, statistics: statistics::new(1500, 170, 160, 170, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'sylvara', rank: 0, statistics: statistics::new(1500, 150, 170, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'bane', rank: 0, statistics: statistics::new(1500, 190, 125, 185, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'ember', rank: 0, statistics: statistics::new(1500, 165, 155, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'molten', rank: 2, statistics: statistics::new(1500, 180, 160, 160, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'solas', rank: 2, statistics: statistics::new(1500, 150, 170, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'solveig', rank: 2, statistics: statistics::new(1500, 185, 130, 185, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'janus', rank: 1, statistics: statistics::new(1500, 200, 110, 190, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'horus', rank: 1, statistics: statistics::new(1500, 165, 155, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'jabari', rank: 1, statistics: statistics::new(1500, 185, 135, 180, 10, 200), skillsCount: 3 });
            world.write_model(BaseHero { heroName: 'khamsin', rank: 1, statistics: statistics::new(1500, 180, 140, 180, 10, 200), skillsCount: 3 });
        }
        fn initHeroesByRankDict(ref world: WorldStorage) {
            world.write_model(HeroesByRank { rank: 0, heroes: array!['sirocco', 'wellan', 'marella', 'elandor', 'diana', 'elric', 'nereus', 'rex', 'celeste', 'oakheart', 'sylvara', 'bane', 'ember'] });
            world.write_model(HeroesByRank { rank: 1, heroes: array!['janus', 'horus', 'jabari', 'khamsin'] });
            world.write_model(HeroesByRank { rank: 2, heroes: array!['molten', 'solas', 'solveig'] });
        }
        fn initRunesTable(ref world: WorldStorage) {
            world.write_model(RuneStatistics { statistic: RuneStatistic::Health, rarity: RuneRarity::Common, isPercent: false, value: 300 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Attack, rarity: RuneRarity::Common, isPercent: false, value: 30 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Defense, rarity: RuneRarity::Common, isPercent: false, value: 30 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Speed, rarity: RuneRarity::Common, isPercent: false, value: 20 });

            world.write_model(RuneStatistics { statistic: RuneStatistic::Health, rarity: RuneRarity::Common, isPercent: true, value: 10 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Attack, rarity: RuneRarity::Common, isPercent: true, value: 10 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Defense, rarity: RuneRarity::Common, isPercent: true, value: 10 });
            world.write_model(RuneStatistics { statistic: RuneStatistic::Speed, rarity: RuneRarity::Common, isPercent: true, value: 10 });
        }
        fn initBonusRunesTable(ref world: WorldStorage) {
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Health, rarity: RuneRarity::Common, isPercent: false, value: 5 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Attack, rarity: RuneRarity::Common, isPercent: false, value: 5 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Defense, rarity: RuneRarity::Common, isPercent: false, value: 5 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Speed, rarity: RuneRarity::Common, isPercent: false, value: 3 });

            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Health, rarity: RuneRarity::Common, isPercent: true, value: 2 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Attack, rarity: RuneRarity::Common, isPercent: true, value: 2 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Defense, rarity: RuneRarity::Common, isPercent: true, value: 2 });
            world.write_model(BonusRuneStatistics { statistic: RuneStatistic::Speed, rarity: RuneRarity::Common, isPercent: true, value: 2 });
        }
    }

    fn matchAndAddStat(ref runesTotalBonusStats: Statistics, statType: RuneStatistic, bonusStat: u64, isPercent: bool, baseStats: Statistics) {
        if(isPercent) {
            match statType {
                RuneStatistic::Health => runesTotalBonusStats.health += (baseStats.health * bonusStat) / 100,
                RuneStatistic::Attack => runesTotalBonusStats.attack += (baseStats.attack * bonusStat) / 100,
                RuneStatistic::Defense => runesTotalBonusStats.defense += (baseStats.defense * bonusStat) / 100,
                RuneStatistic::Speed => runesTotalBonusStats.speed += (baseStats.speed * bonusStat) / 100,
            }
        }
        else {
            match statType {
                RuneStatistic::Health => runesTotalBonusStats.health += bonusStat,
                RuneStatistic::Attack => runesTotalBonusStats.attack += bonusStat,
                RuneStatistic::Defense => runesTotalBonusStats.defense += bonusStat,
                RuneStatistic::Speed => runesTotalBonusStats.speed += bonusStat,
            }
        }
    }
    
}