pub mod runes;
pub mod heroes;

use core::traits::TryInto;

use game::models::hero::{HeroImpl};
use {starknet::ContractAddress, starknet::get_block_timestamp};

use dojo::world::WorldStorage;
use dojo::model::ModelStorage;

use game::models::storage::config::{ConfigType, Config};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Account {
    #[key]
    pub owner: ContractAddress,
    pub username: felt252,
    pub energy: u16,
    pub pvpEnergy: u16,
    pub crystals: u32,
    pub gems: u32,
    pub lastEnergyUpdateTimestamp: u64,
    pub lastPvpEnergyUpdateTimestamp: u64,
    pub runesCount: u32,
    pub heroesCount: u32,
    pub summonChests: u32,
}


pub fn new(username: felt252, owner: ContractAddress, ref world: WorldStorage) -> Account {

    let configMaxEnergy: Config = world.read_model(ConfigType::MaxEnergy);
    let configMaxPvpEnergy: Config = world.read_model(ConfigType::MaxPvpEnergy);
    let configStartingCrystals: Config = world.read_model(ConfigType::StartingCrystals);
    let configStartingGems: Config = world.read_model(ConfigType::StartingGems);
    let configStartingSummonChests: Config = world.read_model(ConfigType::StartingSummonChests);
    let maxEnergy: u16 = configMaxEnergy.value.try_into().unwrap();
    let maxPvpEnergy: u16 = configMaxPvpEnergy.value.try_into().unwrap();
    let startingCrystals: u32 = configStartingCrystals.value.try_into().unwrap();
    let startingGems: u32 = configStartingGems.value.try_into().unwrap();
    let startingSummonChests: u32 = configStartingSummonChests.value.try_into().unwrap();
    
    // let maxEnergy: u16 = get!(world, ConfigType::MaxEnergy, Config).value.try_into().unwrap();
    // let maxPvpEnergy: u16 = get!(world, ConfigType::MaxPvpEnergy, Config).value.try_into().unwrap();
    // let startingCrystals: u32 = get!(world, ConfigType::StartingCrystals, Config).value.try_into().unwrap();
    // let startingGems: u32 = get!(world, ConfigType::StartingGems, Config).value.try_into().unwrap();
    // let startingSummonChests: u32 = get!(world, ConfigType::StartingSummonChests, Config).value.try_into().unwrap();

    Account {
        owner: owner,
        username: username,
        energy: maxEnergy,
        pvpEnergy: maxPvpEnergy,
        crystals: startingCrystals,
        gems: startingGems,
        lastEnergyUpdateTimestamp: get_block_timestamp(),
        lastPvpEnergyUpdateTimestamp: get_block_timestamp(),
        runesCount: 0,
        heroesCount: 0,
        summonChests: startingSummonChests,
    }
}

pub trait AccountTrait {
    fn updateEnergy(ref self: Account, ref world: WorldStorage) -> u64;
    fn increaseSummonChests(ref self: Account, summonChestsToAdd: u32);
    fn decreaseEnergy(ref self: Account, energyCost: u16);
    fn increaseEnergy(ref self: Account, energyToAdd: u16);

    fn updatePvpEnergy(ref self: Account, ref world: WorldStorage) -> u64;
    fn decreasePvpEnergy(ref self: Account, energyCost: u16);
    fn increasePvpEnergy(ref self: Account, energyToAdd: u16);

    fn increaseCrystals(ref self: Account, crystalsToAdd: u32);
    fn decreaseCrystals(ref self: Account, crystalsToSub: u32);
    fn increaseGems(ref self: Account, gemsToAdd: u32);
    fn decreaseGems(ref self: Account, gemsToSub: u32);

    fn getEnergyInfos(self: Account) -> (u16, u64);
    fn getPvpEnergyInfos(self: Account) -> (u16, u64);
    fn print(self: Account);
}

