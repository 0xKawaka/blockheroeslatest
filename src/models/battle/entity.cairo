pub mod battleStatistics;
pub mod turnBar;
pub mod skill;
pub mod healthOnTurnProc;
pub mod stunOnTurnProc;
pub mod cooldowns;

use game::models::battle::entity::turnBar::{TurnBar};
use game::models::battle::entity::healthOnTurnProc::{DamageOrHealEnum};
use game::models::battle::entity::stunOnTurnProc::{StunOnTurnProcImpl};
use game::models::battle::entity::skill::{SkillImpl, buff::BuffType};
use game::models::battle::entity::cooldowns::{CooldownsImpl, CooldownsTrait};

use game::models::battle::entity::battleStatistics::{BattleStatisticsTrait, BattleStatisticsImpl, battleStatistic::{BattleStatisticTrait, BattleStatisticImpl}};
use game::models::battle::entity::{stunOnTurnProc::StunOnTurnProcTrait};
use game::models::battle::BattleTrait;
use game::models::battle::entity::turnBar::TurnBarTrait;
use game::models::battle::{Battle, BattleImpl};

use game::utils::vec::VecTrait;

use game::utils::random::{rand8};

use game::models::events::{Skill, EndTurn, EntityBuffEvent};

use dojo::world::WorldStorage;
use dojo::event::EventStorage;

use core::box::BoxTrait;
use starknet::get_block_timestamp;



#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum AllyOrEnemy {
    Ally,
    Enemy,
}

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Entity {
    pub index: u32,
    pub heroId: u32,
    pub name: felt252,
    pub turnBar: turnBar::TurnBar,
    pub statistics: battleStatistics::BattleStatistics,
    pub cooldowns: cooldowns::Cooldowns,
    pub stunOnTurnProc: stunOnTurnProc::StunOnTurnProc,
    pub allyOrEnemy: AllyOrEnemy,
}

pub fn new(index: u32, heroId: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64, allyOrEnemy: AllyOrEnemy) -> Entity {
    Entity {
        index: index,
        heroId: heroId,
        name: name,
        statistics: battleStatistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: turnBar::new(index, speed),
        cooldowns: cooldowns::new(),
        stunOnTurnProc: stunOnTurnProc::new(0),
        allyOrEnemy: allyOrEnemy,
    }
}

pub trait EntityTrait {
    fn playTurn(ref self: Entity, ref world: WorldStorage, ref battle: Battle);
    fn playTurnPlayer(ref self: Entity, ref world: WorldStorage, skillIndex: u8, targetIndex: u32, ref battle: Battle);
    fn endTurn(ref self: Entity, ref world: WorldStorage, ref battle: Battle);
    fn die(ref self: Entity, ref battle: Battle);
    fn pickSkill(ref self: Entity, skillsCount: u8) -> u8;
    fn takeDamage(ref self: Entity, damage: u64);
    fn takeHeal(ref self: Entity, heal: u64);
    fn takeHealAllowOverheal(ref self: Entity, heal: u64);
    fn setMaxHealthIfHealthIsGreater(ref self: Entity);
    fn incrementTurnbar(ref self: Entity);
    fn updateTurnBarSpeed(ref self: Entity);
    fn processEndTurnProcs(ref self: Entity, ref battle: Battle);
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8);
    fn applyPoison(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyRegen(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyStun(ref self: Entity, duration: u8);
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8);
    // fn randCrit(ref self: Entity) -> bool;
    fn isStunned(ref self: Entity) -> bool;
    fn isDead(self: @Entity) -> bool;
    fn isAlly(self: @Entity) -> bool;
    fn getEventBuffsArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatisticsBuffsArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatusArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatisticsStatusArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getIndex(self: @Entity) -> u32;
    fn getTurnBar(self: @Entity) -> @TurnBar;
    fn getAttack(self: @Entity) -> u64;
    fn getDefense(self: @Entity) -> u64;
    fn getSpeed(self: @Entity) -> u64;
    fn getCriticalChance(self: @Entity) -> u64;
    fn getCriticalDamage(self: @Entity) -> u64;
    fn getHealth(self: @Entity) -> i64;
    fn getMaxHealth(self: @Entity) -> u64;
    fn print(self: @Entity);
}

