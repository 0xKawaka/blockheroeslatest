// #[cfg(test)]
// pub mod levelsTest {
//     use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
//     use dojo::utils::test::{spawn_test_world, deploy_contract};
//     // use game::systems::{levels::{Levels, Levels::LevelsImpl, ILevelsDispatcherTrait, ILevelsDispatcher}};
//     use game::systems::{levels::{Levels, Levels::LevelsImpl}};
//     use game::models::storage::level::{levelEnemy::{level_enemy, LevelEnemy}, levelInfos::{level_infos, LevelInfos}};
//     use game::models::hero::{Hero, HeroImpl, HeroTrait};

//     fn setup_world() -> IWorldDispatcher {
//         let mut models = array![level_enemy::TEST_CLASS_HASH, level_infos::TEST_CLASS_HASH];
 
//         let world = spawn_test_world("game", models);
//         world
//     }

//     #[test]
//     #[available_gas(900000000)]
//     fn test_levels() {
//         let caller = starknet::contract_address_const::<0x0>();
//         let world = setup_world();
//         LevelsImpl::init(world);

//         let energyCost = LevelsImpl::getEnergyCost(world, 0, 1);
//         assert(energyCost == 1,'energyCost should be 1');
//         let enemies: Array<Hero> = LevelsImpl::getEnemies(world, 0, 1);
//         let mut i = 0;
//         loop {
//             if(i >= enemies.len()) {
//                 break;
//             }
//             let enemy = *enemies[i];
//             // let name = enemy.getName();
//             println!("enemy: {:?}", enemy.getName());
//             i += 1;
//         }
//     }
// }