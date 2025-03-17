use core::array::ArrayTrait;
use game::utils::vec::VecTrait;

use game::models::battle::{Battle, BattleTrait};
use game::models::battle::entity::{Entity, EntityImpl, EntityTrait};
use game::models::events::{IdAndValue};


#[derive(Copy, Drop, Serde, Introspect)]
pub struct Heal {
    pub value: u64,
    pub target: bool,
    pub aoe: bool,
    pub self: bool,
    pub healType: HealType,
}

#[derive(Copy, Drop, Serde, Introspect)]
pub enum HealType {
    Flat,
    Percent,
}

pub fn new(value: u64, target: bool, aoe: bool, self: bool, healType: HealType) -> Heal {
    return Heal { value: value, target: target, aoe: aoe, self: self, healType: healType, };
}

pub trait HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue>;
    fn computeHeal(self: Heal, ref target: Entity) -> u64;
}

pub impl HealImpl of HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValue> {
        let mut healByIdArray: Array<IdAndValue> = Default::default();
        if (self.value == 0) {
            return healByIdArray;
        }

        if (self.aoe) {
            let allies = battle.getAliveAlliesOf(caster.index);
            let mut i: u32 = 0;
            loop {
                if (i >= allies.len()) {
                    break;
                }
                let mut ally = *allies[i];


                // Apply on caster direcly to prevent it being overwritten later
                if(caster.index == ally.getIndex()){
                    let heal = self.computeHeal(ref caster);
                    caster.takeHeal(heal);
                    healByIdArray.append(IdAndValue { entityId: caster.index, value: heal });
                    i += 1;
                    continue;
                }
                // Apply on target direcly to prevent it being overwritten later
                else if(target.index == ally.getIndex()) {
                    let heal = self.computeHeal(ref target);
                    target.takeHeal(heal);
                    healByIdArray.append(IdAndValue { entityId: target.index, value: heal });
                    i += 1;
                    continue;
                }

                let heal = self.computeHeal(ref ally);
                ally.takeHeal(heal);
                healByIdArray.append(IdAndValue { entityId: ally.index, value: heal });
                battle.entities.set(ally.index, ally);
                i += 1;
            }
        } else {
            if (self.self) {
                let heal = self.computeHeal(ref caster);
                caster.takeHeal(heal);
                healByIdArray.append(IdAndValue { entityId: caster.index, value: heal });
            }
            if (self.target) {
                // if already healed self and target is self, return
                if(self.self && target.index == caster.index){
                    return healByIdArray;
                }
                if(target.index == caster.index) {
                    let heal = self.computeHeal(ref caster);
                    caster.takeHeal(heal);
                    healByIdArray.append(IdAndValue { entityId: caster.index, value: heal });
                }
                else {
                    let heal = self.computeHeal(ref target);
                    target.takeHeal(heal);
                    healByIdArray.append(IdAndValue { entityId: target.index, value: heal });
                }
            }
        }
        return healByIdArray;
    }
    fn computeHeal(self: Heal, ref target: Entity) -> u64 {
        match self.healType {
            HealType::Flat => {
                return self.value;
            },
            HealType::Percent => {
                return (self.value * target.getMaxHealth()) / 100;
            },
        }
    }
}