pub impl EntityImpl of EntityTrait {
    fn playTurn(ref self: Entity, ref world: WorldStorage, ref battle: Battle) {
        if(self.isDead()) {
            self.die(ref battle);
            return;
        }
        self.setMaxHealthIfHealthIsGreater();
        println!("Health {}", self.getHealth());

        self.cooldowns.reduceCooldowns();
        if(self.isStunned()){
            println!("Stunned");
            self.endTurn(ref world, ref battle);
            return;
        }
        else {
            match self.allyOrEnemy {
                AllyOrEnemy::Ally => {
                    battle.waitForPlayerAction();
                    battle.entities.set(self.getIndex(), self);
                },
                AllyOrEnemy::Enemy => {
                    let skillSet = battle.skillSets.get(self.index).unwrap().unbox();
                    let skillIndex = self.pickSkill(skillSet.len().try_into().unwrap());
                    let skill = *skillSet.get(skillIndex.into()).unwrap().unbox();
                    let skillEventParams = skill.cast(skillIndex, ref self, ref battle);
                    world.emit_event(@Skill {
                        owner: battle.owner,
                        casterId: skillEventParams.casterId,
                        targetId: skillEventParams.targetId,
                        skillIndex: skillIndex,
                        damages: skillEventParams.damages,
                        heals: skillEventParams.heals,
                        deaths: battle.checkAndProcessDeadEntities(),
                    });
                    self.endTurn(ref world, ref battle);
                },
            }
        }
    }
    fn playTurnPlayer(ref self: Entity, ref world: WorldStorage, skillIndex: u8, targetIndex: u32, ref battle: Battle) {
        let mut target = battle.getEntityByIndex(targetIndex);
        assert(!target.isDead(), 'Target is dead');
        assert(!self.cooldowns.isOnCooldown(skillIndex), 'Skill is on cooldown');
        let skillSet = battle.skillSets.get(self.index).unwrap().unbox();
        let skill = *skillSet.get(skillIndex.into()).unwrap().unbox();
        let skillEventParams = skill.castOnTarget(skillIndex, ref self, ref target, ref battle);
        world.emit_event(@Skill {
            owner: battle.owner,
            casterId: skillEventParams.casterId,
            targetId: skillEventParams.targetId,
            skillIndex: skillIndex,
            damages: skillEventParams.damages,
            heals: skillEventParams.heals,
            deaths: battle.checkAndProcessDeadEntities(),
        });
        self.endTurn(ref world, ref battle);
    }
    fn endTurn(ref self: Entity, ref world: WorldStorage, ref battle: Battle) {
        // self.setMaxHealthIfHealthIsGreater();
        self.processEndTurnProcs(ref battle);
        self.turnBar.resetTurn();
        battle.entities.set(self.getIndex(), self);
        world.emit_event(@EndTurn {
            owner: battle.owner,
            buffs: battle.getEventBuffsArray(),
            status: battle.getEventStatusArray(),
            speeds: battle.getEventSpeedsArray(),
        });
    }
    fn die(ref self: Entity, ref battle: Battle) {
        println!("Death {}", self.index);
        battle.deadEntities.append(self.getIndex());
        battle.entities.set(self.getIndex(), self);

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveEntities.len()) {
                break;
            }
            let entityIndex = battle.aliveEntities.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveEntities.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.turnTimeline.len()) {
                break;
            }
            let entityIndex = battle.turnTimeline.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.turnTimeline.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveAlliesIndexes.len()) {
                break;
            }
            let entityIndex = battle.aliveAlliesIndexes.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveAlliesIndexes.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveEnemiesIndexes.len()) {
                break;
            }
            let entityIndex = battle.aliveEnemiesIndexes.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveEnemiesIndexes.remove(i);
                break;
            }
            i = i + 1;
        };
    }
    fn pickSkill(ref self: Entity, skillsCount: u8) -> u8 {
        let mut seed = get_block_timestamp();
        if(skillsCount == 1) {
            return 0;
        }

        let mut skillsNotOnCd: Array<u8> = array![0];
        let mut i: u8 = 1;
        loop {
            if(i >= skillsCount) {
                break;
            }
            if(!self.cooldowns.isOnCooldown(i)) {
                skillsNotOnCd.append(i);
            }
            i = i + 1;
        };
        if(skillsNotOnCd.len() == 1) {
            return 0;
        }
        let skillsNotOnCdIndex = rand8(seed, skillsNotOnCd.len().try_into().unwrap());
        let skillIndex = *skillsNotOnCd[skillsNotOnCdIndex.into()];
        return skillIndex;
    }
    fn takeDamage(ref self: Entity, damage: u64) {
        self.statistics.health -= damage.try_into().unwrap();
    }
    fn takeHeal(ref self: Entity, heal: u64) {
        self.statistics.health += heal.try_into().unwrap();
        self.setMaxHealthIfHealthIsGreater();
    }
    fn takeHealAllowOverheal(ref self: Entity, heal: u64) {
        self.statistics.health += heal.try_into().unwrap();
    }
    fn setMaxHealthIfHealthIsGreater(ref self: Entity) {
        let maxHeathSigned: i64 = self.getMaxHealth().try_into().unwrap();
        if(self.statistics.health > maxHeathSigned) {
            self.statistics.health = maxHeathSigned;
        }
    }
    fn incrementTurnbar(ref self: Entity) {
        self.turnBar.incrementTurnbar();
    }
    fn updateTurnBarSpeed(ref self: Entity) {
        self.turnBar.setSpeed(self.getSpeed());
    }
    fn processEndTurnProcs(ref self: Entity, ref battle: Battle) {
        if(self.isStunned()) {
            self.stunOnTurnProc.proc();
        }
        self.statistics.reduceBuffsStatusDuration();
    }
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8) {
        self.statistics.applyStatModifier(buffType, value, duration);
    }
    fn applyPoison(ref self: Entity, ref battle: Battle, value: u64, duration: u8) {
        battle.healthOnTurnProcs.push(healthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Damage));
    }
    fn applyRegen(ref self: Entity, ref battle: Battle, value: u64, duration: u8) {
        battle.healthOnTurnProcs.push(healthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Heal));
    }
    fn applyStun(ref self: Entity, duration: u8) {
        self.stunOnTurnProc.setStunned(duration);
    }
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8) {
        self.cooldowns.setCooldown(skillIndex, duration);
    }
    fn isStunned(ref self: Entity) -> bool {
        self.stunOnTurnProc.isStunned()
    }
    fn isDead(self: @Entity) -> bool {
        // println!("isDead health: {} {}", self.statistics.getHealth().sign, self.statistics.getHealth().mag);
        if(self.statistics.getHealth() < 0) {
        // if (self.statistics.getHealth().min(i64Impl::new(0, false)) == self.statistics.getHealth()) {
            return true;
        }
        return false;
    }
    fn isAlly(self: @Entity) -> bool {
        return *self.allyOrEnemy == AllyOrEnemy::Ally;
    }
    fn getEventBuffsArray(self: Entity) -> Array<EntityBuffEvent> {
        return self.getEventStatisticsBuffsArray();
    }
    fn getEventStatisticsBuffsArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut buffsArray: Array<EntityBuffEvent> = Default::default();
        if(self.statistics.attack.getBonusValue() > 0 && self.statistics.attack.getBonusDuration() > 0) {
            buffsArray.append(EntityBuffEvent { name: 'attack', duration: self.statistics.attack.getBonusDuration() });
        }
        if(self.statistics.defense.getBonusValue() > 0 && self.statistics.defense.getBonusDuration() > 0) {
            buffsArray.append(EntityBuffEvent { name: 'defense', duration: self.statistics.defense.getBonusDuration() });
        }
        if(self.statistics.speed.getBonusValue() > 0 && self.statistics.speed.getBonusDuration() > 0) {
            buffsArray.append(EntityBuffEvent { name: 'speed', duration: self.statistics.speed.getBonusDuration() });
        }
        return buffsArray;
    }
    fn getEventStatusArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut statusArray: Array<EntityBuffEvent> = self.getEventStatisticsStatusArray();
        if(self.stunOnTurnProc.isStunned()){
            statusArray.append(EntityBuffEvent { name: 'stun', duration: self.stunOnTurnProc.duration })
        }
        return statusArray;
    }
    fn getEventStatisticsStatusArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut statusArray: Array<EntityBuffEvent> = Default::default();
        if(self.statistics.attack.getMalusValue() > 0 && self.statistics.attack.getMalusDuration() > 0) {
            statusArray.append(EntityBuffEvent { name: 'attack', duration: self.statistics.attack.getMalusDuration() });
        }
        if(self.statistics.defense.getMalusValue() > 0 && self.statistics.defense.getMalusDuration() > 0) {
            statusArray.append(EntityBuffEvent { name: 'defense', duration: self.statistics.defense.getMalusDuration() });
        }
        if(self.statistics.speed.getMalusValue() > 0 && self.statistics.speed.getMalusDuration() > 0) {
            statusArray.append(EntityBuffEvent { name: 'speed', duration: self.statistics.speed.getMalusDuration() });
        }
        return statusArray;
    }
    fn getIndex(self: @Entity) -> u32 {
        *self.index
    }
    fn getTurnBar(self: @Entity) -> @TurnBar {
        self.turnBar
    }
    fn getAttack(self: @Entity) -> u64 {
        self.statistics.getAttack()
    }
    fn getDefense(self: @Entity) -> u64 {
        self.statistics.getDefense()
    }
    fn getSpeed(self: @Entity) -> u64 {
        self.statistics.getSpeed()
    }
    fn getCriticalChance(self: @Entity) -> u64 {
        self.statistics.getCriticalChance()
    }
    fn getCriticalDamage(self: @Entity) -> u64 {
        self.statistics.getCriticalDamage()
    }
    fn getHealth(self: @Entity) -> i64 {
        self.statistics.getHealth()
    }
    fn getMaxHealth(self: @Entity) -> u64 {
        self.statistics.getMaxHealth()
    }

    fn print(self: @Entity) {
        println!("Entity name: {}", self.name);
        println!("Entity index: {}", self.index);
        self.statistics.print();
    }
}