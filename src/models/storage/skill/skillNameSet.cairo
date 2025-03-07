#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct SkillNameSet {
    #[key]
    pub heroName: felt252,
    #[key]
    pub index: u8,
    pub skill: felt252,
}

pub fn new(hero_name: felt252, index: u8, skill: felt252) -> SkillNameSet {
    SkillNameSet {
        heroName: hero_name,
        index: index,
        skill: skill,
    }
}