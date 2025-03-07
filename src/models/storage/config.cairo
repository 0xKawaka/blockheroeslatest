#[derive(Drop, Serde, Copy, Introspect)]
pub enum ConfigType {
    TimeTickEnergy,
    TimeTickPvpEnergy,
    MaxEnergy,
    MaxPvpEnergy,
    StartingCrystals,
    StartingGems,
    StartingSummonChests,
    TotalHeroesCount,
}

#[derive(Drop, Serde, Copy)]
#[dojo::model]
pub struct Config {
    #[key]
    pub key: ConfigType,
    pub value: u64,
}



fn configTypefromU64(value: u64) -> ConfigType {
    match value {
        0 => ConfigType::TimeTickEnergy,
        1 => ConfigType::TimeTickPvpEnergy,
        2 => ConfigType::MaxEnergy,
        3 => ConfigType::MaxPvpEnergy,
        4 => ConfigType::StartingCrystals,
        5 => ConfigType::StartingGems,
        6 => ConfigType::StartingSummonChests,
        7 => ConfigType::TotalHeroesCount,
        _ => panic!("Invalid value for ConfigType"),
    }
}