pub impl AccountImpl of AccountTrait {
    fn updateEnergy(ref self: Account, ref world: WorldStorage) -> u64 {
        let now = get_block_timestamp();
        let configMaxEnergy: Config = world.read_model(ConfigType::MaxEnergy);
        let maxEnergy: u16 = configMaxEnergy.value.try_into().unwrap();
        // let maxEnergy: u16 = get!(world, ConfigType::MaxEnergy, Config).value.try_into().unwrap();
        
        if(self.energy >= maxEnergy) {
            self.lastEnergyUpdateTimestamp = now;
            return self.lastEnergyUpdateTimestamp;
        }

        println!("lastEnergyUpdateTimestamp {}", self.lastEnergyUpdateTimestamp);
        println!("now {}", now);

        let configTimeTickEnergy: Config = world.read_model(ConfigType::TimeTickEnergy);
        let timeTickEnergy: u64 = configTimeTickEnergy.value;
        // let timeTickEnergy: u64 = get!(world, ConfigType::TimeTickEnergy, Config).value;

        let timeDiff = now - self.lastEnergyUpdateTimestamp;
        let energyToAdd = timeDiff / timeTickEnergy;

        if(energyToAdd == 0) {
            return self.lastEnergyUpdateTimestamp;
        }
        self.energy = self.energy + energyToAdd.try_into().unwrap();

        if(self.energy >= maxEnergy) {
            self.energy = maxEnergy;
            self.lastEnergyUpdateTimestamp = now;
            return self.lastEnergyUpdateTimestamp;
        }

        let timeLeft = timeDiff % timeTickEnergy;
        self.lastEnergyUpdateTimestamp = now - timeLeft;
        return self.lastEnergyUpdateTimestamp;
    }
    fn increaseSummonChests(ref self: Account, summonChestsToAdd: u32) {
        self.summonChests = self.summonChests + summonChestsToAdd;
    }
    fn decreaseEnergy(ref self: Account, energyCost: u16) {
        assert(self.energy >= energyCost, 'Not enough energy');
        self.energy = self.energy - energyCost;
    }
    fn increaseEnergy(ref self: Account, energyToAdd: u16) {
        self.energy = self.energy + energyToAdd;
    }
    fn updatePvpEnergy(ref self: Account, ref world: WorldStorage) -> u64 {
        let now = get_block_timestamp();
        let configMaxPvpEnergy: Config = world.read_model(ConfigType::MaxPvpEnergy);
        let maxPvpEnergy: u16 = configMaxPvpEnergy.value.try_into().unwrap();
        // let maxPvpEnergy: u16 = get!(world, ConfigType::MaxPvpEnergy, Config).value.try_into().unwrap();

        if(self.pvpEnergy >= maxPvpEnergy) {
            self.lastPvpEnergyUpdateTimestamp = now;
            return self.lastPvpEnergyUpdateTimestamp;
        }

        let configTimeTickPvpEnergy: Config = world.read_model(ConfigType::TimeTickPvpEnergy);
        let timeTickPvpEnergy: u64 = configTimeTickPvpEnergy.value;
        // let timeTickPvpEnergy: u64 = get!(world, ConfigType::TimeTickPvpEnergy, Config).value;

        let timeDiff = now - self.lastPvpEnergyUpdateTimestamp;
        let energyToAdd = timeDiff / timeTickPvpEnergy;

        if(energyToAdd == 0) {
            return self.lastPvpEnergyUpdateTimestamp;
        }
        self.pvpEnergy = self.pvpEnergy + energyToAdd.try_into().unwrap();

        if(self.pvpEnergy >= maxPvpEnergy) {
            self.pvpEnergy = maxPvpEnergy;
            self.lastPvpEnergyUpdateTimestamp = now;
            return self.lastPvpEnergyUpdateTimestamp;
        }

        let timeLeft = timeDiff % timeTickPvpEnergy;
        self.lastPvpEnergyUpdateTimestamp = now - timeLeft;
        return self.lastPvpEnergyUpdateTimestamp;
    }
    fn decreasePvpEnergy(ref self: Account, energyCost: u16) {
        assert(self.pvpEnergy >= energyCost, 'Not enough pvp energy');
        self.pvpEnergy = self.pvpEnergy - energyCost;
    }
    fn increasePvpEnergy(ref self: Account, energyToAdd: u16) {
        self.pvpEnergy = self.pvpEnergy + energyToAdd;
    }
    fn increaseCrystals(ref self: Account, crystalsToAdd: u32) {
        self.crystals = self.crystals + crystalsToAdd;
    }
    fn decreaseCrystals(ref self: Account, crystalsToSub: u32) {
        assert(self.crystals >= crystalsToSub, 'Not enough crystals');
        self.crystals = self.crystals - crystalsToSub;
    }
    fn increaseGems(ref self: Account, gemsToAdd: u32) {
        self.gems = self.gems + gemsToAdd;
    }
    fn decreaseGems(ref self: Account, gemsToSub: u32) {
        assert(self.gems >= gemsToSub, 'Not enough gems');
        self.gems = self.gems - gemsToSub;
    }
    fn getEnergyInfos(self: Account) -> (u16, u64) {
        return (self.energy, self.lastEnergyUpdateTimestamp);
    }
    fn getPvpEnergyInfos(self: Account) -> (u16, u64) {
        return (self.pvpEnergy, self.lastPvpEnergyUpdateTimestamp);
    }
    fn print(self: Account) {
        println!("username {}", self.username);
        println!("energy {}", self.energy);
        println!("pvpEnergy {}", self.pvpEnergy);
        println!("crystals {}", self.crystals);
        println!("gems {}", self.gems);
        println!("runesCount {}", self.runesCount);
        println!("heroesCount {}", self.heroesCount);
        println!("summonChests {}", self.summonChests);

    }
}

