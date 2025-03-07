use game::models::hero::rune::{Rune, RuneImpl, RuneType};

#[derive(Introspect, Copy, Drop, Serde)]
pub struct EquippedRunes {
    pub isFirstRuneEquipped: bool,
    pub first: u32,
    pub isSecondRuneEquipped: bool,
    pub second: u32,
    pub isThirdRuneEquipped: bool,
    pub third: u32,
    pub isFourthRuneEquipped: bool,
    pub fourth: u32,
    pub isFifthRuneEquipped: bool,
    pub fifth: u32,
    pub isSixthRuneEquipped: bool,
    pub sixth: u32,
}

pub fn new() -> EquippedRunes {
    EquippedRunes {
        isFirstRuneEquipped: false,
        isSecondRuneEquipped: false,
        isThirdRuneEquipped: false,
        isFourthRuneEquipped: false,
        isFifthRuneEquipped: false,
        isSixthRuneEquipped: false,
        first: 0,
        second: 0,
        third: 0,
        fourth: 0,
        fifth: 0,
        sixth: 0,
    }
}

pub trait EquippedRunesTrait {
    fn equipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn handleEquipRune(ref self: EquippedRunes, isAnotherRuneAlreadyEquipped: bool, runeAlreadyEquippedId: u32, ref rune: Rune, heroId: u32);
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn unequipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32>;
    fn print(self: EquippedRunes);
}

pub impl EquippedRunesImpl of EquippedRunesTrait {
    fn equipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => self.handleEquipRune(self.isFirstRuneEquipped, self.first, ref rune, heroId),
            RuneType::Second => self.handleEquipRune(self.isSecondRuneEquipped, self.second, ref rune, heroId),
            RuneType::Third => self.handleEquipRune(self.isThirdRuneEquipped, self.third, ref rune, heroId),
            RuneType::Fourth => self.handleEquipRune(self.isFourthRuneEquipped, self.fourth, ref rune, heroId),
            RuneType::Fifth => self.handleEquipRune(self.isFifthRuneEquipped, self.fifth, ref rune, heroId),
            RuneType::Sixth => self.handleEquipRune(self.isSixthRuneEquipped, self.sixth, ref rune, heroId),
        }
    }
    fn handleEquipRune(ref self: EquippedRunes, isAnotherRuneAlreadyEquipped: bool, runeAlreadyEquippedId: u32, ref rune: Rune, heroId: u32) {
        // if(isAnotherRuneAlreadyEquipped) {
            // let mut runeAlreadyEquipped = runesList[runeAlreadyEquippedId];
            // runeAlreadyEquipped.unequip();
            // runesList.set(runeAlreadyEquipped.id, runeAlreadyEquipped);
            // self.equipRuneEmptySlot(ref rune, heroId);
        // } else {
            // self.equipRuneEmptySlot(ref rune, heroId);
        // }
        assert(!isAnotherRuneAlreadyEquipped, 'Rune already equipped');
        self.equipRuneEmptySlot(ref rune, heroId);
    }
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => {
                self.first = rune.id;
                self.isFirstRuneEquipped = true;
            },
            RuneType::Second => {
                self.second = rune.id;
                self.isSecondRuneEquipped = true;
            },
            RuneType::Third => {
                self.third = rune.id;
                self.isThirdRuneEquipped = true;
            },
            RuneType::Fourth => {
                self.fourth = rune.id;
                self.isFourthRuneEquipped = true;
            },
            RuneType::Fifth => {
                self.fifth = rune.id;
                self.isFifthRuneEquipped = true;
            },
            RuneType::Sixth => {
                self.sixth = rune.id;
                self.isSixthRuneEquipped = true;
            },
        }
        rune.setEquippedBy(heroId);
    }
    fn unequipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => {
                self.isFirstRuneEquipped = false;
            },
            RuneType::Second => {
                self.isSecondRuneEquipped = false;
            },
            RuneType::Third => {
                self.isThirdRuneEquipped = false;
            },
            RuneType::Fourth => {
                self.isFourthRuneEquipped = false;
            },
            RuneType::Fifth => {
                self.isFifthRuneEquipped = false;
            },
            RuneType::Sixth => {
                self.isSixthRuneEquipped = false;
            },
        }
        rune.unequip();
    }

    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32> {
        let mut runesIndexArray: Array<u32> = Default::default();
        if(self.isFirstRuneEquipped) {
            runesIndexArray.append(self.first);
        }
        if(self.isSecondRuneEquipped) {
            runesIndexArray.append(self.second);
        }
        if(self.isThirdRuneEquipped) {
            runesIndexArray.append(self.third);
        }
        if(self.isFourthRuneEquipped) {
            runesIndexArray.append(self.fourth);
        }
        if(self.isFifthRuneEquipped) {
            runesIndexArray.append(self.fifth);
        }
        if(self.isSixthRuneEquipped) {
            runesIndexArray.append(self.sixth);
        }
        return runesIndexArray;
    }
    fn print(self: EquippedRunes) {
        if(self.isFirstRuneEquipped) {
            println!("First rune equipped: {}", self.first);
        }
        if(self.isSecondRuneEquipped) {
            println!("Second rune equipped: {}", self.second);
        }
        if(self.isThirdRuneEquipped) {
            println!("Third rune equipped: {}", self.third);
        }
        if(self.isFourthRuneEquipped) {
            println!("Fourth rune equipped: {}", self.fourth);
        }
        if(self.isFifthRuneEquipped) {
            println!("Fifth rune equipped: {}", self.fifth);
        }
        if(self.isSixthRuneEquipped) {
            println!("Sixth rune equipped: {}", self.sixth);
        }
    }

}