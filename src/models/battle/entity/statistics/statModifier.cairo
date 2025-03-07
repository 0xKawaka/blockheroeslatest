#[derive(Copy, Drop, Serde, Introspect)]
pub struct StatModifier {
    pub value: u64,
    pub duration: u8,
}

pub fn new(value: u64, duration: u8) -> StatModifier {
    StatModifier { value, duration, }
}

pub trait StatModifierTrait {
    fn reduceDuration(ref self: StatModifier);
    fn reset(ref self: StatModifier);
    fn set(ref self: StatModifier, value: u64, duration: u8);
}

pub impl StatModifierImpl of StatModifierTrait {
    fn reduceDuration(ref self: StatModifier) {
        if self.duration > 0 {
            self.duration -= 1;
        }
    }
    fn reset(ref self: StatModifier) {
        self.duration = 0;
        self.value = 0;
    }
    fn set(ref self: StatModifier, value: u64, duration: u8) {
        self.value = value;
        self.duration = duration;
    }
}