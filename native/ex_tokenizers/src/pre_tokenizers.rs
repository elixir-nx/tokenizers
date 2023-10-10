use crate::util::Info;
use crate::{new_info, ExTokenizersError};
use rustler::NifTaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::pre_tokenizers::split::SplitPattern;
use tokenizers::PreTokenizer;
use tokenizers::{processors::byte_level::ByteLevel, PreTokenizedString, PreTokenizerWrapper};

pub struct ExTokenizersPreTokenizerRef(pub PreTokenizerWrapper);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.PreTokenizer"]
pub struct ExTokenizersPreTokenizer {
    pub resource: rustler::resource::ResourceArc<ExTokenizersPreTokenizerRef>,
}

impl Serialize for ExTokenizersPreTokenizer {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersPreTokenizer {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersPreTokenizer::new(
            PreTokenizerWrapper::deserialize(deserializer)?,
        ))
    }
}

impl tokenizers::PreTokenizer for ExTokenizersPreTokenizer {
    fn pre_tokenize(&self, pretokenized: &mut PreTokenizedString) -> tokenizers::Result<()> {
        self.resource.0.pre_tokenize(pretokenized)
    }
}

impl Clone for ExTokenizersPreTokenizer {
    fn clone(&self) -> Self {
        Self {
            resource: self.resource.clone(),
        }
    }
}

impl ExTokenizersPreTokenizerRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<PreTokenizerWrapper>,
    {
        Self(data.into())
    }
}

impl ExTokenizersPreTokenizer {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<PreTokenizerWrapper>,
    {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersPreTokenizerRef::new(data)),
        }
    }
}

#[rustler::nif]
#[allow(clippy::type_complexity)]
pub fn pre_tokenizers_pre_tokenize(
    pre_tokenizer: ExTokenizersPreTokenizer,
    sequence: String,
) -> Result<Vec<(String, (usize, usize))>, ExTokenizersError> {
    let mut pretokenized = PreTokenizedString::from(sequence);

    pre_tokenizer.pre_tokenize(&mut pretokenized)?;
    let splits: Vec<(String, (usize, usize))> = pretokenized
        .get_splits(
            tokenizers::OffsetReferential::Original,
            tokenizers::OffsetType::Char,
        )
        .into_iter()
        .map(|(s, o, _)| (s.to_owned(), o))
        .collect();
    Ok(splits)
}

// /////////////////////////////////////////////////////////////////////////////
// / Inspection
// /////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn pre_tokenizers_info(pre_tokenizer: ExTokenizersPreTokenizer) -> Info {
    match pre_tokenizer.resource.0 {
        PreTokenizerWrapper::BertPreTokenizer(_) => new_info!(
            pre_tokenizer_type: "BertPreTokenizer"
        ),
        PreTokenizerWrapper::ByteLevel(_) => new_info!(
            pre_tokenizer_type: "ByteLevel"
        ),
        PreTokenizerWrapper::Delimiter(_) => new_info!(
            pre_tokenizer_type: "Delimiter"
        ),
        PreTokenizerWrapper::Metaspace(_) => new_info!(
            pre_tokenizer_type: "Metaspace"
        ),
        PreTokenizerWrapper::Whitespace(_) => new_info!(
            pre_tokenizer_type: "Whitespace"
        ),
        PreTokenizerWrapper::Sequence(_) => new_info!(
            pre_tokenizer_type: "Sequence"
        ),
        PreTokenizerWrapper::Split(_) => new_info!(
            pre_tokenizer_type: "Split"
        ),
        PreTokenizerWrapper::Punctuation(_) => new_info!(
            pre_tokenizer_type: "Punctuation"
        ),
        PreTokenizerWrapper::WhitespaceSplit(_) => new_info!(
            pre_tokenizer_type: "WhitespaceSplit"
        ),
        PreTokenizerWrapper::Digits(_) => new_info!(
            pre_tokenizer_type: "Digits"
        ),
        PreTokenizerWrapper::UnicodeScripts(_) => new_info!(
            pre_tokenizer_type: "UnicodeScripts"
        ),
    }
}

// /////////////////////////////////////////////////////////////////////////////
// / Implementation
// /////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum ByteLevelOption {
    AddPrefixSpace(bool),
    UseRegex(bool),
}

#[rustler::nif]
pub fn pre_tokenizers_byte_level(options: Vec<ByteLevelOption>) -> ExTokenizersPreTokenizer {
    let mut byte_level: ByteLevel = tokenizers::pre_tokenizers::byte_level::ByteLevel::default();
    for option in options {
        match option {
            ByteLevelOption::AddPrefixSpace(add_prefix_space) => {
                byte_level = byte_level.add_prefix_space(add_prefix_space)
            }
            ByteLevelOption::UseRegex(use_regex) => byte_level = byte_level.use_regex(use_regex),
        };
    }
    ExTokenizersPreTokenizer::new(byte_level)
}

#[rustler::nif]
pub fn pre_tokenizers_byte_level_alphabet() -> Vec<u32> {
    tokenizers::pre_tokenizers::byte_level::ByteLevel::alphabet()
        .into_iter()
        .map(|c| c as u32)
        .collect::<Vec<_>>()
}

