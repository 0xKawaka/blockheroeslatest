use game::systems::accounts::Accounts::AccountsImpl;
use dojo::world::WorldStorage;
use starknet::ContractAddress;

const levelZeroExperienceGiven: u32 = 100;
const bonusExperiencePercentEnemyGivesPerLevel: u32 = 20;

pub fn computeAndDistributeExperience(ref world: WorldStorage, owner: ContractAddress, heroesIndexes: Array<u32>, enemyLevels: @Array<u16>) {
    let totalExperience = computeExperienceAmount(enemyLevels);
    let experiencePerHero = totalExperience / heroesIndexes.len();
    let mut i: u32 = 0;
    loop {
        if i == heroesIndexes.len() {
            break;
        }
        println!("Adding {} experience to hero {}", experiencePerHero, *heroesIndexes[i]);
        AccountsImpl::addExperienceToHeroId(ref world, owner, *heroesIndexes[i], experiencePerHero);
        i += 1;
    };
}

pub fn computeExperienceAmount(enemyLevels: @Array<u16>) -> u32 {
    let mut totalExperiennce = 0;
    let mut i: u32 = 0;
    loop {
        if i == enemyLevels.len() {
            break;
        }
        totalExperiennce += computeExperienceAmountForEnemy((*enemyLevels[i]).into());
        i += 1;
    };
    return totalExperiennce;
}

pub fn computeExperienceAmountForEnemy(enemyLevel: u32) -> u32 {
    return levelZeroExperienceGiven + (((enemyLevel - 1) * levelZeroExperienceGiven * bonusExperiencePercentEnemyGivesPerLevel) / 100);
}