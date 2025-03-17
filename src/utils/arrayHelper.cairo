use core::array::ArrayTrait;
use core::fmt::Display;

pub fn includes<T, +PartialEq<T>>(arr: @Array<T>, item: @T) -> bool {
    let arrLen = arr.len();
    let mut i: u32 = 0;
    let mut found: bool = false;
    loop {
        if (i >= arrLen) {
            break;
        }
        let value = arr[i];
        if (value == item) {
            found = true;
            break;
        }
        i += 1;
    };
    return found;
}

pub fn print<T, +Copy<T>, +Display<T>, +Drop<T>>(arr: @Array<T>) {
    let arrLen = arr.len();
    let mut i: u32 = 0;
    loop {
        if (i >= arrLen) {
            break;
        }
        let value: T = *arr[i];
        println!("{}", value);
        i += 1;
    }
}