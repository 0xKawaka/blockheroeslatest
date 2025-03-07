#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct LevelInfos {
    #[key]
    pub map: u16,
    #[key]
    pub level: u16,
    pub energyCost: u16,
    pub enemiesCount: u16,
}