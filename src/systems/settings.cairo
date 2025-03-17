#[dojo::contract]
pub mod Settings {
    use game::systems::skillFactory::SkillFactory::SkillFactoryImpl;
    use game::systems::levels::Levels::LevelsImpl;
    use game::systems::entityFactory::EntityFactory::EntityFactoryImpl;
    use game::systems::arena::Arena::ArenaImpl;
    use game::systems::quests::Quests::QuestsImpl;
    use game::models::storage::{config::{ConfigType, Config}, summonRates::SummonRates};

    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;

    
    fn initConfig(ref world: WorldStorage) {
        world.write_model(@Config { key: ConfigType::TimeTickEnergy, value: 1200 });
        world.write_model(@Config { key: ConfigType::TimeTickPvpEnergy, value: 1200 });
        world.write_model(@Config { key: ConfigType::MaxEnergy, value: 5 });
        world.write_model(@Config { key: ConfigType::MaxPvpEnergy, value: 5 });
        world.write_model(@Config { key: ConfigType::StartingCrystals, value: 50000 });
        world.write_model(@Config { key: ConfigType::StartingGems, value: 0 });
        world.write_model(@Config { key: ConfigType::StartingSummonChests, value: 2 });
        world.write_model(@Config { key: ConfigType::TotalHeroesCount, value: 20 });
    }

    fn initArena(ref world: WorldStorage) {
        let minRankGems = array![1, 2, 4, 10];
        let gems = array![1, 2, 4, 10];
        let minRankRange = array![5, 8, 10, 20, 30, 50, 100, 300, 500, 2000, 10000, 100000];
        let range = array![2, 3, 4, 5, 10, 15, 20, 30, 50, 100, 100, 100];
        ArenaImpl::initArena(ref world, minRankGems, gems, minRankRange, range);
    }

    fn initSettings(ref world: WorldStorage) {
        SkillFactoryImpl::initSkills(ref world);
        SkillFactoryImpl::initSkillsBuffs(ref world);
        SkillFactoryImpl::initHeroSkillNameSet(ref world);
        LevelsImpl::init(ref world);
        EntityFactoryImpl::initBaseHeroesDict(ref world);
        EntityFactoryImpl::initRunesTable(ref world);
        EntityFactoryImpl::initBonusRunesTable(ref world);
        EntityFactoryImpl::initHeroesByRankDict(ref world);
        QuestsImpl::initQuests(ref world);
        initArena(ref world);
        initConfig(ref world);
        world.write_model(@SummonRates { key: 0, rates: array![89, 10, 1]});
    }

    fn dojo_init(ref self: ContractState) {
        let mut world = self.world(@"game");
        initSettings(ref world);
    }

}