use core::option::OptionTrait;
use core::traits::Into;

pub fn rand32(seed: u64, max: u32) -> u32 {
    let multiply: u128 = 1103515245;
    let add: u128 = 12345;
    let next = (seed.into() * multiply) + add;
    let rdm128 =  (next/65536) % max.into();
    let rdm: u32 = rdm128.try_into().unwrap();
    return rdm;
}

pub fn rand8(seed: u64, max: u8) -> u8 {
    let multiply: u128 = 1103515245;
    let add: u128 = 12345;
    let next = (seed.into() * multiply) + add;
    let rdm128 =  (next/65536) % max.into();
    let rdm: u8 = rdm128.try_into().unwrap();
    return rdm;
}

pub fn rand16(seed: u64, max: u16) -> u16 {
    let multiply: u128 = 1103515245;
    let add: u128 = 12345;
    let next = (seed.into() * multiply) + add;
    let rdm128 =  (next/65536) % max.into();
    let rdm: u16 = rdm128.try_into().unwrap();
    return rdm;
}