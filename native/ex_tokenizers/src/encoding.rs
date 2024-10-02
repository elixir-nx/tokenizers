use rustler::{Binary, Env, NifTaggedEnum, ResourceArc};
use tokenizers::Encoding;

use crate::util::Direction;

pub struct ExTokenizersEncodingRef(pub Encoding);

#[rustler::resource_impl]
impl rustler::Resource for ExTokenizersEncodingRef {}

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Encoding"]
pub struct ExTokenizersEncoding {
    pub resource: ResourceArc<ExTokenizersEncodingRef>,
}

impl From<Encoding> for ExTokenizersEncoding {
    fn from(encoding: Encoding) -> Self {
        Self {
            resource: ResourceArc::new(ExTokenizersEncodingRef(encoding)),
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
/// Implementation
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn encoding_get_length(encoding: ExTokenizersEncoding) -> usize {
    encoding.resource.0.len()
}

#[rustler::nif]
pub fn encoding_get_n_sequences(encoding: ExTokenizersEncoding) -> usize {
    encoding.resource.0.n_sequences()
}

#[rustler::nif]
pub fn encoding_set_sequence_id(
    encoding: ExTokenizersEncoding,
    seq_id: usize,
) -> ExTokenizersEncoding {
    let mut encoding = encoding.resource.0.clone();
    encoding.set_sequence_id(seq_id);
    encoding.into()
}

#[rustler::nif]
pub fn encoding_get_ids(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.get_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_u32_ids(env: Env, encoding: ExTokenizersEncoding) -> Binary {
    encoding
        .resource
        .make_binary(env, |r| slice_u32_to_u8(r.0.get_ids()))
}

#[rustler::nif]
pub fn encoding_get_type_ids(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.get_type_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_u32_type_ids(env: Env, encoding: ExTokenizersEncoding) -> Binary {
    encoding
        .resource
        .make_binary(env, |r| slice_u32_to_u8(r.0.get_type_ids()))
}

#[rustler::nif]
pub fn encoding_get_attention_mask(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.get_attention_mask().to_vec()
}

#[rustler::nif]
pub fn encoding_get_u32_attention_mask(env: Env, encoding: ExTokenizersEncoding) -> Binary {
    encoding
        .resource
        .make_binary(env, |r| slice_u32_to_u8(r.0.get_attention_mask()))
}

#[rustler::nif]
pub fn encoding_get_special_tokens_mask(encoding: ExTokenizersEncoding) -> Vec<u32> {
    encoding.resource.0.get_special_tokens_mask().to_vec()
}

#[rustler::nif]
pub fn encoding_get_u32_special_tokens_mask(env: Env, encoding: ExTokenizersEncoding) -> Binary {
    encoding
        .resource
        .make_binary(env, |r| slice_u32_to_u8(r.0.get_special_tokens_mask()))
}

#[rustler::nif]
pub fn encoding_get_tokens(encoding: ExTokenizersEncoding) -> Vec<String> {
    encoding.resource.0.get_tokens().to_vec()
}

#[rustler::nif]
pub fn encoding_get_word_ids(encoding: ExTokenizersEncoding) -> Vec<Option<u32>> {
    encoding.resource.0.get_word_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_sequence_ids(encoding: ExTokenizersEncoding) -> Vec<Option<usize>> {
    encoding.resource.0.get_sequence_ids().to_vec()
}

#[rustler::nif]
pub fn encoding_get_offsets(encoding: ExTokenizersEncoding) -> Vec<(usize, usize)> {
    encoding.resource.0.get_offsets().to_vec()
}

#[rustler::nif]
pub fn encoding_get_overflowing(encoding: ExTokenizersEncoding) -> Vec<ExTokenizersEncoding> {
    encoding
        .resource
        .0
        .get_overflowing()
        .iter()
        .map(|encoding| encoding.clone().into())
        .collect::<Vec<ExTokenizersEncoding>>()
}

#[rustler::nif]
pub fn encoding_word_to_tokens(
    encoding: ExTokenizersEncoding,
    word: u32,
    seq_id: usize,
) -> Option<(usize, usize)> {
    encoding.resource.0.word_to_tokens(word, seq_id)
}

#[rustler::nif]
pub fn encoding_word_to_chars(
    encoding: ExTokenizersEncoding,
    word: u32,
    seq_id: usize,
) -> Option<(usize, usize)> {
    encoding.resource.0.word_to_chars(word, seq_id)
}

#[rustler::nif]
pub fn encoding_token_to_sequence(encoding: ExTokenizersEncoding, token: usize) -> Option<usize> {
    encoding.resource.0.token_to_sequence(token)
}

#[rustler::nif]
pub fn encoding_token_to_chars(
    encoding: ExTokenizersEncoding,
    token: usize,
) -> Option<(usize, (usize, usize))> {
    encoding.resource.0.token_to_chars(token)
}

#[rustler::nif]
pub fn encoding_token_to_word(
    encoding: ExTokenizersEncoding,
    token: usize,
) -> Option<(usize, u32)> {
    encoding.resource.0.token_to_word(token)
}

#[rustler::nif]
pub fn encoding_char_to_token(
    encoding: ExTokenizersEncoding,
    position: usize,
    seq_id: usize,
) -> Option<usize> {
    encoding.resource.0.char_to_token(position, seq_id)
}

#[rustler::nif]
pub fn encoding_char_to_word(
    encoding: ExTokenizersEncoding,
    position: usize,
    seq_id: usize,
) -> Option<u32> {
    encoding.resource.0.char_to_word(position, seq_id)
}

#[derive(NifTaggedEnum)]
pub enum PadOption {
    PadId(u32),
    PadTypeId(u32),
    PadToken(String),
    Direction(Direction),
}

struct Padding {
    pad_id: u32,
    pad_type_id: u32,
    pad_token: String,
    direction: Direction,
}

fn parse_pad_options(opts: &Vec<PadOption>) -> Padding {
    let mut default = Padding {
        pad_id: 0,
        pad_type_id: 0,
        pad_token: "[PAD]".to_string(),
        direction: Direction::Right,
    };
    for opt in opts {
        match opt {
            PadOption::PadId(id) => default.pad_id = *id,
            PadOption::PadTypeId(id) => default.pad_type_id = *id,
            PadOption::PadToken(token) => default.pad_token = token.clone(),
            PadOption::Direction(direction) => default.direction = direction.clone(),
        }
    }
    default
}

#[rustler::nif]
pub fn encoding_pad(
    encoding: ExTokenizersEncoding,
    target_length: usize,
    opts: Vec<PadOption>,
) -> ExTokenizersEncoding {
    let default = parse_pad_options(&opts);

    let mut encoding = encoding.resource.0.clone();
    encoding.pad(
        target_length,
        default.pad_id,
        default.pad_type_id,
        &default.pad_token,
        default.direction.into(),
    );
    encoding.into()
}

#[derive(NifTaggedEnum)]
pub enum TruncationOption {
    Stride(usize),
    Direction(Direction),
}

struct Truncation {
    stride: usize,
    direction: Direction,
}

fn parse_truncation_options(opts: &Vec<TruncationOption>) -> Truncation {
    let mut default = Truncation {
        stride: 0,
        direction: Direction::Right,
    };

    for opt in opts {
        match opt {
            TruncationOption::Stride(stride) => default.stride = *stride,
            TruncationOption::Direction(direction) => default.direction = direction.clone(),
        }
    }
    default
}

#[rustler::nif]
pub fn encoding_truncate(
    encoding: ExTokenizersEncoding,
    max_len: usize,
    opts: Vec<TruncationOption>,
) -> ExTokenizersEncoding {
    let default = parse_truncation_options(&opts);

    let mut encoding = encoding.resource.0.clone();

    encoding.truncate(max_len, default.stride, default.direction.into());
    encoding.into()
}

fn slice_u32_to_u8(slice: &[u32]) -> &[u8] {
    unsafe { std::slice::from_raw_parts(slice.as_ptr() as *const u8, slice.len() * 4) }
}

///////////////////////////////////////////////////////////////////////////////
/// Encoding transformations
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum TransformationElement {
    Pad((usize, Vec<PadOption>)), // {:pad, {target_length, opts}}
    Truncate((usize, Vec<TruncationOption>)), // {:truncate, {max_len, opts}}
    SetSequenceId(usize),         // {:set_sequence_id, seq_id}
}

#[rustler::nif]
pub fn encoding_transform(
    encoding: ExTokenizersEncoding,
    transformations: Vec<TransformationElement>,
) -> ExTokenizersEncoding {
    let mut encoding = encoding.resource.0.clone();
    apply_transformations(&mut encoding, &transformations);
    encoding.into()
}

pub fn apply_transformations(
    encoding: &mut Encoding,
    transformations: &Vec<TransformationElement>,
) {
    for transformation in transformations {
        match transformation {
            TransformationElement::Pad((target_length, opts)) => {
                let default = parse_pad_options(opts);

                encoding.pad(
                    *target_length,
                    default.pad_id,
                    default.pad_type_id,
                    &default.pad_token,
                    default.direction.into(),
                )
            }
            TransformationElement::Truncate((max_len, opts)) => {
                let default = parse_truncation_options(opts);
                encoding.truncate(*max_len, default.stride, default.direction.into())
            }
            TransformationElement::SetSequenceId(seq_id) => encoding.set_sequence_id(*seq_id),
        }
    }
}
