use serde::{Deserialize, Serialize};

use crate::{new_info, tokenizer::ExTokenizersTokenizer, util::Info, ExTokenizersError};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ExTokenizersDecodeStreamRef {
    skip_special_tokens: bool,
    ids: Vec<u32>,
    prefix: String,
    prefix_index: usize,
    read_index: usize,
}

impl ExTokenizersDecodeStreamRef {
    pub fn step<M, N, PT, PP, D>(
        &mut self,
        tokenizer: &tokenizers::TokenizerImpl<M, N, PT, PP, D>,
        id: u32,
    ) -> tokenizers::tokenizer::Result<Option<String>>
    where
        M: tokenizers::Model,
        N: tokenizers::Normalizer,
        PT: tokenizers::PreTokenizer,
        PP: tokenizers::PostProcessor,
        D: tokenizers::Decoder,
    {
        tokenizers::step_decode_stream(
            tokenizer,
            id,
            self.skip_special_tokens,
            &mut self.ids,
            &mut self.prefix,
            &mut self.prefix_index,
        )
    }
}

pub struct ExTokenizerDecodeStreamLock {
    pub inner: std::sync::RwLock<ExTokenizersDecodeStreamRef>,
}

#[rustler::resource_impl]
impl rustler::Resource for ExTokenizerDecodeStreamLock {}

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.DecodeStream"]
pub struct ExTokenizersDecodeStream {
    pub resource: rustler::ResourceArc<ExTokenizerDecodeStreamLock>,
}

impl Serialize for ExTokenizersDecodeStream {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.inner.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersDecodeStream {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersDecodeStream::new(
            ExTokenizersDecodeStreamRef::deserialize(deserializer)?,
        ))
    }
}

impl Clone for ExTokenizersDecodeStream {
    fn clone(&self) -> Self {
        Self {
            resource: rustler::ResourceArc::new(ExTokenizerDecodeStreamLock {
                inner: std::sync::RwLock::new(self.resource.inner.read().unwrap().clone()),
            }),
        }
    }
}

impl ExTokenizersDecodeStream {
    pub fn new(data: ExTokenizersDecodeStreamRef) -> Self {
        Self {
            resource: rustler::ResourceArc::new(ExTokenizerDecodeStreamLock {
                inner: std::sync::RwLock::new(data),
            }),
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn decoder_stream_step(
    decode_stream: ExTokenizersDecodeStream,
    tokenizer: ExTokenizersTokenizer,
    id: u32,
) -> Result<Option<String>, ExTokenizersError> {
    let tk = tokenizer.resource.0.clone();
    let mut ds = decode_stream.resource.inner.write().unwrap();

    ds.step(&tk, id).map_err(ExTokenizersError::Tokenizer)
}

#[rustler::nif]
fn decoder_stream_new(skip_special_tokens: bool) -> ExTokenizersDecodeStream {
    let ds = ExTokenizersDecodeStreamRef {
        skip_special_tokens,
        ids: vec![],
        prefix: "".to_string(),
        prefix_index: 0,
        read_index: 0,
    };

    ExTokenizersDecodeStream::new(ds)
}

///////////////////////////////////////////////////////////////////////////////
/// Inspection
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn decoder_stream_info(decode_stream: ExTokenizersDecodeStream) -> Info {
    let ds = decode_stream.resource.inner.read().unwrap();

    new_info! {
        skip_special_tokens: ds.skip_special_tokens
    }
}
