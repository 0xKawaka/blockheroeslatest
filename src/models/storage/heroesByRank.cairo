#[derive(Drop, Serde)]
#[dojo::model]
pub struct HeroesByRank {
    #[key]
    pub rank: u16,
    pub heroes: Array<felt252>,
}