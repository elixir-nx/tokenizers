use rustler::NifTaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::{Decoder, DecoderWrapper};

use crate::{new_info, util::Info, ExTokenizersError};

pub struct ExTokenizersDecoderRef(pub DecoderWrapper);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Decoder"]
pub struct ExTokenizersDecoder {
    pub resource: rustler::resource::ResourceArc<ExTokenizersDecoderRef>,
}

impl Serialize for ExTokenizersDecoder {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersDecoder {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersDecoder::new(DecoderWrapper::deserialize(
            deserializer,
        )?))
    }
}

impl Clone for ExTokenizersDecoder {
    fn clone(&self) -> Self {
        Self {
            resource: self.resource.clone(),
        }
    }
}

impl ExTokenizersDecoderRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<DecoderWrapper>,
    {
        Self(data.into())
    }
}

impl ExTokenizersDecoder {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<DecoderWrapper>,
    {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersDecoderRef::new(data)),
        }
    }
}

impl tokenizers::Decoder for ExTokenizersDecoder {
    fn decode_chain(&self, tokens: Vec<String>) -> tokenizers::Result<Vec<String>> {
        self.resource.0.decode_chain(tokens)
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn decoders_decode(
    decoder: ExTokenizersDecoder,
    tokens: Vec<String>,
) -> Result<String, ExTokenizersError> {
    decoder
        .resource
        .0
        .decode(tokens)
        .map_err(ExTokenizersError::Tokenizer)
}

///////////////////////////////////////////////////////////////////////////////
/// Inspection
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn decoders_info(decoder: ExTokenizersDecoder) -> Info {
    match &decoder.resource.0 {
        tokenizers::DecoderWrapper::BPE(decoder) => new_info! {
            decoder_type: "BPE",
            suffix: decoder.suffix.clone()
        },
        tokenizers::DecoderWrapper::ByteLevel(decoder) => new_info! {
            decoder_type: "ByteLevel",
            add_prefix_space: decoder.add_prefix_space,
            trim_offsets: decoder.trim_offsets,
            use_regex: decoder.use_regex
        },
        tokenizers::DecoderWrapper::WordPiece(decoder) => new_info! {
            decoder_type: "WordPiece",
            prefix: decoder.prefix.clone(),
            cleanup: decoder.cleanup
        },
        tokenizers::DecoderWrapper::Metaspace(decoder) => new_info! {
            decoder_type: "Metaspace",
            prepend_scheme: match decoder.prepend_scheme {
                tokenizers::pre_tokenizers::metaspace::PrependScheme::First => "first",
                tokenizers::pre_tokenizers::metaspace::PrependScheme::Never => "never",
                tokenizers::pre_tokenizers::metaspace::PrependScheme::Always => "always",
            }
        },
        tokenizers::DecoderWrapper::CTC(decoder) => new_info! {
            decoder_type: "CTC",
            pad_token: decoder.pad_token.clone(),
            word_delimiter_token: decoder.word_delimiter_token.clone(),
            cleanup: decoder.cleanup
        },
        tokenizers::DecoderWrapper::Sequence(_) => new_info! {
            decoder_type: "Sequence"
        },
        DecoderWrapper::Replace(_) => new_info! {
            decoder_type: "Replace"
        },
        DecoderWrapper::Fuse(_) => new_info! {
            decoder_type: "Fuse"
        },
        DecoderWrapper::Strip(decoder) => new_info! {
            decoder_type: "Strip",
            content: decoder.content as u32,
            start: decoder.start,
            stop: decoder.stop
        },
        DecoderWrapper::ByteFallback(_) => new_info! {
            decoder_type: "ByteFallback"
        },
    }
}

///////////////////////////////////////////////////////////////////////////////
/// Builders
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn decoders_byte_level() -> ExTokenizersDecoder {
    ExTokenizersDecoder::new(tokenizers::decoders::byte_level::ByteLevel::default())
}

#[rustler::nif]
fn decoders_replace(
    pattern: String,
    content: String,
) -> Result<ExTokenizersDecoder, rustler::Error> {
    Ok(ExTokenizersDecoder::new(
        tokenizers::normalizers::Replace::new(pattern, content)
            .map_err(|_| rustler::Error::BadArg)?,
    ))
}

#[derive(NifTaggedEnum)]
pub enum WordpieceOption {
    Prefix(String),
    Cleanup(bool),
}

#[rustler::nif]
fn decoders_wordpiece(options: Vec<WordpieceOption>) -> ExTokenizersDecoder {
    struct Opts {
        prefix: String,
        cleanup: bool,
    }
    let mut opts = Opts {
        prefix: "##".into(),
        cleanup: true,
    };
    for opt in options {
        match opt {
            WordpieceOption::Prefix(prefix) => opts.prefix = prefix,
            WordpieceOption::Cleanup(cleanup) => opts.cleanup = cleanup,
        }
    }
    ExTokenizersDecoder::new(tokenizers::decoders::wordpiece::WordPiece::new(
        opts.prefix,
        opts.cleanup,
    ))
}

#[rustler::nif]
fn decoders_byte_fallback() -> ExTokenizersDecoder {
    ExTokenizersDecoder::new(tokenizers::decoders::byte_fallback::ByteFallback::new())
}

#[rustler::nif]
fn decoders_fuse() -> ExTokenizersDecoder {
    ExTokenizersDecoder::new(tokenizers::decoders::fuse::Fuse::new())
}

#[rustler::nif]
fn decoders_strip(
    content: u32,
    left: usize,
    right: usize,
) -> Result<ExTokenizersDecoder, rustler::Error> {
    let content = std::char::from_u32(content).ok_or(rustler::Error::BadArg)?;
    Ok(ExTokenizersDecoder::new(
        tokenizers::decoders::strip::Strip::new(content, left, right),
    ))
}

#[derive(NifTaggedEnum)]
pub enum MetaspaceOption {
    Replacement(u32),
    PrependScheme(PrependScheme),
}

#[derive(NifTaggedEnum)]
pub enum PrependScheme {
    First,
    Never,
    Always,
}

#[rustler::nif]
fn decoders_metaspace(
    options: Vec<MetaspaceOption>,
) -> Result<ExTokenizersDecoder, rustler::Error> {
    struct Opts {
        replacement: char,
        prepend_scheme: tokenizers::decoders::metaspace::PrependScheme,
    }
    let mut opts = Opts {
        replacement: '▁',
        prepend_scheme: tokenizers::decoders::metaspace::PrependScheme::Always,
    };
    for opt in options {
        match opt {
            MetaspaceOption::Replacement(replacement) => {
                opts.replacement = std::char::from_u32(replacement).ok_or(rustler::Error::BadArg)?
            }
            MetaspaceOption::PrependScheme(prepend_scheme) => {
                opts.prepend_scheme = match prepend_scheme {
                    PrependScheme::First => {
                        tokenizers::pre_tokenizers::metaspace::PrependScheme::First
                    }
                    PrependScheme::Never => {
                        tokenizers::pre_tokenizers::metaspace::PrependScheme::Never
                    }
                    PrependScheme::Always => {
                        tokenizers::pre_tokenizers::metaspace::PrependScheme::Always
                    }
                }
            }
        }
    }
    Ok(ExTokenizersDecoder::new(
        tokenizers::decoders::metaspace::Metaspace::new(
            opts.replacement,
            opts.prepend_scheme,
            true,
        ),
    ))
}

#[derive(NifTaggedEnum)]
pub enum BpeOption {
    Suffix(String),
}

#[rustler::nif]
fn decoders_bpe(options: Vec<BpeOption>) -> ExTokenizersDecoder {
    struct Opts {
        suffix: String,
    }
    let mut opts = Opts {
        suffix: "</w>".into(),
    };
    for opt in options {
        match opt {
            BpeOption::Suffix(suffix) => opts.suffix = suffix,
        }
    }

    ExTokenizersDecoder::new(tokenizers::decoders::bpe::BPEDecoder::new(opts.suffix))
}

#[derive(NifTaggedEnum)]
pub enum CTCOption {
    PadToken(String),
    WordDelimiterToken(String),
    Cleanup(bool),
}

#[rustler::nif]
fn decoders_ctc(options: Vec<CTCOption>) -> ExTokenizersDecoder {
    struct Opts {
        pad_token: String,
        word_delimiter_token: String,
        cleanup: bool,
    }
    let mut opts = Opts {
        pad_token: "<pad>".into(),
        word_delimiter_token: "|".into(),
        cleanup: true,
    };

    for opt in options {
        match opt {
            CTCOption::PadToken(pad_token) => opts.pad_token = pad_token,
            CTCOption::WordDelimiterToken(word_delimiter_token) => {
                opts.word_delimiter_token = word_delimiter_token
            }
            CTCOption::Cleanup(cleanup) => opts.cleanup = cleanup,
        }
    }

    ExTokenizersDecoder::new(tokenizers::decoders::ctc::CTC::new(
        opts.pad_token,
        opts.word_delimiter_token,
        opts.cleanup,
    ))
}

#[rustler::nif]
fn decoders_sequence(decoders: Vec<ExTokenizersDecoder>) -> ExTokenizersDecoder {
    let sequence = decoders
        .iter()
        .map(|decoder| decoder.resource.clone())
        .fold(Vec::with_capacity(decoders.len()), |mut acc, decoder| {
            acc.push(decoder.0.clone());
            acc
        });

    ExTokenizersDecoder::new(tokenizers::decoders::sequence::Sequence::new(sequence))
}
