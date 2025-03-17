use game::models::battle::entity::skill::Skill;
use dojo::world::WorldStorage;

pub trait ISkillFactory {
    fn getSkill(ref world: WorldStorage, name: felt252) -> Skill;
    fn getSkillSets(ref world: WorldStorage, names: Array<felt252>) -> Array<Array<Skill>>;
    fn getSkillSet(ref world: WorldStorage, entityName: felt252) -> Array<Skill>;
    fn initSkills(ref world: WorldStorage);
    fn initSkillsBuffs(ref world: WorldStorage);
    fn initHeroSkillNameSet(ref world: WorldStorage);
}

pub mod SkillFactory {
    use dojo::world::WorldStorage;
    use dojo::model::ModelStorage;
    use core::array::ArrayTrait;
    use game::models::battle::{entity::EntityImpl};
    use game::models::battle::entity::{skill, skill::SkillImpl, skill::Skill, skill::TargetType, skill::damage, skill::heal, skill::buff, skill::buff::Buff, skill::buff::BuffType};
    use game::models::battle::entity::healthOnTurnProc::{HealthOnTurnProcImpl};
    use game::models::storage::skill::skillInfos::SkillInfos;
    use game::models::storage::skill::{skillNameSet::SkillNameSet};
    use game::models::storage::skill::skillBuff::SkillBuff;
    use game::models::storage::baseHero::BaseHero;

    pub impl SkillFactoryImpl of super::ISkillFactory {
        fn getSkill(ref world: WorldStorage, name: felt252) -> Skill {
            let skillInfos: SkillInfos = world.read_model(name);
            let mut buffs: Array<Buff> = Default::default();
            let mut i = 0;
            loop {
                if(i == skillInfos.buffsCount) {
                    break;
                }
                let skillBuff: SkillBuff = world.read_model((name, i));
                buffs.append(skillBuff.buff);
                i += 1;
            };
            let skill = skill::new(skillInfos.name, skillInfos.cooldown, skillInfos.damage, skillInfos.heal, skillInfos.targetType, buffs.span());
            return skill;
        }
        fn getSkillSets(ref world: WorldStorage, names: Array<felt252>) -> Array<Array<Skill>> {
            let mut skills: Array<Array<Skill>> = Default::default();
            let mut i: u32 = 0;
            loop {
                if(i == names.len()) {
                    break;
                }
                let entityName = *names[i];
                skills.append(Self::getSkillSet(ref world, entityName));
                i += 1;
            };
            return skills;
        }
        fn getSkillSet(ref world: WorldStorage, entityName: felt252) -> Array<Skill> {
            let baseHero: BaseHero = world.read_model(entityName);
            let skillsCount = baseHero.skillsCount;
            let mut skillSet: Array<Skill> = Default::default();
            let mut i: u8 = 0;
            loop {
                if(i == skillsCount) {
                    break;
                }
                let skillNameSet: SkillNameSet = world.read_model((entityName, i));
                skillSet.append(Self::getSkill(ref world, skillNameSet.skill));
                i += 1;
            };
            return skillSet;
        }
        
