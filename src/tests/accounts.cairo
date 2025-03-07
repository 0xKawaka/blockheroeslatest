// #[cfg(test)]
// pub mod accountsTest {
//     use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
//     use dojo::utils::test::{spawn_test_world, deploy_contract};
//     // use game::systems::{accounts::{Accounts, Accounts::AccountsImpl, IAccountsDispatcherTrait, IAccountsDispatcher}};
//     use game::systems::{accounts::{Accounts, Accounts::AccountsImpl}};
//     use game::models::account::{heroes::{heroes, Heroes}, runes::{runes, Runes}};
//     use game::models::account::{Account, AccountImpl, AccountTrait, account};
//     use game::models::hero::{Hero, HeroImpl, HeroTrait};
//     use game::models::battle::entity::skill::Skill;

//     fn setup_world() -> IWorldDispatcher {
//         let mut models = array![heroes::TEST_CLASS_HASH, runes::TEST_CLASS_HASH, account::TEST_CLASS_HASH];
//         let world = spawn_test_world("game", models);
//         world
//     }

//     #[test]
//     #[available_gas(9000000000)]
//     fn test() {
//         let caller = starknet::contract_address_const::<0x0>();
//         let world = setup_world();
//         AccountsImpl::createAccount(world, 'testname', caller);
//         let account  = AccountsImpl::getAccount(world, caller);
//         assert(account.username == 'testname', 'Account not created');

//         assert(account.runesCount > 0, 'Runes not minted');
//         assert(account.heroesCount > 0, 'Heroes not minted');

//         let startEnergy = account.energy;
//         AccountsImpl::decreaseEnergy(world, caller, 1);
//         let account  = AccountsImpl::getAccount(world, caller);
//         assert(account.energy == startEnergy - 1, 'Energy not decreased');

//         let startPvpEnergy = account.pvpEnergy;
//         AccountsImpl::decreasePvpEnergy(world, caller, 1);
//         let account  = AccountsImpl::getAccount(world, caller);
//         assert(account.pvpEnergy == startPvpEnergy - 1, 'PvpEnergy not decreased');

//         let startCrystal = account.crystals;
//         AccountsImpl::decreaseCrystals(world, caller, 21);
//         let account  = AccountsImpl::getAccount(world, caller);
//         assert(account.crystals == startCrystal - 21, 'Crystal not decreased');
//         AccountsImpl::increaseCrystals(world, caller, 23);
//         let account  = AccountsImpl::getAccount(world, caller);
//         assert(account.crystals == startCrystal + 2, 'Crystal not increased');

//         let hero = AccountsImpl::getHero(world, caller, 2);
//         AccountsImpl::addExperienceToHeroId(world, caller, 2, 20);
//         let heroAfter = AccountsImpl::getHero(world, caller, 2);
//         assert(heroAfter.experience == hero.experience + 20, 'Experience not increased');

//         let accountBefore = AccountsImpl::getAccount(world, caller);
//         AccountsImpl::mintHero(world, caller);
//         let accountAfter = AccountsImpl::getAccount(world, caller);
//         assert(accountAfter.heroesCount == accountBefore.heroesCount + 1, 'Hero not minted');
//         let hero = AccountsImpl::getHero(world, caller, accountAfter.heroesCount - 1);
//         assert(hero.level == 1, 'Hero level not 1');
//         assert(hero.id == accountAfter.heroesCount - 1, 'Hero id not correct');

//         let accountBefore = AccountsImpl::getAccount(world, caller);
//         AccountsImpl::mintHero(world, caller);
//         let accountAfter = AccountsImpl::getAccount(world, caller);
//         assert(accountAfter.heroesCount == accountBefore.heroesCount + 1, '2nd Hero not minted');
//         let hero = AccountsImpl::getHero(world, caller, accountAfter.heroesCount - 1);
//         assert(hero.level == 1, '2nd Hero level not 1');
//         assert(hero.id == accountAfter.heroesCount - 1, '2nd Hero id not correct');

//         let accountBefore = AccountsImpl::getAccount(world, caller);
//         AccountsImpl::mintRune(world, caller);
//         let accountAfter = AccountsImpl::getAccount(world, caller);
//         assert(accountAfter.runesCount == accountBefore.runesCount + 1, 'Rune not minted');
//         let rune = AccountsImpl::getRune(world, caller, accountAfter.runesCount - 1);
//         assert(rune.rank == 0, 'Rune rank not 0');
//         assert(rune.id == accountAfter.runesCount - 1, 'Rune id not correct');

//         let accountBefore = AccountsImpl::getAccount(world, caller);
//         AccountsImpl::mintRune(world, caller);
//         let accountAfter = AccountsImpl::getAccount(world, caller);
//         assert(accountAfter.runesCount == accountBefore.runesCount + 1, '2nd Rune not minted');
//         let rune = AccountsImpl::getRune(world, caller, accountAfter.runesCount - 1);
//         assert(rune.rank == 0, '2nd Rune rank not 0');
//         assert(rune.id == accountAfter.runesCount - 1, '2nd Rune id not correct');

//         let accountBefore = AccountsImpl::getAccount(world, caller);
//         AccountsImpl::upgradeRune(world, caller, 0);
//         AccountsImpl::upgradeRune(world, caller, 0);
//         let accountAfter = AccountsImpl::getAccount(world, caller);
//         let rune = AccountsImpl::getRune(world, caller, 0);
//         assert(rune.rank == 2, 'Rune rank not 2');
//         assert(accountAfter.crystals < accountBefore.crystals, 'Crystal not decreased');

//         AccountsImpl::equipRune(world, caller, 1, 3);
//         let runeAfter = AccountsImpl::getRune(world, caller, 1);
//         let heroAfter = AccountsImpl::getHero(world, caller, 3);
//         assert(*heroAfter.getRunesIndexArray()[0] == 1, 'Rune not equipped');
//         assert(runeAfter.isEquipped == true, 'Rune not equipped');
//         assert(runeAfter.heroEquipped == 3, 'Rune not equipped');

//         AccountsImpl::unequipRune(world, caller, 1);
//         let runeAfter = AccountsImpl::getRune(world, caller, 1);
//         let heroAfter = AccountsImpl::getHero(world, caller, 3);
//         assert(heroAfter.getRunesIndexArray().len() == 0, 'Rune not unequipped 1');
//         assert(runeAfter.isEquipped == false, 'Rune not unequipped 2');

//         let runes = AccountsImpl::getAllRunes(world, caller);
//         let heroes = AccountsImpl::getAllHeroes(world, caller);
//         assert(runes.len() == 14, 'Runes not fetched');
//         assert(heroes.len() == 18, 'Heroes not fetched');
//     }
// }