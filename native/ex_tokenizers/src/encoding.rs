use crate::error::ExTokenizersError;
use tokenizers::utils::padding::PaddingDirection;
use tokenizers::utils::truncation::TruncationDirection;
use tokenizers::Encoding;

pub struct ExTokenizersEncodingRef(pub Encoding);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Encoding"]
pub struct ExTokenizersEncoding {
    pub resource: rustler::resource::ResourceArc<ExTokenizersEncodingRef>,
}

impl ExTokenizersEncodingRef {
    pub fn new(data: Encoding) -> Self {
        Self(data)
    }
}

impl ExTokenizersEncoding {
    pub fn new(data: Encoding) -> Self {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersEncodingRef::new(data)),
        }
    }
}

#[rustler::nif]
pub fn get_tokens(encoding: ExTokenizersEncoding) -> Result<Vec<String>, ExTokenizersError> {
    Ok(encoding.resource.0.get_tokens().to_vec())
}

#[rustler::nif]
pub fn get_ids(encoding: ExTokenizersEncoding) -> Result<Vec<u32>, ExTokenizersError> {
    Ok(encoding.resource.0.get_ids().to_vec())
}

#[rustler::nif]
pub fn get_attention_mask(encoding: ExTokenizersEncoding) -> Result<Vec<u32>, ExTokenizersError> {
    Ok(encoding.resource.0.get_attention_mask().to_vec())
}

#[rustler::nif]
pub fn get_type_ids(encoding: ExTokenizersEncoding) -> Result<Vec<u32>, ExTokenizersError> {
    Ok(encoding.resource.0.get_type_ids().to_vec())
}

#[rustler::nif]
pub fn get_special_tokens_mask(
    encoding: ExTokenizersEncoding,
) -> Result<Vec<u32>, ExTokenizersError> {
    Ok(encoding.resource.0.get_special_tokens_mask().to_vec())
}

#[rustler::nif]
pub fn get_offsets(
    encoding: ExTokenizersEncoding,
) -> Result<Vec<(usize, usize)>, ExTokenizersError> {
    Ok(encoding.resource.0.get_offsets().to_vec())
}

#[rustler::nif]
pub fn n_tokens(encoding: ExTokenizersEncoding) -> Result<usize, ExTokenizersError> {
    Ok(encoding.resource.0.len())
}

#[rustler::nif]
pub fn truncate(
    encoding: ExTokenizersEncoding,
    max_len: usize,
    stride: usize,
    direction: &str,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    let direction: TruncationDirection = match direction {
        "left" => TruncationDirection::Left,
        "right" => TruncationDirection::Right,
        _ => panic!("direction must be right or left"),
    };
    let mut new_encoding = encoding.resource.0.clone();
    new_encoding.truncate(max_len, stride, direction);
    Ok(ExTokenizersEncoding::new(new_encoding))
}

#[rustler::nif]
pub fn pad(
    encoding: ExTokenizersEncoding,
    target_length: usize,
    pad_id: u32,
    pad_type_id: u32,
    pad_token: &str,
    direction: &str,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    let direction: PaddingDirection = match direction {
        "left" => PaddingDirection::Left,
        "right" => PaddingDirection::Right,
        _ => panic!("direction must be right or left"),
    };
    let mut new_encoding = encoding.resource.0.clone();
    new_encoding.pad(target_length, pad_id, pad_type_id, pad_token, direction);
    Ok(ExTokenizersEncoding::new(new_encoding))
}