        fn initSkills(ref world: WorldStorage) {
            world.write_model(@SkillInfos { name: 'Attack Wellan', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Fire Swing', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Fire Strike', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Marella', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Water Heal', cooldown: 3, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(8, false, true, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Water Shield', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Elandor', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Arrows Rain', cooldown: 4, damage: damage::new(100, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Forest Senses', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 2 });
            world.write_model(@SkillInfos { name: 'Attack Sirocco', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Sand Strike', cooldown: 2, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Sandstorm', cooldown: 4, damage: damage::new(100, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Diana', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Nature Call', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Wind Pierce', cooldown: 3, damage: damage::new(280, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Elric', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Holy Bastion', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Divine Hammer', cooldown: 3, damage: damage::new(230, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 2 });
            world.write_model(@SkillInfos { name: 'Attack Nereus', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Tide Strike', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Wave Slash', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Rex', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Chum Challenge', cooldown: 4, damage: damage::new(0, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 2 });
            world.write_model(@SkillInfos { name: 'Anchor Stomps', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Celeste', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Ice Shatter', cooldown: 3, damage: damage::new(150, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Snow Storm', cooldown: 4, damage: damage::new(100, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Oakheart', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Lignum Hammer', cooldown: 2, damage: damage::new(180, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Buloke Wall', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Sylvara', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Silvan Chant', cooldown: 3, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(12, false, true, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Astral Beam', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Bane', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Raging Fire', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Meteor Strike', cooldown: 3, damage: damage::new(160, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Ember', cooldown: 0, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(10, true, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Ember Infusion', cooldown: 3, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(5, true, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 2 });
            world.write_model(@SkillInfos { name: 'Fiery Shower', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Molten', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Blazing Rage', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 2 });
            world.write_model(@SkillInfos { name: 'Volcano Flurry', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Solas', cooldown: 0, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(5, true, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Wisp Infusion', cooldown: 3, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, true, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Divine Storm', cooldown: 3, damage: damage::new(280, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, true, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Solveig', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Swords Dance', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Celestial Judgement', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Janus', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Eclipse Burst', cooldown: 3, damage: damage::new(280, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Void Singularity', cooldown: 4, damage: damage::new(200, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Attack Horus', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Ankh Blessing', cooldown: 4, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Khonsu Blessing', cooldown: 3, damage: damage::new(0, false, false, false, damage::DamageType::Flat), heal: skill::heal::new(10, true, false, false, heal::HealType::Percent), targetType: TargetType::Ally, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Jabari', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Scorpion Surge', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Venom Slash', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Attack Khamsin', cooldown: 0, damage: damage::new(100, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 0 });
            world.write_model(@SkillInfos { name: 'Sand Flurry', cooldown: 3, damage: damage::new(200, true, false, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
            world.write_model(@SkillInfos { name: 'Quicksand Ambush', cooldown: 4, damage: damage::new(100, false, true, false, damage::DamageType::Flat), heal: skill::heal::new(0, false, false, false, heal::HealType::Percent), targetType: TargetType::Enemy, accuracy: 1, buffsCount: 1 });
        }

        fn initSkillsBuffs(ref world: WorldStorage) {
            world.write_model(@SkillBuff { skillName: 'Fire Swing', index: 0, buff: buff::new(BuffType::Stun, 0, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Fire Strike', index: 0, buff: buff::new(BuffType::Poison, 10, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Water Heal', index: 0, buff: buff::new(BuffType::Regen, 6, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Water Shield', index: 0, buff: buff::new(BuffType::DefenseUp, 70, 3, true, false, true) });
            world.write_model(@SkillBuff { skillName: 'Arrows Rain', index: 0, buff: buff::new(BuffType::DefenseDown, 30, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Forest Senses', index: 0, buff: buff::new(BuffType::AttackUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Forest Senses', index: 1, buff: buff::new(BuffType::SpeedUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Sand Strike', index: 0, buff: buff::new(BuffType::AttackUp, 50, 2, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Sandstorm', index: 0, buff: buff::new(BuffType::SpeedDown, 15, 3, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Nature Call', index: 0, buff: buff::new(BuffType::SpeedUp, 35, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Holy Bastion', index: 0, buff: buff::new(BuffType::DefenseUp, 45, 3, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Divine Hammer', index: 0, buff: buff::new(BuffType::SpeedDown, 40, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Divine Hammer', index: 1, buff: buff::new(BuffType::AttackDown, 40, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Tide Strike', index: 0, buff: buff::new(BuffType::AttackUp, 50, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Chum Challenge', index: 0, buff: buff::new(BuffType::DefenseUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Chum Challenge', index: 1, buff: buff::new(BuffType::AttackUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Snow Storm', index: 0, buff: buff::new(BuffType::AttackDown, 30, 2, false, true, false) },  );
            world.write_model(@SkillBuff { skillName: 'Lignum Hammer', index: 0, buff: buff::new(BuffType::Stun, 0, 1, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Buloke Wall', index: 0, buff: buff::new(BuffType::DefenseUp, 45, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Silvan Chant', index: 0, buff: buff::new(BuffType::Regen, 4, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Astral Beam', index: 0, buff: buff::new(BuffType::AttackDown, 50, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Raging Fire', index: 0, buff: buff::new(BuffType::DefenseDown, 40, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Ember Infusion', index: 0, buff: buff::new(BuffType::SpeedUp, 30, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Ember Infusion', index: 1, buff: buff::new(BuffType::AttackUp, 30, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Blazing Rage', index: 0, buff: buff::new(BuffType::DefenseUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Blazing Rage', index: 1, buff: buff::new(BuffType::AttackUp, 60, 3, false, false, true) });
            world.write_model(@SkillBuff { skillName: 'Wisp Infusion', index: 0, buff: buff::new(BuffType::SpeedUp, 40, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Swords Dance', index: 0, buff: buff::new(BuffType::AttackUp, 60, 2, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Celestial Judgement', index: 0, buff: buff::new(BuffType::DefenseDown, 40, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Ankh Blessing', index: 0, buff: buff::new(BuffType::DefenseUp, 35, 3, false, true, false) });
            world.write_model(@SkillBuff { skillName: 'Khonsu Blessing', index: 0, buff: buff::new(BuffType::Regen, 10, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Scorpion Surge', index: 0, buff: buff::new(BuffType::Stun, 0, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Venom Slash', index: 0, buff: buff::new(BuffType::Poison, 12, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Sand Flurry', index: 0, buff: buff::new(BuffType::DefenseDown, 40, 2, true, false, false) });
            world.write_model(@SkillBuff { skillName: 'Quicksand Ambush', index: 0, buff: buff::new(BuffType::SpeedDown, 20, 2, false, true, false) });
        }

        fn initHeroSkillNameSet(ref world: WorldStorage) {
            world.write_model(@SkillNameSet { heroName: 'wellan', index: 0, skill: 'Attack Wellan'});
            world.write_model(@SkillNameSet { heroName: 'wellan', index: 1, skill: 'Fire Swing'});
            world.write_model(@SkillNameSet { heroName: 'wellan', index: 2, skill: 'Fire Strike'});
            world.write_model(@SkillNameSet { heroName: 'marella', index: 0, skill: 'Attack Marella'});
            world.write_model(@SkillNameSet { heroName: 'marella', index: 1, skill: 'Water Heal'});
            world.write_model(@SkillNameSet { heroName: 'marella', index: 2, skill: 'Water Shield'});
            world.write_model(@SkillNameSet { heroName: 'elandor', index: 0, skill: 'Attack Elandor'});
            world.write_model(@SkillNameSet { heroName: 'elandor', index: 1, skill: 'Forest Senses'});
            world.write_model(@SkillNameSet { heroName: 'elandor', index: 2, skill: 'Arrows Rain'});
            world.write_model(@SkillNameSet { heroName: 'sirocco', index: 0, skill: 'Attack Sirocco'});
            world.write_model(@SkillNameSet { heroName: 'sirocco', index: 1, skill: 'Sand Strike'});
            world.write_model(@SkillNameSet { heroName: 'sirocco', index: 2, skill: 'Sandstorm'});
            world.write_model(@SkillNameSet { heroName: 'diana', index: 0, skill: 'Attack Diana'});
            world.write_model(@SkillNameSet { heroName: 'diana', index: 1, skill: 'Nature Call'});
            world.write_model(@SkillNameSet { heroName: 'diana', index: 2, skill: 'Wind Pierce'});
            world.write_model(@SkillNameSet { heroName: 'elric', index: 0, skill: 'Attack Elric'});
            world.write_model(@SkillNameSet { heroName: 'elric', index: 1, skill: 'Holy Bastion'});
            world.write_model(@SkillNameSet { heroName: 'elric', index: 2, skill: 'Divine Hammer'});
            world.write_model(@SkillNameSet { heroName: 'nereus', index: 0, skill: 'Attack Nereus'});
            world.write_model(@SkillNameSet { heroName: 'nereus', index: 1, skill: 'Tide Strike'});
            world.write_model(@SkillNameSet { heroName: 'nereus', index: 2, skill: 'Wave Slash'});
            world.write_model(@SkillNameSet { heroName: 'rex', index: 0, skill: 'Attack Rex'});
            world.write_model(@SkillNameSet { heroName: 'rex', index: 1, skill: 'Chum Challenge'});
            world.write_model(@SkillNameSet { heroName: 'rex', index: 2, skill: 'Anchor Stomps'});
            world.write_model(@SkillNameSet { heroName: 'celeste', index: 0, skill: 'Attack Celeste'});
            world.write_model(@SkillNameSet { heroName: 'celeste', index: 1, skill: 'Ice Shatter'});
            world.write_model(@SkillNameSet { heroName: 'celeste', index: 2, skill: 'Snow Storm'});
            world.write_model(@SkillNameSet { heroName: 'oakheart', index: 0, skill: 'Attack Oakheart'});
            world.write_model(@SkillNameSet { heroName: 'oakheart', index: 1, skill: 'Lignum Hammer'});
            world.write_model(@SkillNameSet { heroName: 'oakheart', index: 2, skill: 'Buloke Wall'});
            world.write_model(@SkillNameSet { heroName: 'sylvara', index: 0, skill: 'Attack Sylvara'});
            world.write_model(@SkillNameSet { heroName: 'sylvara', index: 1, skill: 'Silvan Chant'});
            world.write_model(@SkillNameSet { heroName: 'sylvara', index: 2, skill: 'Astral Beam'});
            world.write_model(@SkillNameSet { heroName: 'bane', index: 0, skill: 'Attack Bane'});
            world.write_model(@SkillNameSet { heroName: 'bane', index: 1, skill: 'Raging Fire'});
            world.write_model(@SkillNameSet { heroName: 'bane', index: 2, skill: 'Meteor Strike'});
            world.write_model(@SkillNameSet { heroName: 'ember', index: 0, skill: 'Attack Ember'});
            world.write_model(@SkillNameSet { heroName: 'ember', index: 1, skill: 'Ember Infusion'});
            world.write_model(@SkillNameSet { heroName: 'ember', index: 2, skill: 'Fiery Shower'});
            world.write_model(@SkillNameSet { heroName: 'molten', index: 0, skill: 'Attack Molten'});
            world.write_model(@SkillNameSet { heroName: 'molten', index: 1, skill: 'Blazing Rage'});
            world.write_model(@SkillNameSet { heroName: 'molten', index: 2, skill: 'Volcano Flurry'});
            world.write_model(@SkillNameSet { heroName: 'solas', index: 0, skill: 'Attack Solas'});
            world.write_model(@SkillNameSet { heroName: 'solas', index: 1, skill: 'Wisp Infusion'});
            world.write_model(@SkillNameSet { heroName: 'solas', index: 2, skill: 'Divine Storm'});
            world.write_model(@SkillNameSet { heroName: 'solveig', index: 0, skill: 'Attack Solveig'});
            world.write_model(@SkillNameSet { heroName: 'solveig', index: 1, skill: 'Swords Dance'});
            world.write_model(@SkillNameSet { heroName: 'solveig', index: 2, skill: 'Celestial Judgement'});
            world.write_model(@SkillNameSet { heroName: 'janus', index: 0, skill: 'Attack Janus'});
            world.write_model(@SkillNameSet { heroName: 'janus', index: 1, skill: 'Eclipse Burst'});
            world.write_model(@SkillNameSet { heroName: 'janus', index: 2, skill: 'Void Singularity'});
            world.write_model(@SkillNameSet { heroName: 'horus', index: 0, skill: 'Attack Horus'});
            world.write_model(@SkillNameSet { heroName: 'horus', index: 1, skill: 'Ankh Blessing'});
            world.write_model(@SkillNameSet { heroName: 'horus', index: 2, skill: 'Khonsu Blessing'});
            world.write_model(@SkillNameSet { heroName: 'jabari', index: 0, skill: 'Attack Jabari'});
            world.write_model(@SkillNameSet { heroName: 'jabari', index: 1, skill: 'Scorpion Surge'});
            world.write_model(@SkillNameSet { heroName: 'jabari', index: 2, skill: 'Venom Slash'});
            world.write_model(@SkillNameSet { heroName: 'khamsin', index: 0, skill: 'Attack Khamsin'});
            world.write_model(@SkillNameSet { heroName: 'khamsin', index: 1, skill: 'Sand Flurry'});
            world.write_model(@SkillNameSet { heroName: 'khamsin', index: 2, skill: 'Quicksand Ambush'});
        }
    }
}