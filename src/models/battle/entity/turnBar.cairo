#[derive(Copy, Drop, Serde, Introspect)]
pub struct TurnBar {
    pub entityIndex: u32,
    pub speed: u64,
    pub turnbar: u64,
    pub incrementStep: u64,
    pub decimals: u64,
}

pub fn new(entityIndex: u32, speed: u64) -> TurnBar {
    TurnBar { entityIndex: entityIndex, speed: speed, turnbar: 0, incrementStep: 7, decimals: 10, }
}

pub trait TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar);
    fn isFull(self: TurnBar) -> bool;
    fn resetTurn(ref self: TurnBar);
    fn setSpeed(ref self: TurnBar, speed: u64);
    fn getSpeed(self: TurnBar) -> u64;
}

pub impl TurnBarImpl of TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar) {
        self.turnbar += (self.speed * self.incrementStep) / self.decimals;
    }
    fn isFull(self: TurnBar) -> bool {
        self.turnbar > 999
    }
    fn resetTurn(ref self: TurnBar) {
        self.turnbar = 0;
    }
    fn setSpeed(ref self: TurnBar, speed: u64) {
        self.speed = speed;
    }
    fn getSpeed(self: TurnBar) -> u64 {
        self.speed
    }
}