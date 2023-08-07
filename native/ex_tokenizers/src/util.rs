use rustler::Encoder;
use tokenizers::{PaddingDirection, TruncationDirection};

#[macro_export]
macro_rules! new_info {
    [$($a:ident : $b:expr),*] => {{
        let vec: Vec<(Box<dyn rustler::Encoder>, Box<dyn rustler::Encoder>)> = vec![$((Box::new(stringify!($a)), Box::new($b)),)*];
        Info(vec)
    }}
}

pub struct Info(pub Vec<(Box<dyn Encoder>, Box<dyn Encoder>)>);

impl rustler::Encoder for Info {
    fn encode<'a>(&self, env: rustler::Env<'a>) -> rustler::Term<'a> {
        rustler::Term::map_from_pairs(
            env,
            &self
                .0
                .iter()
                .map(|(k, v)| (k.encode(env), v.encode(env)))
                .collect::<Vec<_>>(),
        )
        .unwrap()
    }
}

#[derive(rustler::NifUnitEnum, Clone)]
pub enum Direction {
    Left,
    Right,
}

impl From<Direction> for PaddingDirection {
    fn from(val: Direction) -> Self {
        match val {
            Direction::Left => PaddingDirection::Left,
            Direction::Right => PaddingDirection::Right,
        }
    }
}

impl From<&Direction> for PaddingDirection {
    fn from(val: &Direction) -> Self {
        match val {
            Direction::Left => PaddingDirection::Left,
            Direction::Right => PaddingDirection::Right,
        }
    }
}

impl From<Direction> for TruncationDirection {
    fn from(val: Direction) -> Self {
        match val {
            Direction::Left => TruncationDirection::Left,
            Direction::Right => TruncationDirection::Right,
        }
    }
}

impl From<&Direction> for TruncationDirection {
    fn from(val: &Direction) -> Self {
        match val {
            Direction::Left => TruncationDirection::Left,
            Direction::Right => TruncationDirection::Right,
        }
    }
}
