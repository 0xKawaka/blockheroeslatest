pub mod damage;
pub mod heal;
pub mod buff;

use game::models::battle::BattleTrait;
use game::models::battle::entity::skill::buff::{BuffImpl};
use game::models::battle::entity::skill::damage::{DamageImpl};
use game::models::battle::entity::skill::heal::{HealImpl};
use game::models::battle::entity::{Entity, EntityTrait};
use game::models::battle::{Battle, BattleImpl};
use game::models::events::{IdAndValue, SkillEventParams};

use game::utils::vec::VecTrait;
use game::utils::random::rand32;

use core::array::ArrayTrait;
use starknet::get_block_timestamp;


#[derive(Copy, Drop, PartialEq, Serde, Introspect)]
pub enum TargetType {
    Ally,
    Enemy,
}

#[derive(Copy, Drop, Serde)]
pub struct Skill {
    name: felt252,
    cooldown: u8,
    damage: damage::Damage,
    heal: heal::Heal,
    targetType: TargetType,
    buffs: Span<buff::Buff>
}

pub fn new(
    name: felt252,
    cooldown: u8,
    damage: damage::Damage,
    heal: heal::Heal,
    targetType: TargetType,
    buffs: Span<buff::Buff>
) -> Skill {
    Skill {
        name: name,
        cooldown: cooldown,
        damage: damage,
        heal: heal,
        targetType: targetType,
        buffs: buffs
    }
}

pub trait SkillTrait {
    fn cast(self: Skill, skillIndex: u8, ref caster: Entity, ref battle: Battle) -> SkillEventParams;
    fn castOnTarget(self: Skill, skillIndex: u8, ref caster: Entity, ref target: Entity, ref battle: Battle) -> SkillEventParams;
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue>;
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue>;
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity;
    fn print(self: @Skill);
}

pub impl SkillImpl of SkillTrait {
    fn cast(self: Skill, skillIndex: u8, ref caster: Entity, ref battle: Battle) -> SkillEventParams {
        let mut target = self.pickTarget(caster, ref battle);
        return self.castOnTarget(skillIndex, ref caster, ref target, ref battle);
    }
    fn castOnTarget(self: Skill, skillIndex: u8, ref caster: Entity, ref target: Entity, ref battle: Battle) -> SkillEventParams {
        println!("caster");
        println!("{}", caster.getIndex());
        println!("target");
        println!("{}", target.getIndex());
        println!("skill");
        println!("{}", self.name);
        match self.targetType {
            TargetType::Ally => {
                assert(battle.isAllyOf(caster.getIndex(),  target.getIndex()), 'Target should be ally');
            },
            TargetType::Enemy => {
                assert(!battle.isAllyOf(caster.getIndex(),  target.getIndex()), 'Target should be enemy');
            },
        }
        let damages = self.applyDamage(ref caster, ref target, ref battle);
        let heals = self.applyHeal(ref caster, ref target, ref battle);
        self.applyBuffs(ref caster, ref target, ref battle);
        caster.setOnCooldown(skillIndex, self.cooldown);

        // If target and caster overlap, only caster is updated
        if(target.index != caster.index) {
            battle.entities.set(target.getIndex(), target);
        }
        return SkillEventParams { casterId: caster.getIndex(), targetId: target.getIndex(), skillIndex, damages, heals};
    }
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        let  mut i: u32 = 0;
        loop {
            if (i == self.buffs.len()) {
                break;
            }
            let buff = *self.buffs[i];
            buff.apply(ref caster, ref target, ref battle);
            i += 1;
        }
    }
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue> {
        return self.damage.apply(ref caster, ref target, ref battle);
        // TODO : ADD CRIT
    }
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue> {
        return self.heal.apply(ref caster, ref target, ref battle);
    }
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity {
        let mut seed = get_block_timestamp();
        if self.targetType == TargetType::Ally {
            let allies = battle.getAliveAlliesOf(caster.getIndex());
            // println!("alliesLen");
            // println!("{}", allies.len());
            let randIndex = rand32(seed, allies.len());
            let entity = *allies.get(randIndex).unwrap().unbox();
            return entity;
        } else if self.targetType == TargetType::Enemy {
            // println!("enemiesAliveLen");
            // println!("{}", battle.aliveEnemiesIndexes.len);
            // println!("alliesAliveLen");
            // println!("{}", battle.aliveAlliesIndexes.len);
            let enemies = battle.getAliveEnemiesOf(caster.getIndex());
            let entity = *enemies.get(rand32(seed, enemies.len())).unwrap().unbox();
            return entity;
        } else {
            return caster;
        }
    }
    fn print(self: @Skill) {
        println!("Skill name: {}", self.name);
        // println!("Skill cooldown: {}", self.cooldown);
        // println!("Skill damage: {}", self.damage);
        // println!("Skill heal: {}", self.heal);
        // println!("Skill targetType: {}", self.targetType);
        // println!("Skill buffs: {}", self.buffs);
    }
}