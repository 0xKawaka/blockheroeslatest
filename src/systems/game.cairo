use starknet::ContractAddress;

#[starknet::interface]
pub trait IGame<T> {
    fn startPvpBattle(ref self: T, enemyOwner: ContractAddress, heroesIds: Array<u32>);
    fn playArenaTurn(ref self: T, spellIndex: u8, targetIndex: u32);
    fn startBattle(ref self: T, heroesIds: Array<u32>, map: u16, level: u16);
    fn playTurn(ref self: T, map: u16, spellIndex: u8, targetIndex: u32);
    fn claimGlobalRewards(ref self: T, map: u16, mapProgressRequired: u16);
    fn initPvp(ref self: T, heroesIds: Array<u32>);
    fn setPvpTeam(ref self: T, heroesIds: Array<u32>);
    fn equipRune(ref self: T, runeId: u32, heroId: u32);
    fn unequipRune(ref self: T, runeId: u32);
    fn upgradeRune(ref self: T, runeId: u32);
    fn mintHero(ref self: T);
    fn mintRune(ref self: T);
    fn createAccount(ref self: T, username: felt252);
}

#[dojo::contract]
pub mod Game {
    use core::array::ArrayTrait;
    use starknet::{get_caller_address, ContractAddress};

    use game::systems::accounts::Accounts::AccountsImpl;
    use game::systems::entityFactory::EntityFactory::EntityFactoryImpl;
    use game::systems::levels::Levels::LevelsImpl;
    use game::systems::battles::Battles::BattlesImpl;
    use game::systems::arena::Arena::ArenaImpl;
    use game::systems::quests::Quests::QuestsImpl;
    use game::models::hero::{HeroImpl};
    use game::models::battle::entity::{EntityImpl, AllyOrEnemy};
    use game::models::storage::mapProgress::MapProgress;

    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    pub impl GameImpl of super::IGame<ContractState> {
        fn startPvpBattle(ref self: ContractState, enemyOwner: ContractAddress, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            let caller = get_caller_address();
            AccountsImpl::hasAccount(ref world, caller);
            ArenaImpl::hasAccount(ref world, caller);
            ArenaImpl::hasAccount(ref world, enemyOwner);
            ArenaImpl::assertEnemyInRange(ref world, caller, enemyOwner);
            AccountsImpl::decreasePvpEnergy(ref world, caller, 1);
            let allyHeroes = AccountsImpl::getHeroes(ref world, caller, heroesIds.span());
            let allyEntities = EntityFactoryImpl::newEntities(ref world, caller, 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroesIndex = ArenaImpl::getTeam(ref world, enemyOwner);
            let enemyHeroes = AccountsImpl::getHeroes(ref world, enemyOwner, enemyHeroesIndex.span());
            let enemyEntities = EntityFactoryImpl::newEntities(ref world, enemyOwner, allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            BattlesImpl::newArenaBattle(ref world, caller, enemyOwner, allyEntities, enemyEntities);
        }
        fn playArenaTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            let mut world = self.world(@"game");
            BattlesImpl::playArenaTurn(ref world, get_caller_address(), spellIndex, targetIndex);
        }
        fn startBattle(ref self: ContractState, heroesIds: Array<u32>, map: u16, level: u16) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(ref world, get_caller_address());
            let caller = get_caller_address();
            let mapProgress: MapProgress = world.read_model((caller, map));
            let progressLevel = mapProgress.level;
            assert(progressLevel >= level, 'level not unlocked');
            let energyCost = LevelsImpl::getEnergyCost(ref world, map, level);
            AccountsImpl::decreaseEnergy(ref world, caller, energyCost);
            let allyHeroes = AccountsImpl::getHeroes(ref world, caller, heroesIds.span());
            let allyEntities = EntityFactoryImpl::newEntities(ref world, caller, 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroes = LevelsImpl::getEnemies(ref world, map, level);
            let enemyEntities = EntityFactoryImpl::newEntities(ref world, caller, allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            BattlesImpl::newBattle(ref world, caller, allyEntities, enemyEntities, map, level);
        }
        fn playTurn(ref self: ContractState, map: u16, spellIndex: u8, targetIndex: u32) {
            let mut world = self.world(@"game");
            BattlesImpl::playTurn(ref world, get_caller_address(), map, spellIndex, targetIndex);
        }
        fn claimGlobalRewards(ref self: ContractState, map: u16, mapProgressRequired: u16) {
            let mut world = self.world(@"game");
            QuestsImpl::claimGlobalRewards(ref world, get_caller_address(), map, mapProgressRequired);
        }
        fn initPvp(ref self: ContractState, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(ref world, get_caller_address());
            ArenaImpl::hasNoAccount(ref world, get_caller_address());
            AccountsImpl::isOwnerOfHeroes(ref world, get_caller_address(), heroesIds.span());
            ArenaImpl::initAccount(ref world, get_caller_address(), heroesIds);
        }
        fn setPvpTeam(ref self: ContractState, heroesIds: Array<u32>) {
            let mut world = self.world(@"game");
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            AccountsImpl::hasAccount(ref world, get_caller_address());
            AccountsImpl::isOwnerOfHeroes(ref world, get_caller_address(), heroesIds.span());
            ArenaImpl::setTeam(ref world, get_caller_address(), heroesIds.span());
        }
        fn equipRune(ref self: ContractState, runeId: u32, heroId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::equipRune(ref world, get_caller_address(), runeId, heroId);
        }
        fn unequipRune(ref self: ContractState, runeId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::unequipRune(ref world, get_caller_address(), runeId);
        }
        fn upgradeRune(ref self: ContractState, runeId: u32) {
            let mut world = self.world(@"game");
            AccountsImpl::upgradeRune(ref world, get_caller_address(), runeId);
        }
        fn mintHero(ref self: ContractState) {
            let mut world = self.world(@"game");
            AccountsImpl::mintHero(ref world, get_caller_address());
        }
        fn mintRune(ref self: ContractState) {
            let mut world = self.world(@"game");
            AccountsImpl::mintRune(ref world, get_caller_address());
        }
        fn createAccount(ref self: ContractState, username: felt252) {
            let mut world = self.world(@"game");
            AccountsImpl::createAccount(ref world, username, get_caller_address());
        }
    }
}