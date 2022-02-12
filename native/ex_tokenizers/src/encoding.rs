use crate::error::ExTokenizersError;
use tokenizers::Encoding;

pub struct ExTokenizersEncodingRef(pub Encoding);

#[derive(rustler::NifStruct)]
#[module = "ExTokenizers.Encoding"]
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
pub fn truncate(
    encoding: ExTokenizersEncoding,
    max_len: usize,
    stride: usize,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    let mut new_encoding = encoding.resource.0.clone();
    new_encoding.truncate(max_len, stride);
    Ok(ExTokenizersEncoding::new(new_encoding))
}
