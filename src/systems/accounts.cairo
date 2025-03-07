use starknet::ContractAddress;
use game::models::hero::{Hero, rune::Rune};
use game::models::account::Account;
use dojo::world::{WorldStorageTrait, WorldStorage};

trait IAccounts {
    fn equipRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32, heroId: u32);
    fn unequipRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32);
    fn upgradeRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32);
    fn mintHero(ref world: WorldStorage, accountAdrs: ContractAddress);
    fn mintRune(ref world: WorldStorage, accountAdrs: ContractAddress);
    fn createAccount(ref world: WorldStorage, username: felt252, accountAdrs: ContractAddress);
    fn addExperienceToHeroId(ref world: WorldStorage, accountAdrs: ContractAddress, heroId: u32, experience: u32);
    fn increaseSummonChests(ref world: WorldStorage, accountAdrs: ContractAddress, summonChestsToAdd: u32);
    fn decreaseEnergy(ref world: WorldStorage, accountAdrs: ContractAddress, energyCost: u16);
    fn decreasePvpEnergy(ref world: WorldStorage, accountAdrs: ContractAddress, energyCost: u16);
    fn increaseCrystals(ref world: WorldStorage, accountAdrs: ContractAddress, crystalsToAdd: u32);
    fn decreaseCrystals(ref world: WorldStorage, accountAdrs: ContractAddress, crystalsToSub: u32);
    fn getOwnedHeroesNames(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<felt252>;
    fn getAccount(ref world: WorldStorage, accountAdrs: ContractAddress) -> Account;
    fn getHero(ref world: WorldStorage, accountAdrs: ContractAddress, heroId: u32) -> Hero;
    fn getHeroes(ref world: WorldStorage, accountAdrs: ContractAddress, heroesIds: Span<u32>) -> Array<Hero>;
    fn getAllHeroes(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<Hero>;
    fn getRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32) -> Rune;
    fn getRunes(ref world: WorldStorage, accountAdrs: ContractAddress, runesIds: Array<u32>) -> Array<Rune>;
    fn getAllRunes(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<Rune>;
    fn getEnergyInfos(ref world: WorldStorage, accountAdrs: ContractAddress) -> (u16, u64);
    fn hasAccount(ref world: WorldStorage, accountAdrs: ContractAddress);
    fn isOwnerOfHeroes(ref world: WorldStorage, accountAdrs: ContractAddress, heroesIndexes: Span<u32>) -> bool;
    fn mintStarterHeroes(ref world: WorldStorage, accountAdrs: ContractAddress) -> u32;
    fn mintStarterRunes(ref world: WorldStorage, accountAdrs: ContractAddress) -> u32;
}

pub mod Accounts {
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use core::array::ArrayTrait;
    use core::option::OptionTrait;
    use core::box::BoxTrait;
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    use game::models::hero::rune::RuneTrait;
    use game::models::hero::HeroTrait;
    use game::models::{account, account::{AccountImpl, AccountTrait, Account, heroes::Heroes, runes::Runes}};
    use game::models::storage::usernames::Usernames;
    use game::models::storage::{config::{ConfigType, Config}, heroesByRank::HeroesByRank, summonRates::SummonRates, baseHero::BaseHero};
    use game::models::{hero, hero::Hero, hero::HeroImpl, hero::rune, hero::EquippedRunesImpl, hero::rune::RuneImpl, hero::rune::Rune};
    use game::models::hero::rune::{RuneStatistic, RuneRarity, RuneType};
    use game::models::events::{Event, EventKey, HeroMinted, RuneMinted, NewAccount, TimestampEnergy, TimestampPvpEnergy};
    use game::utils::random::{rand32, rand16};
    use super::IAccounts;


    #[abi(embed_v0)]
    impl AccountsImpl of super::IAccounts {
        fn equipRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32, heroId: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            assert(acc.heroesCount > heroId, 'heroId out of range');
            assert(acc.runesCount > runeId, 'runeId out of range');
            let mut heroWrapper: Heroes =  world.read_model((acc.owner, heroId));
            let mut hero = heroWrapper.hero;
            let mut runeWrapper: Runes = world.read_model((acc.owner, runeId));
            let mut rune = runeWrapper.rune;
            hero.equipRune(ref rune);
            world.write_model(Heroes {owner: acc.owner, index: heroId, hero: hero});
            world.write_model(Runes {owner: acc.owner, index: runeId, rune: rune});
        }
        fn unequipRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            assert(acc.runesCount > runeId, 'runeId out of range');
            let mut runeWrapper: Runes = world.read_model((acc.owner, runeId));
            let mut rune = runeWrapper.rune;
            assert(rune.isEquipped(), 'Rune not equipped');
            let mut heroWrapper: Heroes = world.read_model((acc.owner, rune.getHeroEquipped()));
            let mut hero = heroWrapper.hero;
            hero.unequipRune(ref rune);
            world.write_model(Heroes {owner: acc.owner, index: hero.id, hero: hero});
            world.write_model(Runes {owner: acc.owner, index: runeId, rune: rune});
        }
        fn upgradeRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            assert(acc.runesCount > runeId, 'runeId out of range');
            let mut runeWrapper: Runes = world.read_model((acc.owner, runeId));
            let mut rune = runeWrapper.rune;
            rune.upgrade(world, ref acc);
            world.write_model(Runes {owner: acc.owner, index: runeId, rune: rune});
        }
        fn mintHero(ref world: WorldStorage, accountAdrs: ContractAddress) {
            let mut acc = Self::getAccount(world, accountAdrs);
            assert(acc.summonChests > 0, 'No summon chests');
            acc.summonChests -= 1;

            let ownedHeroesNames = Self::getOwnedHeroesNames(world, accountAdrs);
            let totalHeroesCountWrapper: Config = world.read_model(ConfigType::TotalHeroesCount);
            let totalHeroesCount: u32 = totalHeroesCountWrapper.value.try_into().unwrap();
            assert(totalHeroesCount > ownedHeroesNames.len(), 'All heroes owned');

            let summonRatesWrapper: SummonRates = world.read_model(0);
            let summonRates: Array<u16> = summonRatesWrapper.rates;
            let randIndexRank: u32 = rand16(get_block_timestamp(), 100).into();
            let mut rank: u32 = summonRates.len() - 1;
            let mut sum: u32 = 0;
            loop {
                sum += (*summonRates[rank]).into();
                if randIndexRank < sum {
                    break;
                }
                rank -= 1;
            };

            loop {
                let rank16: u16 = rank.try_into().unwrap();
                let heroesPossibleWrapper: HeroesByRank = world.read_model(rank16);
                let heroesPossible: Array<felt252> = heroesPossibleWrapper.heroes;
            
                let mut notOwnedHeroesIndexes: Array<u32> = Default::default();
                let mut i: u32 = 0;
                loop {
                    if i == heroesPossible.len() {
                        break;
                    }
                    let mut j: u32 = 0;
                    let mut isOwned = false;
                    loop {
                        if j == ownedHeroesNames.len() {
                            break;
                        }
                        if heroesPossible[i] == ownedHeroesNames[j] {
                            isOwned = true;
                            break;
                        }
                        j += 1;
                    };
                    if !isOwned {
                        notOwnedHeroesIndexes.append(i);
                    }
                    i += 1;
                };

                if(notOwnedHeroesIndexes.len() > 0) {
                    let randIndex = rand32(get_block_timestamp(), notOwnedHeroesIndexes.len());
                    let heroName = *heroesPossible[*notOwnedHeroesIndexes[randIndex]];
                    let baseHeroWrapper: BaseHero = world.read_model(heroName);
                    let baseRank = baseHeroWrapper.rank;
                    world.write_model(Heroes {owner: accountAdrs, index: acc.heroesCount, hero: hero::new(acc.heroesCount, heroName, 1, baseRank)});
                    acc.heroesCount += 1;
                    world.write_model(acc);
                    world.emit_event(@HeroMinted {owner: accountAdrs, id: acc.heroesCount - 1, name: heroName});
                    break;
                }
                else if(rank == summonRates.len() - 1) {
                    break;
                }
                else {
                    rank += 1;
                }
            };
        }
        fn mintRune(ref world: WorldStorage, accountAdrs: ContractAddress) {
            let mut acc = Self::getAccount(world, accountAdrs);
            let mintedRune = rune::new(acc.runesCount);
            world.write_model(Runes {owner: accountAdrs, index: acc.runesCount, rune: mintedRune});
            acc.runesCount += 1;
            world.write_model(acc);
            world.emit_event(@RuneMinted {eventKey: EventKey::RuneMinted, owner: accountAdrs, rune: mintedRune});
        }
        fn createAccount(ref world: WorldStorage, username: felt252, accountAdrs: ContractAddress) {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            assert(acc.username == 0x0, 'wallet already has account');
            let usernameStorageWrapper: Usernames = world.read_model(username);
            let usernameStorage = usernameStorageWrapper.username;
            assert(usernameStorage.owner == 0.try_into().unwrap(), 'username already taken');
            let mut acc = account::new(username, accountAdrs, world);
            world.emit_event(@NewAccount {owner: accountAdrs, username: username});
            let heroesCount = Self::mintStarterHeroes(world, accountAdrs);
            let runesCount = Self::mintStarterRunes(world, accountAdrs);
            acc.heroesCount = heroesCount;
            acc.runesCount = runesCount;
            world.write_model(acc);
            world.write_model(Usernames {username: username, owner: accountAdrs});
        }
        fn addExperienceToHeroId(ref world: WorldStorage, accountAdrs: ContractAddress, heroId: u32, experience: u32) {
            let acc = Self::getAccount(world, accountAdrs);
            assert(acc.heroesCount > heroId, 'heroId out of range');
            let mut heroWrapper: Heroes = world.read_model((accountAdrs, heroId));
            let mut hero = heroWrapper.hero;
            hero.gainExperience(world, experience, accountAdrs);
            world.write_model(Heroes {owner: accountAdrs, index: heroId, hero: hero});
        }
        fn increaseSummonChests(ref world: WorldStorage, accountAdrs: ContractAddress, summonChestsToAdd: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            acc.increaseSummonChests(summonChestsToAdd);
            world.write_model(acc);
        }
        fn decreaseEnergy(ref world: WorldStorage, accountAdrs: ContractAddress, energyCost: u16) {
            let mut acc = Self::getAccount(world, accountAdrs);
            let timestamp:u64 = acc.updateEnergy(world);
            world.emit_event(@TimestampEnergy {eventKey: EventKey::TimestampEnergy, owner: accountAdrs, timestamp: timestamp});
            acc.decreaseEnergy(energyCost);
            world.write_model(acc);
        }
        fn decreasePvpEnergy(ref world: WorldStorage, accountAdrs: ContractAddress, energyCost: u16) {
            let mut acc = Self::getAccount(world, accountAdrs);
            let timestamp:u64 = acc.updatePvpEnergy(world);
            world.emit_event(@TimestampPvpEnergy {eventKey: EventKey::TimestampPvpEnergy, owner: accountAdrs, timestamp: timestamp});
            acc.decreasePvpEnergy(energyCost);
            world.write_model(acc);
        }
        fn increaseCrystals(ref world: WorldStorage, accountAdrs: ContractAddress, crystalsToAdd: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            acc.increaseCrystals(crystalsToAdd);
            world.write_model(acc);
        }
        fn decreaseCrystals(ref world: WorldStorage, accountAdrs: ContractAddress, crystalsToSub: u32) {
            let mut acc = Self::getAccount(world, accountAdrs);
            acc.decreaseCrystals(crystalsToSub);
            world.write_model(acc);
        }
        fn getOwnedHeroesNames(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<felt252> {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let mut heroes: Array<felt252> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == acc.heroesCount {
                    break;
                }
                let heroWrapper: Heroes = world.read_model((accountAdrs, i));
                let hero = heroWrapper.hero;
                heroes.append(hero.name);
                i += 1;
            };
            return heroes;
        }


        fn getAccount(ref world: WorldStorage, accountAdrs: ContractAddress) -> Account {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            assert(acc.owner == accountAdrs, 'Account not created');
            return acc;
        }
        fn getRune(ref world: WorldStorage, accountAdrs: ContractAddress, runeId: u32) -> Rune {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            assert(acc.runesCount > runeId, 'runeId out of range');
            let runeWrapper: Runes = world.read_model((accountAdrs, runeId));
            return runeWrapper.rune;
        }
        fn getRunes(ref world: WorldStorage, accountAdrs: ContractAddress, runesIds: Array<u32>) -> Array<Rune> {
            let mut runes: Array<Rune> = Default::default();
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let runesCount = acc.runesCount;
            let mut i: u32 = 0;
            loop {
                if i == runesIds.len() {
                    break;
                }
                let runeId: u32 = *runesIds[i];
                assert(runeId <= runesCount - 1, 'runeId out of range');
                let runeWrapper: Runes = world.read_model((accountAdrs, runeId));
                runes.append(runeWrapper.rune);
                i += 1;
            };
            return runes;
        }
        fn getAllRunes(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<Rune> {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let runesCount = acc.runesCount;
            let mut i: u32 = 0;
            let mut runes: Array<Rune> = Default::default();
            loop {
                if i == runesCount {
                    break;
                }
                let runeWrapper: Runes = world.read_model((accountAdrs, i));
                runes.append(runeWrapper.rune);
                i += 1;
            };
            return runes;
        }
        fn getHero(ref world: WorldStorage, accountAdrs: ContractAddress, heroId: u32) -> Hero {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let heroesCount = acc.heroesCount;
            assert(heroesCount > heroId, 'heroId out of range');
            let heroWrapper: Heroes = world.read_model((accountAdrs, heroId));
            return heroWrapper.hero;
        }
        fn getHeroes(ref world: WorldStorage, accountAdrs: ContractAddress, heroesIds: Span<u32>) -> Array<Hero> {
            let mut heroes: Array<Hero> = Default::default();
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let heroesCount = acc.heroesCount;
            let mut i: u32 = 0;
            loop {
                if i == heroesIds.len() {
                    break;
                }
                let heroeId: u32 = *heroesIds[i];
                assert(heroeId <= heroesCount - 1, 'heroId out of range');
                let heroWrapper: Heroes = world.read_model((accountAdrs, heroeId));
                heroes.append(heroWrapper.hero);
                i += 1;
            };
            return heroes;
        }
        fn getAllHeroes(ref world: WorldStorage, accountAdrs: ContractAddress) -> Array<Hero> {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let heroesCount = acc.heroesCount;
            let mut i: u32 = 0;
            let mut heroes: Array<Hero> = Default::default();
            loop {
                if i == heroesCount {
                    break;
                }
                let heroWrapper: Heroes = world.read_model((accountAdrs, i));
                heroes.append(heroWrapper.hero);
                i += 1;
            };
            return heroes;
        }
        fn getEnergyInfos(ref world: WorldStorage, accountAdrs: ContractAddress) -> (u16, u64) {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            return acc.getEnergyInfos();
        }
        fn hasAccount(ref world: WorldStorage, accountAdrs: ContractAddress) {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            assert(acc.username != 0x0, 'Account not found');
        }
        fn isOwnerOfHeroes(ref world: WorldStorage, accountAdrs: ContractAddress, heroesIndexes: Span<u32>) -> bool {
            let accWrapper: Account = world.read_model(accountAdrs);
            let acc = accWrapper.account;
            let heroesCount = acc.heroesCount;
            let mut i: u32 = 0;
            let mut isOwnerOfHeroes = true;
            loop {
                if i == heroesIndexes.len() {
                    break;
                }
                if(*heroesIndexes[i] >= heroesCount) {
                    isOwnerOfHeroes = false;
                    break;
                }
                i += 1;
            };
            return isOwnerOfHeroes;
        }
        fn mintStarterHeroes(ref world: WorldStorage, accountAdrs: ContractAddress) -> u32 {
            let mut heroesCount = 0;
            world.write_model(Heroes {owner: accountAdrs, index: 0, hero: hero::new(0, 'marella', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 1, hero: hero::new(1, 'sirocco', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 2, hero: hero::new(2, 'wellan', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 3, hero: hero::new(3, 'elandor', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 4, hero: hero::new(4, 'diana', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 5, hero: hero::new(5, 'elric', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 6, hero: hero::new(6, 'nereus', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 7, hero: hero::new(7, 'rex', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 8, hero: hero::new(8, 'celeste', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 9, hero: hero::new(9, 'oakheart', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 10, hero: hero::new(10, 'sylvara', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 11, hero: hero::new(11, 'bane', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 12, hero: hero::new(12, 'ember', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 13, hero: hero::new(13, 'molten', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 14, hero: hero::new(14, 'solas', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 15, hero: hero::new(15, 'solveig', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 16, hero: hero::new(16, 'janus', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 17, hero: hero::new(17, 'horus', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 18, hero: hero::new(18, 'jabari', 1, 1)});
            world.write_model(Heroes {owner: accountAdrs, index: 19, hero: hero::new(19, 'khamsin', 1, 1)});
            heroesCount = 20;
            return heroesCount;
        }
        fn mintStarterRunes(ref world: WorldStorage, accountAdrs: ContractAddress) -> u32 {
            let mut runesCount = 0;
            world.write_model(Runes {owner: accountAdrs, index: 0, rune: rune::newDeterministic(0, RuneStatistic::Attack, true, RuneRarity::Common, RuneType::Second)});
            world.write_model(Runes {owner: accountAdrs, index: 1, rune: rune::newDeterministic(1, RuneStatistic::Defense, true, RuneRarity::Common, RuneType::Fourth)});
            world.write_model(Runes {owner: accountAdrs, index: 2, rune: rune::newDeterministic(2, RuneStatistic::Health, true, RuneRarity::Common, RuneType::Fifth)});
            world.write_model(Runes {owner: accountAdrs, index: 3, rune: rune::newDeterministic(3, RuneStatistic::Speed, true, RuneRarity::Common, RuneType::Fourth)});          
            runesCount = 4;
            // world.write_model(Runes {owner: accountAdrs, index: 4, rune: rune::newDeterministic(4, RuneStatistic::Attack, true, RuneRarity::Common, RuneType::Second)});
            // world.write_model(Runes {owner: accountAdrs, index: 5, rune: rune::newDeterministic(5, RuneStatistic::Defense, true, RuneRarity::Common, RuneType::Fourth)});
            // world.write_model(Runes {owner: accountAdrs, index: 6, rune: rune::newDeterministic(6, RuneStatistic::Health, true, RuneRarity::Common, RuneType::Fifth)});
            // world.write_model(Runes {owner: accountAdrs, index: 7, rune: rune::newDeterministic(7, RuneStatistic::Speed, true, RuneRarity::Common, RuneType::Fourth)});
            // world.write_model(Runes {owner: accountAdrs, index: 8, rune: rune::newDeterministic(8, RuneStatistic::Attack, false, RuneRarity::Common, RuneType::First)});
            // world.write_model(Runes {owner: accountAdrs, index: 9, rune: rune::newDeterministic(9, RuneStatistic::Attack, true, RuneRarity::Common, RuneType::Second)});
            // world.write_model(Runes {owner: accountAdrs, index: 10, rune: rune::newDeterministic(10, RuneStatistic::Defense, false, RuneRarity::Common, RuneType::Third)});
            // world.write_model(Runes {owner: accountAdrs, index: 11, rune: rune::newDeterministic(11, RuneStatistic::Defense, false, RuneRarity::Common, RuneType::Third)});
            // runesCount = 12;
            return runesCount;
        }
    }
}