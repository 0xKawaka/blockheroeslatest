#[derive(Drop, Serde)]
#[dojo::model]
pub struct SummonRates {
    #[key]
    pub key: u16,
    pub rates: Array<u16>,
}