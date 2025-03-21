use game::systems::accounts::Accounts::AccountsImpl;
use dojo::world::WorldStorage;
use dojo::event::EventStorage;
use game::models::events::{Loot};
use starknet::{ContractAddress, get_block_timestamp};
use game::utils::random::rand32;

const baseCrystalsGivenPerEnemy: u32 = 200;
const crystalsBonusPercentPerLevel: u32 = 20;
const runeLootChance: u32 = 10;

pub fn computeAndDistributeLoot(ref world: WorldStorage, owner: ContractAddress, enemyLevels: @Array<u16>) {
    let mut totalLevel: u32 = 0;
    let mut i: u32 = 0;
    let enemiesLen = enemyLevels.len();
    loop {
        if i == enemiesLen {
            break;
        }
        totalLevel += (*enemyLevels[i]).into();
        i += 1;
    };
    let crystals: u32 = baseCrystalsGivenPerEnemy * enemiesLen + ((baseCrystalsGivenPerEnemy * (totalLevel - enemiesLen) * crystalsBonusPercentPerLevel) / 100);
    AccountsImpl::increaseCrystals(ref world, owner, crystals);
    if(hasLootedRune()) {
        println!("Looted rune");
        AccountsImpl::mintRune(ref world, owner);
    }
    world.emit_event(@Loot {
        owner: owner,
        crystals: crystals,
    });
}

pub fn hasLootedRune() -> bool {
    return rand32(get_block_timestamp(), 10) < runeLootChance;
}