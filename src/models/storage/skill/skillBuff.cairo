use game::models::battle::entity::skill::buff::Buff;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct SkillBuff {
    #[key]
    pub skillName: felt252,
    #[key]
    pub index: u16,
    pub buff: Buff,
}