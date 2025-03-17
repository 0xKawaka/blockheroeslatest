// #[cfg(test)]
// pub mod entityFactoryTest {
//     use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
//     use dojo::utils::test::{spawn_test_world, deploy_contract};
//     // use game::systems::{entityFactory::{EntityFactory, EntityFactory::EntityFactoryImpl, IEntityFactoryDispatcherTrait, IEntityFactoryDispatcher}};
//     use game::systems::{entityFactory::{EntityFactory, EntityFactory::EntityFactoryImpl}};
//     use game::systems::{accounts::{Accounts, Accounts::AccountsImpl}};
//     use game::models::account::{Account, AccountImpl, AccountTrait, account};
//     use game::models::storage::statistics::{runeStatistics::rune_statistics, bonusRuneStatistics::bonus_rune_statistics};
//     use game::models::storage::{baseHero::base_hero};
//     use game::models::hero::{Hero, HeroImpl, HeroTrait};
//     use game::models::account::{heroes::{heroes, Heroes}, runes::{runes, Runes}};
//     use game::models::hero::{rune, rune::RuneRarity, rune::RuneType, rune::RuneStatistic};
//     use game::models::storage::{statistics, statistics::Statistics};
    
//     use game::models::battle::entity::skill::Skill;
//     use game::models::battle::{entity, entity::Entity, entity::EntityImpl, entity::EntityTrait, entity::AllyOrEnemy};

//     fn setup_world() -> IWorldDispatcher {
//         let mut models = array![base_hero::TEST_CLASS_HASH, rune_statistics::TEST_CLASS_HASH, bonus_rune_statistics::TEST_CLASS_HASH, heroes::TEST_CLASS_HASH, runes::TEST_CLASS_HASH, account::TEST_CLASS_HASH];
 
//         let world = spawn_test_world("game", models);
//         world
//     }

//     #[test]
//     #[available_gas(900000000)]
//     fn test() {
//         let caller = starknet::contract_address_const::<0x0>();
//         let world = setup_world();

//         EntityFactoryImpl::initBaseHeroesDict(ref world);
//         EntityFactoryImpl::initRunesTable(ref world);
//         EntityFactoryImpl::initBonusRunesTable(ref world);

//         let testrunes = array![rune::newDeterministic(0, RuneStatistic::Attack, false, RuneRarity::Common, RuneType::First)];
//         let runeBonuses = EntityFactoryImpl::computeRunesBonuses(ref world, testrunes, statistics::new(0, 0, 0, 0, 0, 0));
//         assert(runeBonuses.attack == 30, 'runeBonuses.attack == 30');
//         assert(runeBonuses.defense == 0, 'runeBonuses.defense == 0');

//         AccountsImpl::createAccount(ref world, 'testname', caller);
//         AccountsImpl::mintHero(ref world, caller);
//         AccountsImpl::mintHero(ref world, caller);
//         AccountsImpl::mintHero(ref world, caller);
//         let hero0 = AccountsImpl::getHero(ref world, caller, 0);
//         let hero1 = AccountsImpl::getHero(ref world, caller, 1);
//         let hero2 = AccountsImpl::getHero(ref world, caller, 2);

//         let entities: Array<Entity> = EntityFactoryImpl::newEntities(ref world, caller, 0, array![hero0, hero1, hero2], AllyOrEnemy::Ally);
//         println!("entity1 maxhealth: {}", entities[1].getMaxHealth());
//         println!("entity2 maxhealth: {}", entities[2].getMaxHealth());
//     }
// }