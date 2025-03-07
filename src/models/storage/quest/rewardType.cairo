#[derive(Copy, Drop, Serde, Introspect)]
pub enum RewardType {
    Summon,
    Rune,
    Crystals,
}

pub trait RewardTypeTrait {
    fn toU16(self: RewardType) -> u16;
}

pub impl RewardTypeImpl of RewardTypeTrait {
    fn toU16(self: RewardType) -> u16 {
        match self {
            RewardType::Summon => 0,
            RewardType::Rune => 1,
            RewardType::Crystals => 2,
        }
    }
}

