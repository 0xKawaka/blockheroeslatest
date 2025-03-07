use game::models::battle::entity::skill::damage::Damage;
use game::models::battle::entity::skill::heal::Heal;
use game::models::battle::entity::skill::TargetType;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct SkillInfos {
    #[key]
    pub name: felt252,
    pub cooldown: u8,
    pub damage: Damage,
    pub heal: Heal,
    pub targetType: TargetType,
    pub accuracy: u16,
    pub buffsCount: u16,
}
