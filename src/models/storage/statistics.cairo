pub mod bonusRuneStatistics;
pub mod runeStatistics;

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Statistics {
    pub health: u64,
    pub attack: u64,
    pub defense: u64,
    pub speed: u64,
    pub criticalRate: u64,
    pub criticalDamage: u64,
}

pub fn new(health: u64, attack: u64, defense: u64, speed: u64, criticalRate: u64, criticalDamage: u64) -> Statistics {
    Statistics {
        health,
        attack,
        defense,
        speed,
        criticalRate,
        criticalDamage,
    }
}