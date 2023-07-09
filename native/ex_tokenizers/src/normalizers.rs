use crate::{new_info, util::Info, ExTokenizersError};
use rustler::NifTaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::{NormalizedString, Normalizer, NormalizerWrapper};

pub struct ExTokenizersNormalizerRef(pub NormalizerWrapper);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Normalizer"]
pub struct ExTokenizersNormalizer {
    pub resource: rustler::resource::ResourceArc<ExTokenizersNormalizerRef>,
}

impl Serialize for ExTokenizersNormalizer {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersNormalizer {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersNormalizer::new(NormalizerWrapper::deserialize(
            deserializer,
        )?))
    }
}

impl ExTokenizersNormalizerRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<NormalizerWrapper>,
    {
        Self(data.into())
    }
}

impl Clone for ExTokenizersNormalizer {
    fn clone(&self) -> Self {
        Self {
            resource: self.resource.clone(),
        }
    }
}

impl ExTokenizersNormalizer {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<NormalizerWrapper>,
    {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersNormalizerRef::new(data)),
        }
    }
}

impl tokenizers::Normalizer for ExTokenizersNormalizer {
    fn normalize(&self, normalized: &mut NormalizedString) -> tokenizers::Result<()> {
        self.resource.0.normalize(normalized)
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn normalizers_normalize(
    normalizer: ExTokenizersNormalizer,
    input: String,
) -> Result<String, ExTokenizersError> {
    let mut normalized = NormalizedString::from(input);
    normalizer.resource.0.normalize(&mut normalized)?;
    Ok(normalized.get().to_owned())
}

// /////////////////////////////////////////////////////////////////////////////
// / Inspection
// /////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn normalizers_info(normalizer: ExTokenizersNormalizer) -> Info {
    match normalizer.resource.0 {
        NormalizerWrapper::BertNormalizer(_) => new_info!(
            normalizer_type: "BertNormalizer"
        ),
        NormalizerWrapper::StripNormalizer(_) => new_info!(
            normalizer_type: "StripNormalizer"
        ),
        NormalizerWrapper::StripAccents(_) => new_info!(
            normalizer_type: "StripAccents"
        ),
        NormalizerWrapper::NFC(_) => new_info!(
            normalizer_type: "NFC"
        ),
        NormalizerWrapper::NFD(_) => new_info!(
            normalizer_type: "NFD"
        ),
        NormalizerWrapper::NFKC(_) => new_info!(
            normalizer_type: "NFKC"
        ),
        NormalizerWrapper::NFKD(_) => new_info!(
            normalizer_type: "NFKD"
        ),
        NormalizerWrapper::Sequence(_) => new_info!(
            normalizer_type: "Sequence"
        ),
        NormalizerWrapper::Lowercase(_) => new_info!(
            normalizer_type: "Lowercase"
        ),
        NormalizerWrapper::Nmt(_) => new_info!(
            normalizer_type: "Nmt"
        ),
        NormalizerWrapper::Precompiled(_) => new_info!(
            normalizer_type: "Precompiled"
        ),
        NormalizerWrapper::Replace(_) => new_info!(
            normalizer_type: "Replace"
        ),
        NormalizerWrapper::Prepend(_) => new_info!(
            normalizer_type: "Prepend"
        ),
    }
}

// /////////////////////////////////////////////////////////////////////////////
// / Implementation
// /////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum BertOption {
    CleanText(bool),
    HandleChineseChars(bool),
    StripAccents(bool),
    Lowercase(bool),
}

#[rustler::nif]
pub fn normalizers_bert_normalizer(options: Vec<BertOption>) -> ExTokenizersNormalizer {
    struct Opts {
        clean_text: bool,
        handle_chinese_chars: bool,
        strip_accents: Option<bool>,
        lowercase: bool,
    }

    // Default values
    let mut opts = Opts {
        clean_text: true,
        handle_chinese_chars: true,
        strip_accents: None,
        lowercase: true,
    };
    options.iter().for_each(|option| match option {
        BertOption::CleanText(val) => opts.clean_text = *val,
        BertOption::HandleChineseChars(val) => opts.handle_chinese_chars = *val,
        BertOption::StripAccents(val) => opts.strip_accents = Some(*val),
        BertOption::Lowercase(val) => opts.lowercase = *val,
    });

    ExTokenizersNormalizer::new(tokenizers::normalizers::BertNormalizer::new(
        opts.clean_text,
        opts.handle_chinese_chars,
        opts.strip_accents,
        opts.lowercase,
    ))
}

#[rustler::nif]
pub fn normalizers_nfd() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::unicode::NFD)
}

#[rustler::nif]
pub fn normalizers_nfkd() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::unicode::NFKD)
}

#[rustler::nif]
pub fn normalizers_nfc() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::unicode::NFC)
}

#[rustler::nif]
pub fn normalizers_nfkc() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::unicode::NFKC)
}

#[derive(NifTaggedEnum)]
pub enum StripOption {
    Left(bool),
    Right(bool),
}

#[rustler::nif]
pub fn normalizers_strip(options: Vec<StripOption>) -> ExTokenizersNormalizer {
    struct Opts {
        left: bool,
        right: bool,
    }

    // Default values
    let mut opts = Opts {
        left: true,
        right: true,
    };
    options.iter().for_each(|option| match option {
        StripOption::Left(val) => opts.left = *val,
        StripOption::Right(val) => opts.right = *val,
    });

    ExTokenizersNormalizer::new(tokenizers::normalizers::strip::Strip::new(
        opts.left, opts.right,
    ))
}

#[rustler::nif]
pub fn normalizers_prepend(prepend: String) -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::prepend::Prepend::new(prepend))
}

#[rustler::nif]
pub fn normalizers_strip_accents() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::strip::StripAccents)
}

#[rustler::nif]
pub fn normalizers_sequence(normalizers: Vec<ExTokenizersNormalizer>) -> ExTokenizersNormalizer {
    // Fairly saying, normalizer is immutable, but we are still using `arc`
    // to point already created normalizer instead of clonning it.
    let seq: Vec<NormalizerWrapper> = normalizers
        .iter()
        .map(|normalizer| normalizer.resource.0.clone())
        .collect();
    ExTokenizersNormalizer::new(tokenizers::normalizers::Sequence::new(seq))
}

#[rustler::nif]
pub fn normalizers_lowercase() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::utils::Lowercase)
}

#[rustler::nif]
pub fn normalizers_replace(
    pattern: String,
    content: String,
) -> Result<ExTokenizersNormalizer, rustler::Error> {
    Ok(ExTokenizersNormalizer::new(
        tokenizers::normalizers::replace::Replace::new(pattern, content)
            .map_err(|_| rustler::Error::BadArg)?,
    ))
}

#[rustler::nif]
pub fn normalizers_nmt() -> ExTokenizersNormalizer {
    ExTokenizersNormalizer::new(tokenizers::normalizers::unicode::Nmt)
}

#[rustler::nif]
pub fn normalizers_precompiled(data: Vec<u8>) -> Result<ExTokenizersNormalizer, ExTokenizersError> {
    Ok(ExTokenizersNormalizer::new(
        tokenizers::normalizers::precompiled::Precompiled::from(&data)
            .map_err(anyhow::Error::from)?,
    ))
}