#[rustler::nif]
pub fn pre_tokenizers_whitespace() -> ExTokenizersPreTokenizer {
    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::whitespace::Whitespace)
}

#[rustler::nif]
pub fn pre_tokenizers_whitespace_split() -> ExTokenizersPreTokenizer {
    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::whitespace::WhitespaceSplit)
}

#[rustler::nif]
pub fn pre_tokenizers_bert() -> ExTokenizersPreTokenizer {
    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::bert::BertPreTokenizer)
}

#[derive(NifTaggedEnum)]
pub enum MetaspaceOption {
    Replacement(u32),
    AddPrefixSpace(bool),
}

#[rustler::nif]
pub fn pre_tokenizers_metaspace(
    options: Vec<MetaspaceOption>,
) -> Result<ExTokenizersPreTokenizer, rustler::Error> {
    let mut metaspace = tokenizers::pre_tokenizers::metaspace::Metaspace::default();
    for option in options {
        match option {
            MetaspaceOption::Replacement(replacement) => metaspace
                .set_replacement(std::char::from_u32(replacement).ok_or(rustler::Error::BadArg)?),
            MetaspaceOption::AddPrefixSpace(add_prefix_space) => {
                metaspace.add_prefix_space = add_prefix_space
            }
        }
    }
    Ok(ExTokenizersPreTokenizer::new(metaspace))
}

#[rustler::nif]
pub fn pre_tokenizers_char_delimiter_split(
    delimiter: u32,
) -> Result<ExTokenizersPreTokenizer, rustler::Error> {
    Ok(ExTokenizersPreTokenizer::new(
        tokenizers::pre_tokenizers::delimiter::CharDelimiterSplit::new(
            std::char::from_u32(delimiter).ok_or(rustler::Error::BadArg)?,
        ),
    ))
}

#[derive(rustler::NifUnitEnum)]
pub enum SplitDelimiterBehavior {
    Removed,
    Isolated,
    MergedWithPrevious,
    MergedWithNext,
    Contiguous,
}

impl From<SplitDelimiterBehavior> for tokenizers::SplitDelimiterBehavior {
    fn from(value: SplitDelimiterBehavior) -> Self {
        match value {
            SplitDelimiterBehavior::Removed => tokenizers::SplitDelimiterBehavior::Removed,
            SplitDelimiterBehavior::Isolated => tokenizers::SplitDelimiterBehavior::Isolated,
            SplitDelimiterBehavior::MergedWithPrevious => {
                tokenizers::SplitDelimiterBehavior::MergedWithPrevious
            }
            SplitDelimiterBehavior::MergedWithNext => {
                tokenizers::SplitDelimiterBehavior::MergedWithNext
            }
            SplitDelimiterBehavior::Contiguous => tokenizers::SplitDelimiterBehavior::Contiguous,
        }
    }
}

#[derive(NifTaggedEnum)]
pub enum SplitOption {
    Invert(bool),
}

#[derive(NifTaggedEnum)]
pub enum LocalSplitPattern {
    String(String),
    Regex(String),
}

#[rustler::nif]
pub fn pre_tokenizers_split(
    pattern: LocalSplitPattern,
    behavior: SplitDelimiterBehavior,
    options: Vec<SplitOption>,
) -> Result<ExTokenizersPreTokenizer, rustler::Error> {
    struct Opts {
        invert: bool,
    }
    let mut opts = Opts { invert: false };
    let final_pattern = match pattern {
        LocalSplitPattern::String(pattern) => SplitPattern::String(pattern),
        LocalSplitPattern::Regex(pattern) => SplitPattern::Regex(pattern),
    };

    for option in options {
        match option {
            SplitOption::Invert(invert) => opts.invert = invert,
        }
    }

    Ok(ExTokenizersPreTokenizer::new(
        tokenizers::pre_tokenizers::split::Split::new(final_pattern, behavior.into(), opts.invert)
            .map_err(|_| rustler::Error::BadArg)?,
    ))
}

#[rustler::nif]
pub fn pre_tokenizers_punctuation(behavior: SplitDelimiterBehavior) -> ExTokenizersPreTokenizer {
    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::punctuation::Punctuation::new(
        behavior.into(),
    ))
}

#[rustler::nif]
pub fn pre_tokenizers_sequence(
    pretokenizers: Vec<ExTokenizersPreTokenizer>,
) -> ExTokenizersPreTokenizer {
    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::sequence::Sequence::new(
        pretokenizers
            .iter()
            .map(|pretokenizer| pretokenizer.resource.0.clone())
            .collect(),
    ))
}

#[derive(NifTaggedEnum)]
pub enum DigitsOption {
    IndividualDigits(bool),
}

#[rustler::nif]
pub fn pre_tokenizers_digits(options: Vec<DigitsOption>) -> ExTokenizersPreTokenizer {
    struct Opts {
        individual_digits: bool,
    }
    let mut opts = Opts {
        individual_digits: false,
    };

    for option in options {
        match option {
            DigitsOption::IndividualDigits(individual_digits) => {
                opts.individual_digits = individual_digits
            }
        };
    }

    ExTokenizersPreTokenizer::new(tokenizers::pre_tokenizers::digits::Digits::new(
        opts.individual_digits,
    ))
}
