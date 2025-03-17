pub mod experienceHandler;
pub mod lootHandler;
pub mod battleFactory;

use starknet::ContractAddress;
use game::models::battle::entity::Entity;
use dojo::world::WorldStorage;

pub trait IBattles {
    fn newArenaBattle(ref world: WorldStorage, owner: ContractAddress, enemyOwner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>);
    fn newBattle(ref world: WorldStorage, owner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>, map: u16, level: u16);
    fn playArenaTurn(ref world: WorldStorage, owner: ContractAddress, spellIndex: u8, targetIndex: u32);
    fn playTurn(ref world: WorldStorage, owner: ContractAddress, map: u16, spellIndex: u8, targetIndex: u32);
}

pub mod Battles {
    use core::option::OptionTrait;
    use starknet::ContractAddress;
    use game::utils::vec::{VecTrait};

    use game::models::{battle::Battle, battle::BattleImpl, battle::BattleTrait};
    use game::models::battle::entity::{Entity, EntityImpl, skill::SkillImpl};
    use game::models::battle::entity::{turnBar::TurnBarImpl};
    use game::models::battle::entity::healthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::models::storage::battles::{healthOnTurnProcStorage::HealthOnTurnProcStorage, battleStorage::BattleStorage, entityStorage::EntityStorage, arenaBattleStorage::ArenaBattleStorage};
    use game::models::storage::arena::arenaAccount::ArenaAccount;
    use game::models::storage::mapProgress::MapProgress;
    use game::models::events::{NewBattle};
    use game::models::map::{MapTrait, Map};
    use game::systems::levels::Levels::LevelsImpl;
    use game::systems::arena::Arena::ArenaImpl;
    use game::systems::skillFactory::SkillFactory::SkillFactoryImpl;
    use super::battleFactory::BattleFactory::BattleFactoryImpl;

    use game::systems::battles::experienceHandler;
    use game::systems::battles::lootHandler;
    use dojo::world::WorldStorage;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;

    pub impl BattlesImpl of super::IBattles {
        fn newArenaBattle(ref world: WorldStorage, owner: ContractAddress, enemyOwner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>) {
            InternalBattlesImpl::initArenaBattleStorage(ref world, owner, enemyOwner, allyEntities, enemyEntities);
            let mut battle = BattleFactoryImpl::getBattle(ref world, owner, Map::Arena.toU16());
            let healthsArray = battle.getHealthsArray();
            world.emit_event(@NewBattle { owner: owner, healthsArray: healthsArray });
            battle.battleLoop(ref world);
            InternalBattlesImpl::ifArenaBattleIsOverHandle(ref world, owner, battle.isBattleOver, battle.isVictory);
            InternalBattlesImpl::storeBattleState(ref world, ref battle, owner, Map::Arena.toU16());
        }
        fn newBattle(ref world: WorldStorage, owner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>, map: u16, level: u16) {
            InternalBattlesImpl::initBattleStorage(ref world, owner, allyEntities, enemyEntities, map, level);
            let mut battle = BattleFactoryImpl::getBattle(ref world, owner, map);
            let healthsArray = battle.getHealthsArray();
            world.emit_event(@NewBattle { owner: owner, healthsArray: healthsArray });
            battle.battleLoop(ref world);
            InternalBattlesImpl::ifBattleIsOverHandle(ref world, owner, map, battle.isBattleOver, battle.isVictory);
            InternalBattlesImpl::storeBattleState(ref world, ref battle, owner, map);
        }
        fn playArenaTurn(ref world: WorldStorage, owner: ContractAddress, spellIndex: u8, targetIndex: u32) {
            let mut battle = BattleFactoryImpl::getBattle(ref world, owner, Map::Arena.toU16());
            battle.playTurn(ref world, spellIndex, targetIndex);
            InternalBattlesImpl::ifArenaBattleIsOverHandle(ref world, owner, battle.isBattleOver, battle.isVictory);
            InternalBattlesImpl::storeBattleState(ref world, ref battle, owner, Map::Arena.toU16());
        }
        fn playTurn(ref world: WorldStorage, owner: ContractAddress, map: u16, spellIndex: u8, targetIndex: u32) {
            let mut battle = BattleFactoryImpl::getBattle(ref world, owner, map);
            battle.playTurn(ref world, spellIndex, targetIndex);
            InternalBattlesImpl::ifBattleIsOverHandle(ref world, owner, map, battle.isBattleOver, battle.isVictory);
            InternalBattlesImpl::storeBattleState(ref world, ref battle, owner, map);
        }
    }

