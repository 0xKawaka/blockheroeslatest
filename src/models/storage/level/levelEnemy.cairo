use game::models::hero::Hero;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct LevelEnemy {
    #[key]
    pub map: u16,
    #[key]
    pub level: u16,
    #[key]
    pub index: u16,
    pub hero: Hero,
}