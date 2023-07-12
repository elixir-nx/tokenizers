use rustler::{resource::ResourceArc, NifTaggedEnum};
use std::sync::RwLock;
use tokenizers::Encoding;

use crate::util::Direction;

pub struct ExTokenizersEncodingRef(pub RwLock<Encoding>);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Encoding"]
pub struct ExTokenizersEncoding {
    pub resource: ResourceArc<ExTokenizersEncodingRef>,
}

impl From<Encoding> for ExTokenizersEncoding {
    fn from(encoding: Encoding) -> Self {
        Self {
            resource: ResourceArc::new(ExTokenizersEncodingRef(RwLock::new(encoding))),
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
/// Implementation
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn encoding_get_length(encoding: ExTokenizersEncoding) -> usize {
    encoding.resource.0.read().unwrap().len()
}

#[rustler::nif]
pub fn encoding_get_n_sequences(encoding: ExTokenizersEncoding) -> usize {
    encoding.resource.0.read().unwrap().n_sequences()
}

#[rustler::nif]
pub fn encoding_set_sequence_id(encoding: ExTokenizersEncoding, seq_id: usize) {
    encoding.resource.0.write().unwrap().set_sequence_id(seq_id)
}

#[rustler::nif]
pub fn encoding_get_ids(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.read().unwrap().get_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_type_ids(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.read().unwrap().get_type_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_attention_mask(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .get_attention_mask()
        .to_vec()
}

#[rustler::nif]
pub fn encoding_get_special_tokens_mask(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .get_special_tokens_mask()
        .to_vec()
}

#[rustler::nif]
pub fn encoding_get_tokens(encoding: ExTokenizersEncoding) -> Vec<String> {
    encoding.resource.0.read().unwrap().get_tokens().to_vec()
}

#[rustler::nif]
pub fn encoding_get_word_ids(encoding: ExTokenizersEncoding) -> Vec<Option<u32>> {
    encoding.resource.0.read().unwrap().get_word_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_sequence_ids(encoding: ExTokenizersEncoding) -> Vec<Option<usize>> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .get_sequence_ids()
        .to_vec()
}

#[rustler::nif]
pub fn encoding_get_offsets(encoding: ExTokenizersEncoding) -> Vec<(usize, usize)> {
    encoding.resource.0.read().unwrap().get_offsets().to_vec()
}

#[rustler::nif]
pub fn encoding_get_overflowing(encoding: ExTokenizersEncoding) -> Vec<ExTokenizersEncoding> {
    let encoding = encoding.resource.0.read().unwrap();
    let overflowings: &Vec<Encoding> = encoding.get_overflowing();
    overflowings
        .iter()
        .map(|encoding| encoding.clone().into())
        .collect()
}

#[rustler::nif]
pub fn encoding_word_to_tokens(
    encoding: ExTokenizersEncoding,
    word: u32,
    seq_id: usize,
) -> Option<(usize, usize)> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .word_to_tokens(word, seq_id)
}

#[rustler::nif]
pub fn encoding_word_to_chars(
    encoding: ExTokenizersEncoding,
    word: u32,
    seq_id: usize,
) -> Option<(usize, usize)> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .word_to_chars(word, seq_id)
}

#[rustler::nif]
pub fn encoding_token_to_sequence(encoding: ExTokenizersEncoding, token: usize) -> Option<usize> {
    encoding.resource.0.read().unwrap().token_to_sequence(token)
}

#[rustler::nif]
pub fn encoding_token_to_chars(
    encoding: ExTokenizersEncoding,
    token: usize,
) -> Option<(usize, (usize, usize))> {
    encoding.resource.0.read().unwrap().token_to_chars(token)
}

#[rustler::nif]
pub fn encoding_token_to_word(
    encoding: ExTokenizersEncoding,
    token: usize,
) -> Option<(usize, u32)> {
    encoding.resource.0.read().unwrap().token_to_word(token)
}

#[rustler::nif]
pub fn encoding_char_to_token(
    encoding: ExTokenizersEncoding,
    position: usize,
    seq_id: usize,
) -> Option<usize> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .char_to_token(position, seq_id)
}

#[rustler::nif]
pub fn encoding_char_to_word(
    encoding: ExTokenizersEncoding,
    position: usize,
    seq_id: usize,
) -> Option<u32> {
    encoding
        .resource
        .0
        .read()
        .unwrap()
        .char_to_word(position, seq_id)
}

#[derive(NifTaggedEnum)]
pub enum PadOption {
    PadId(u32),
    PadTypeId(u32),
    PadToken(String),
    Direction(Direction),
}

#[rustler::nif]
pub fn encoding_pad(
    encoding: ExTokenizersEncoding,
    target_length: usize,
    opts: Vec<PadOption>,
) -> ExTokenizersEncoding {
    struct Padding {
        pad_id: u32,
        pad_type_id: u32,
        pad_token: String,
        direction: Direction,
    }
    let mut default = Padding {
        pad_id: 0,
        pad_type_id: 0,
        pad_token: "[PAD]".to_string(),
        direction: Direction::Right,
    };

    for opt in opts {
        match opt {
            PadOption::PadId(id) => default.pad_id = id,
            PadOption::PadTypeId(id) => default.pad_type_id = id,
            PadOption::PadToken(token) => default.pad_token = token,
            PadOption::Direction(direction) => default.direction = direction,
        }
    }

    encoding.resource.0.write().unwrap().pad(
        target_length,
        default.pad_id,
        default.pad_type_id,
        &default.pad_token,
        default.direction.into(),
    );
    encoding
}

#[derive(NifTaggedEnum)]
pub enum TruncationOption {
    Stride(usize),
    Direction(Direction),
}

#[rustler::nif]
pub fn encoding_truncate(
    encoding: ExTokenizersEncoding,
    max_len: usize,
    opts: Vec<TruncationOption>,
) -> ExTokenizersEncoding {
    struct Truncation {
        stride: usize,
        direction: Direction,
    }
    let mut default = Truncation {
        stride: 0,
        direction: Direction::Right,
    };

    for opt in opts {
        match opt {
            TruncationOption::Stride(stride) => default.stride = stride,
            TruncationOption::Direction(direction) => default.direction = direction,
        }
    }

    encoding.resource.0.write().unwrap().truncate(
        max_len,
        default.stride,
        default.direction.into(),
    );
    encoding
}
