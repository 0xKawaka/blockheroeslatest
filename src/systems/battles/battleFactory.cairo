pub mod BattleFactory {

    use core::clone::Clone;
    use game::models::battle::entity::EntityTrait;
    use starknet::ContractAddress;
    use game::models::battle::Battle;
    use game::models::storage::battles::{battleStorage::BattleStorage, arenaBattleStorage::ArenaBattleStorage, entityStorage::EntityStorage, healthOnTurnProcStorage::HealthOnTurnProcStorage};
    use game::models::{battle, battle::entity::{EntityImpl, Entity, healthOnTurnProc::HealthOnTurnProc}};
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use game::systems::skillFactory::SkillFactory::SkillFactoryImpl;


    pub trait IBattleFactory {
        fn getBattle(ref world: WorldStorage, owner: ContractAddress, map: u16) -> Battle;
        fn newBattleFromBattleInfos(ref world: WorldStorage, owner: ContractAddress, map: u16, entitiesCount: u32, isWaitingForPlayerAction: bool) -> Battle;
        fn getAlliesAndEnemies(ref world: WorldStorage, owner: ContractAddress, entities: Span<Entity>) -> (Array<u32>, Array<u32>);
        fn getAlivesAndDeadEntities(ref world: WorldStorage, owner: ContractAddress, entities: Span<Entity>) -> (Array<u32>, Array<u32>);
        fn getEntities(ref world: WorldStorage, owner: ContractAddress, map: u16, entitiesCount: u32) -> Array<Entity>;
        fn getHealthOnTurnProcs(ref world: WorldStorage, owner: ContractAddress, map: u16) -> Array<HealthOnTurnProc>;
    }

    pub impl BattleFactoryImpl of IBattleFactory {
        fn getBattle(ref world: WorldStorage, owner: ContractAddress, map: u16) -> Battle {
            let battleInfos: BattleStorage = world.read_model((owner, map));
            return Self::newBattleFromBattleInfos(world, owner, map, battleInfos.entitiesCount, battleInfos.isWaitingForPlayerAction);
        }
        fn newBattleFromBattleInfos(ref world: WorldStorage, owner: ContractAddress, map: u16, entitiesCount: u32, isWaitingForPlayerAction: bool) -> Battle {
            let entitiesArray = Self::getEntities(world, owner, map, entitiesCount);
            let entities = entitiesArray.span();
            let (aliveEntities, deadEntities) = Self::getAlivesAndDeadEntities(world, owner, entities);
            let turnTimeline = aliveEntities.clone();
            let (allies, enemies) = Self::getAlliesAndEnemies(world, owner, entities);
            let healthOnTurnProcs = Self::getHealthOnTurnProcs(world, owner, map);
            let mut entitiesNames: Array<felt252> = Default::default();
            let mut i: u32 = 0;
            loop {
                if( i == entities.len() ) {
                    break;
                }
                let entity = *entities[i];
                entitiesNames.append(entity.name);
                i += 1;
            };
            let skillSets = SkillFactoryImpl::getSkillSets(world, entitiesNames);
            let battle = battle::new(entitiesArray, aliveEntities, deadEntities, turnTimeline, allies, enemies, healthOnTurnProcs, skillSets, false, isWaitingForPlayerAction, owner);
            return battle;

        }
        fn getAlliesAndEnemies(ref world: WorldStorage, owner: ContractAddress, entities: Span<Entity>) -> (Array<u32>, Array<u32>) {
            let mut allies: Array<u32> = Default::default();
            let mut enemies: Array<u32> = Default::default();
            let mut i: u32 = 0;
            loop {
                if( i == entities.len() ) {
                    break;
                }
                if(entities[i].isAlly()) {
                    allies.append(entities[i].getIndex());
                }
                else {
                    enemies.append(entities[i].getIndex());
                }
                i += 1;
            };
            return (allies, enemies);
        }
        fn getAlivesAndDeadEntities(ref world: WorldStorage, owner: ContractAddress, entities: Span<Entity>) -> (Array<u32>, Array<u32>) {
            let mut deadEntities: Array<u32> = Default::default();
            let mut aliveEntities: Array<u32> = Default::default();
            let mut i: u32 = 0;
            loop {
                if( i == entities.len() ) {
                    break;
                }
                if(entities[i].isDead()) {
                    deadEntities.append(entities[i].getIndex());
                    println!("Dead entity {}", entities[i].getIndex());
                }
                else {
                    aliveEntities.append(entities[i].getIndex());
                    println!("Alive entity {}", entities[i].getIndex());
                }
                i += 1;
            };
            return (aliveEntities, deadEntities);
        }
        fn getEntities(ref world: WorldStorage, owner: ContractAddress, map: u16, entitiesCount: u32) -> Array<Entity> {
            let mut entities: Array<Entity> = Default::default();
            let mut i: u32 = 0;
            loop {
                if( i == entitiesCount ) {
                    break;
                }
                let entityInfos: EntityStorage = world.read_model((owner, map, i));
                entities.append(entityInfos.entityVal);
                i += 1;
            };
            return entities;
        }
        fn getHealthOnTurnProcs(ref world: WorldStorage, owner: ContractAddress, map: u16) -> Array<HealthOnTurnProc> {
            let mut healthOnTurnProcs: Array<HealthOnTurnProc> = Default::default();
            let mut i: u32 = 0;
            let battleInfos: BattleStorage = world.read_model((owner, map));
            let entitiesCount = battleInfos.entitiesCount;
            loop {
                if( i == entitiesCount ) {
                    break;
                }
                let entityInfos: EntityStorage = world.read_model((owner, map, i));
                let healthOnTurnProcsCount = entityInfos.healthOnTurnProcCount;
                let mut j: u32 = 0;
                loop {
                    if( j == healthOnTurnProcsCount ) {
                        break;
                    }
                    let healthOnTurnProcInfos: HealthOnTurnProcStorage = world.read_model((owner, map, i, j));
                    healthOnTurnProcs.append(healthOnTurnProcInfos.healthOnTurnProc);
                    j += 1;
                };
                i += 1;
            };
            return healthOnTurnProcs;
        }
    }
}