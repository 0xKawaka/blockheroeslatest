use starknet::ContractAddress;

#[dojo::interface]
trait IGame {
    fn startPvpBattle(enemyOwner: ContractAddress, heroesIds: Array<u32>);
    fn playArenaTurn(spellIndex: u8, targetIndex: u32);
    fn startBattle(heroesIds: Array<u32>, map: u16, level: u16);
    fn playTurn(map: u16, spellIndex: u8, targetIndex: u32);
    fn claimGlobalRewards(map: u16, mapProgressRequired: u16);
    fn initPvp(heroesIds: Array<u32>);
    fn setPvpTeam(heroesIds: Array<u32>);
    fn equipRune(runeId: u32, heroId: u32);
    fn unequipRune(runeId: u32);
    fn upgradeRune(runeId: u32);
    fn mintHero();
    fn mintRune();
    fn createAccount(username: felt252);
}

#[dojo::contract]
pub mod Game {
    use core::array::ArrayTrait;
    use starknet::{get_caller_address,get_block_timestamp, ContractAddress};

    use game::systems::accounts::Accounts::AccountsImpl;
    use game::systems::entityFactory::EntityFactory::EntityFactoryImpl;
    use game::systems::levels::Levels::LevelsImpl;
    use game::systems::battles::Battles::BattlesImpl;
    use game::systems::arena::Arena::ArenaImpl;
    use game::systems::quests::Quests::QuestsImpl;
    use game::models::hero::{Hero, HeroImpl, HeroTrait};
    use game::models::battle::entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy};
    use game::models::storage::mapProgress::MapProgress;
    use game::models::map::Map;
    use alexandria_data_structures::vec::{NullableVec, NullableVecImpl, VecTrait};

    use dojo::model::ModelStorage;
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl GameImpl of super::IGame<ContractState> {
        fn startPvpBattle(ref self: ContractState, enemyOwner: ContractAddress, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            let caller = get_caller_address();
            AccountsImpl::hasAccount(world, caller);
            ArenaImpl::hasAccount(world, caller);
            ArenaImpl::hasAccount(world, enemyOwner);
            ArenaImpl::assertEnemyInRange(world, caller, enemyOwner);
            AccountsImpl::decreasePvpEnergy(world, caller, 1);
            let allyHeroes = AccountsImpl::getHeroes(world, caller, heroesIds.span());
            let allyEntities = EntityFactoryImpl::newEntities(world, caller, 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroesIndex = ArenaImpl::getTeam(world, enemyOwner);
            let enemyHeroes = AccountsImpl::getHeroes(world, enemyOwner, enemyHeroesIndex.span());
            let enemyEntities = EntityFactoryImpl::newEntities(world, enemyOwner, allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            BattlesImpl::newArenaBattle(world, caller, enemyOwner, allyEntities, enemyEntities);
        }
        fn playArenaTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            let mut world = self.world(@"game");
            BattlesImpl::playArenaTurn(world, get_caller_address(), spellIndex, targetIndex);
        }
        fn startBattle(ref self: ContractState, heroesIds: Array<u32>, map: u16, level: u16) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(world, get_caller_address());
            let caller = get_caller_address();
            let progressLevel = get!(world, (caller, map), MapProgress).level;
            assert(progressLevel >= level, 'level not unlocked');
            let energyCost = LevelsImpl::getEnergyCost(world, map, level);
            AccountsImpl::decreaseEnergy(world, caller, energyCost);
            let allyHeroes = AccountsImpl::getHeroes(world, caller, heroesIds.span());
            let allyEntities = EntityFactoryImpl::newEntities(world, caller, 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroes = LevelsImpl::getEnemies(world, map, level);
            let enemyEntities = EntityFactoryImpl::newEntities(world, caller, allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            BattlesImpl::newBattle(world, caller, allyEntities, enemyEntities, map, level);
        }
        fn playTurn(ref self: ContractState, map: u16, spellIndex: u8, targetIndex: u32) {
            let mut world = self.world(@"game");
            BattlesImpl::playTurn(world, get_caller_address(), map, spellIndex, targetIndex);
        }
        fn claimGlobalRewards(ref self: ContractState, map: u16, mapProgressRequired: u16) {
            let mut world = self.world(@"game");
            QuestsImpl::claimGlobalRewards(world, get_caller_address(), map, mapProgressRequired);
        }
        fn initPvp(ref self: ContractState, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(world, get_caller_address());
            ArenaImpl::hasNoAccount(world, get_caller_address());
            AccountsImpl::isOwnerOfHeroes(world, get_caller_address(), heroesIds.span());
            ArenaImpl::initAccount(world, get_caller_address(), heroesIds);
        }
        fn setPvpTeam(ref self: ContractState, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(world, get_caller_address());
            AccountsImpl::isOwnerOfHeroes(world, get_caller_address(), heroesIds.span());
            ArenaImpl::setTeam(world, get_caller_address(), heroesIds.span());
        }
        fn equipRune(ref self: ContractState, runeId: u32, heroId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::equipRune(world, get_caller_address(), runeId, heroId);
        }
        fn unequipRune(ref self: ContractState, runeId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::unequipRune(world, get_caller_address(), runeId);
        }
        fn upgradeRune(ref self: ContractState, runeId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::upgradeRune(world, get_caller_address(), runeId);
        }
        fn mintHero(ref self: ContractState) {
            let mut world = self.world(@"game");
            AccountsImpl::mintHero(world, get_caller_address());
        }
        fn mintRune(ref self: ContractState) {
            let mut world = self.world(@"game");
            AccountsImpl::mintRune(world, get_caller_address());
        }
        fn createAccount(ref self: ContractState, username: felt252) {
            let mut world = self.world(@"game");
            AccountsImpl::createAccount(world,  username, get_caller_address());
        }
    }
}