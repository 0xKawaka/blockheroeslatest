#[derive(Copy, Drop, Serde, Introspect)]
pub struct Cooldowns {
    pub skill1: u8,
    pub skill2: u8,
    // skill3: u8,
}

pub fn new() -> Cooldowns {
    Cooldowns {
        skill1: 0,
        skill2: 0,
        // skill3: 0,
    }
}

pub trait CooldownsTrait {
    fn reduceCooldowns(ref self: Cooldowns);
    fn setCooldown(ref self: Cooldowns, skillIndex: u8, cooldown: u8);
    fn isOnCooldown(self: Cooldowns, skillIndex: u8) -> bool;
}

pub impl CooldownsImpl of  CooldownsTrait {
    fn reduceCooldowns(ref self: Cooldowns) {
        if(self.skill1 > 0) {
            self.skill1 -= 1;
        }
        if(self.skill2 > 0) {
            self.skill2 -= 1;
        }
        // if(self.skill3 > 0) {
        //     self.skill3 -= 1;
        // }
    }
    fn setCooldown(ref self: Cooldowns, skillIndex: u8, cooldown: u8) {
        if(skillIndex  ==  0){
            return;
        }
        if(skillIndex == 1) {
            self.skill1 = cooldown;
        }
        if(skillIndex == 2) {
            self.skill2 = cooldown;
        }
        // if(skillIndex == 3) {
        //     self.skill3 = cooldown;
        // }
    }
    fn isOnCooldown(self: Cooldowns, skillIndex: u8) -> bool {
        if(skillIndex  ==  0){
            return false;
        }
        if(skillIndex == 1) {
            return self.skill1 > 0;
        }
        if(skillIndex == 2) {
            return self.skill2 > 0;
        }
        // if(skillIndex == 3) {
        //     return self.skill3 > 0;
        // }
        return true;
    }
}