    #[generate_trait]
    impl InternalBattlesImpl of InternalBattlesTrait {
        fn getHeroesIdsByMap(ref world: WorldStorage, owner: ContractAddress, map: u16) -> Array<u32> {
            let battleStorage: BattleStorage = world.read_model((owner, map));
            let entitiesCount = battleStorage.entitiesCount;
            let mut i: u32 = 0;
            let mut heroesIds: Array<u32> = Default::default();
            loop {
                if( i == entitiesCount ) {
                    break;
                }
                let entityStorage: EntityStorage = world.read_model((owner, map, i));
                if(entityStorage.entityVal.isAlly()) {
                    heroesIds.append(entityStorage.entityVal.heroId);
                }
                i += 1;
            };
            return heroesIds;
        }
        fn ifBattleIsOverHandle(ref world: WorldStorage, owner: ContractAddress, map: u16, isBattleOver: bool, isVictory: bool) {
            if(!isBattleOver || !isVictory) {
                return;
            }
            let heroesIds = Self::getHeroesIdsByMap(ref world, owner, map);
            let battleStorage: BattleStorage = world.read_model((owner, map));
            let levels = LevelsImpl::getEnemiesLevels(ref world, map, battleStorage.level);
            experienceHandler::computeAndDistributeExperience(ref world, owner, heroesIds, @levels);
            lootHandler::computeAndDistributeLoot(ref world, owner, @levels);
            let levelProgress: MapProgress = world.read_model((owner, map));
            if(levelProgress.level == battleStorage.level){
                world.write_model(@MapProgress { owner: owner, map: map, level: battleStorage.level + 1 });
            }
        }
                
        fn ifArenaBattleIsOverHandle(ref world: WorldStorage, owner: ContractAddress, isBattleOver: bool, isVictory: bool) {
            if(!isBattleOver || !isVictory) {
                return;
            }
            let arenaBattleStorage: ArenaBattleStorage = world.read_model(owner);
            let arenaAccounnt: ArenaAccount = world.read_model(owner);
            ArenaImpl::swapRanks(ref world, owner, arenaBattleStorage.enemyOwner, arenaAccounnt.lastClaimedRewards);    
        }

        fn initArenaBattleStorage(ref world: WorldStorage, owner: ContractAddress, enemyOwner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>) {
            world.write_model(
                @ArenaBattleStorage {
                    owner: owner,
                    enemyOwner: enemyOwner,
                }
            );
            Self::initBattleStorage(ref world, owner, allyEntities, enemyEntities, Map::Arena.toU16(), 0);
        }
        fn initBattleStorage(ref world: WorldStorage, owner: ContractAddress, allyEntities: Array<Entity>, enemyEntities: Array<Entity>, map: u16, level: u16) {
            world.write_model(
                @BattleStorage {
                        owner: owner,
                        map: map,
                        level: level,
                        entitiesCount: allyEntities.len() + enemyEntities.len(),
                        aliveEntitiesCount: allyEntities.len() + enemyEntities.len(),
                        isBattleOver: false,
                        isWaitingForPlayerAction: false,
                }
            );
            let mut i: u32 = 0;
            loop {
                if( i == allyEntities.len() ) {
                    break;
                }
                world.write_model(
                    @EntityStorage {
                            owner: owner,
                            map: map,
                            entityIndex: allyEntities[i].getIndex(),
                            entityVal: *allyEntities[i],
                            healthOnTurnProcCount: 0,
                    }
                );
                i += 1;
            };
            i = 0;
            loop {
                if( i == enemyEntities.len() ) {
                    break;
                }
                world.write_model(
                    @EntityStorage {
                            owner: owner,
                            map: map,
                            entityIndex: enemyEntities[i].getIndex(),
                            entityVal: *enemyEntities[i],
                            healthOnTurnProcCount: 0,
                    }
                );
                i += 1;
            };
        }
        fn storeBattleState(ref world: WorldStorage, ref battle: Battle, owner: ContractAddress, map: u16) {
            let battleInfos: BattleStorage = world.read_model((owner, map));

            world.write_model(
                @BattleStorage {
                        owner: battleInfos.owner,
                        map: battleInfos.map,
                        level: battleInfos.level,
                        entitiesCount: battle.entities.len(),
                        aliveEntitiesCount: battle.aliveEntities.len(),
                        isBattleOver: battle.isBattleOver,
                        isWaitingForPlayerAction: battle.isWaitingForPlayerAction,
                    }
            );

            let mut i: u32 = 0;
            loop {
                if( i == battle.entities.len() ) {
                    break;
                }
                let healthOnTurnProcsEntity: Array<HealthOnTurnProc> = battle.getHealthOnTurnProcsEntity(i);
                world.write_model(
                    @EntityStorage {
                            owner: battleInfos.owner,
                            map: battleInfos.map,
                            entityIndex: battle.entities.get(i).unwrap().getIndex(),
                            entityVal: battle.entities.get(i).unwrap(),
                            healthOnTurnProcCount: healthOnTurnProcsEntity.len(),
                    }
                );
                let mut j: u32 = 0;
                loop {
                    if( j == healthOnTurnProcsEntity.len() ) {
                        break;
                    }
                    world.write_model(
                        @HealthOnTurnProcStorage {
                            owner: battleInfos.owner,
                            map: battleInfos.map,
                            entityIndex: battle.entities.get(i).unwrap().getIndex(),
                            index: j,
                            healthOnTurnProc: *healthOnTurnProcsEntity[j],
                        }
                    );
                    j += 1;
                };
                i += 1;
            };
            
        }
    }
}