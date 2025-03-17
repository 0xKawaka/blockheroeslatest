use starknet::ContractAddress;

use game::models::hero::rune::Rune;

#[derive(Drop)]
// #[dojo::event]
pub enum Event {
    NewBattle: NewBattle,
    Skill: Skill,
    StartTurn: StartTurn,
    EndTurn: EndTurn,
    EndBattle: EndBattle,

    Loot: Loot,
    ExperienceGain: ExperienceGain,

    NewAccount: NewAccount,
    HeroMinted: HeroMinted,

    RuneMinted: RuneMinted,
    RuneUpgraded: RuneUpgraded,
    RuneBonusEvent: RuneBonusEvent,

    ArenaDefense: ArenaDefense,
    RankChange: RankChange,
    InitArena: InitArena,

    TimestampPvpEnergy: TimestampPvpEnergy,
    TimestampEnergy: TimestampEnergy,
}

#[derive(Drop, Serde, Introspect)]
pub enum EventKey {
    RuneMinted,
    TimestampEnergy,
    TimestampPvpEnergy,
}

#[derive(Destruct, Serde, Introspect)]
pub struct SkillEventParams {
    pub casterId: u32,
    pub targetId: u32,
    pub skillIndex: u8,
    pub damages: Array<IdAndValue>,
    pub heals: Array<IdAndValue>,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct NewBattle {
    #[key]
    pub owner: ContractAddress,
    pub healthsArray: Array<u64>,
}
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct BuffEvent {
    #[key]
    pub entityId: u32,
    pub name: felt252,
    pub duration: u8,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct IdAndValue {
    #[key]
    pub entityId: u32,
    pub value: u64,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct Skill {
    #[key]
    pub owner: ContractAddress,
    pub casterId: u32,
    pub targetId: u32,
    pub skillIndex: u8,
    pub damages: Array<IdAndValue>,
    pub heals: Array<IdAndValue>,
    pub deaths: Array<u32>,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct EndTurn {
    #[key]
    pub owner: ContractAddress,
    pub buffs: Array<BuffEvent>,
    pub status: Array<BuffEvent>,
    pub speeds: Array<IdAndValue>,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct TurnBarEvent {
    #[key]
    pub entityId: u32,
    pub value: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct EntityBuffEvent {
    #[key]
    pub name: felt252,
    pub duration: u8,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct StartTurn {
    #[key]
    pub owner: ContractAddress,
    pub entityId: u32,
    pub damages: Array<u64>,
    pub heals: Array<u64>,
    pub buffs: Array<EntityBuffEvent>,
    pub status: Array<EntityBuffEvent>,
    pub isDead: bool,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct EndBattle {
    #[key]
    pub owner: ContractAddress,
    pub playerHasWon: bool,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct Loot {
    #[key]
    pub owner: ContractAddress,
    pub crystals: u32,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct ExperienceGain {
    #[key]
    pub owner: ContractAddress,
    pub entityId: u32,
    pub experienceGained: u32,
    pub levelAfter: u16,
    pub experienceAfter: u32,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct NewAccount {
    #[key]
    pub owner: ContractAddress,
    pub username: felt252,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct HeroMinted {
    #[key]
    pub owner: ContractAddress,
    pub id: u32,
    pub name: felt252,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct RuneMinted {
    #[key]
    pub owner: ContractAddress,
    pub rune: Rune,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct RuneUpgraded {
    #[key]
    pub owner: ContractAddress,
    pub id: u32,
    pub rank: u32,
    pub crystalCost: u32,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct RuneBonusEvent {
    #[key]
    pub owner: ContractAddress,
    pub id: u32,
    pub rank: u32,
    pub procStat: felt252,
    pub isPercent: bool,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct ArenaDefense {
    #[key]
    pub owner: ContractAddress,
    pub heroeIds: Span<u32>,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct RankChange {
    #[key]
    pub owner: ContractAddress,
    pub rank: u64,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct InitArena {
    #[key]
    pub owner: ContractAddress,
    pub rank: u64,
    pub heroeIds: Array<u32>,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct TimestampEnergy {
    #[key]
    pub owner: ContractAddress,
    pub timestamp: u64,
}
#[derive(Drop, Serde)]
#[dojo::event]
pub struct TimestampPvpEnergy {
    #[key]
    pub owner: ContractAddress,
    pub timestamp: u64,
}