#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct ArenaCurrentRankIndex {
    #[key]
    pub id: u8,
    pub currentRankIndex: u64,
}