#[dojo::contract]
pub mod Settings {
    use game::systems::skillFactory::SkillFactory::SkillFactoryImpl;
    use game::systems::levels::Levels::LevelsImpl;
    use game::systems::entityFactory::EntityFactory::EntityFactoryImpl;
    use game::systems::entityFactory::EntityFactory;
    use game::systems::arena::Arena::ArenaImpl;
    use game::systems::quests::Quests::QuestsImpl;
    use game::models::storage::{config::{ConfigType, Config}, summonRates::SummonRates};

    use dojo::model::ModelStorage;
    use dojo::event::EventStorage;
    use dojo::world::{WorldStorageTrait, WorldStorage};
    
    fn initConfig(ref self: ContractState) {
        let mut world = self.world(@"game");
        world.write_model(Config { key: ConfigType::TimeTickEnergy, value: 1200 });
        world.write_model(Config { key: ConfigType::TimeTickPvpEnergy, value: 1200 });
        world.write_model(Config { key: ConfigType::MaxEnergy, value: 5 });
        world.write_model(Config { key: ConfigType::MaxPvpEnergy, value: 5 });
        world.write_model(Config { key: ConfigType::StartingCrystals, value: 400 });
        world.write_model(Config { key: ConfigType::StartingGems, value: 0 });
        world.write_model(Config { key: ConfigType::StartingSummonChests, value: 2 });
        world.write_model(Config { key: ConfigType::TotalHeroesCount, value: 20 });
    }

    fn initArena(ref world: WorldStorage) {
        let minRankGems = array![1, 2, 4, 10];
        let gems = array![1, 2, 4, 10];
        let minRankRange = array![5, 8, 10, 20, 30, 50, 100, 300, 500, 2000, 10000, 100000];
        let range = array![2, 3, 4, 5, 10, 15, 20, 30, 50, 100, 100, 100];
        ArenaImpl::initArena(world, minRankGems, gems, minRankRange, range);
    }

    fn initSettings(ref world: WorldStorage) {
        SkillFactoryImpl::initSkills(world);
        SkillFactoryImpl::initSkillsBuffs(world);
        SkillFactoryImpl::initHeroSkillNameSet(world);
        LevelsImpl::init(world);
        EntityFactoryImpl::initBaseHeroesDict(world);
        EntityFactoryImpl::initRunesTable(world);
        EntityFactoryImpl::initBonusRunesTable(world);
        EntityFactoryImpl::initHeroesByRankDict(world);
        QuestsImpl::initQuests(world);
        initArena(world);
        initConfig(world);
        world.write_model(SummonRates { key: 0, rates: array![89, 10, 1]});
    }

    fn dojo_init(ref self: ContractState) {
        let mut world = self.world(@"game");
        initSettings(world);
    }

}