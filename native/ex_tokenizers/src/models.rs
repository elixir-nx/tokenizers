use std::collections::HashMap;
use std::ops::Deref;
use std::path::{Path, PathBuf};
use std::sync::RwLock;

use rustler::NifTaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::models::bpe::BpeBuilder;
use tokenizers::models::wordlevel::WordLevelBuilder;
use tokenizers::models::wordpiece::WordPieceBuilder;
use tokenizers::{Model, ModelWrapper};

use crate::error::ExTokenizersError;
use crate::trainers::ExTokenizersTrainer;
use crate::{new_info, util::Info};

pub struct ExTokenizersModelRef(pub RwLock<ModelWrapper>);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Model"]
pub struct ExTokenizersModel {
    pub resource: rustler::resource::ResourceArc<ExTokenizersModelRef>,
}

impl Serialize for ExTokenizersModel {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.read().unwrap().serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersModel {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersModel::new(ModelWrapper::deserialize(
            deserializer,
        )?))
    }
}

impl Clone for ExTokenizersModel {
    fn clone(&self) -> Self {
        Self {
            resource: self.resource.clone(),
        }
    }
}

impl tokenizers::Model for ExTokenizersModel {
    type Trainer = ExTokenizersTrainer;

    fn tokenize(&self, sequence: &str) -> tokenizers::Result<Vec<tokenizers::Token>> {
        self.resource.0.read().unwrap().tokenize(sequence)
    }

    fn token_to_id(&self, token: &str) -> Option<u32> {
        self.resource.0.read().unwrap().token_to_id(token)
    }

    fn id_to_token(&self, id: u32) -> Option<String> {
        self.resource.0.read().unwrap().id_to_token(id)
    }

    fn get_vocab(&self) -> HashMap<String, u32> {
        self.resource.0.read().unwrap().get_vocab()
    }

    fn get_vocab_size(&self) -> usize {
        self.resource.0.read().unwrap().get_vocab_size()
    }

    fn save(&self, folder: &Path, name: Option<&str>) -> tokenizers::Result<Vec<PathBuf>> {
        self.resource.0.read().unwrap().save(folder, name)
    }

    fn get_trainer(&self) -> Self::Trainer {
        ExTokenizersTrainer::new(self.resource.0.read().unwrap().get_trainer())
    }
}

impl ExTokenizersModelRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<ModelWrapper>,
    {
        Self(RwLock::new(data.into()))
    }
}

impl ExTokenizersModel {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<ModelWrapper>,
    {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersModelRef::new(data)),
        }
    }
}

#[derive(NifTaggedEnum)]
pub enum ModelSaveOption {
    Prefix(String),
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn models_save(
    model: ExTokenizersModel,
    folder: String,
    options: Vec<ModelSaveOption>,
) -> Result<Vec<String>, ExTokenizersError> {
    struct Opts {
        prefix: Option<String>,
    }

    // Default values
    let mut opts = Opts { prefix: None };

    options.into_iter().for_each(|option| match option {
        ModelSaveOption::Prefix(prefix) => opts.prefix = Some(prefix),
    });

    Ok(model
        .resource
        .0
        .read()
        .unwrap()
        .save(Path::new(&folder), opts.prefix.as_deref())?
        .iter()
        .map(|path| {
            path.to_str()
                // Unwraping here, because we are sure that pathes are valid
                .unwrap()
                .to_owned()
        })
        .collect())
}

///////////////////////////////////////////////////////////////////////////////
/// Inspection
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn models_info(model: ExTokenizersModel) -> Info {
    match &model.resource.0.read().unwrap().deref() {
        ModelWrapper::BPE(model) => new_info! {
            model_type: "bpe",
            dropout: model.dropout,
            unk_token: model.unk_token.clone(),
            continuing_subword_prefix: model.continuing_subword_prefix.clone(),
            end_of_word_suffix: model.end_of_word_suffix.clone(),
            fuse_unk: model.fuse_unk,
            byte_fallback: model.byte_fallback
        },
        ModelWrapper::WordPiece(model) => new_info! {
            model_type: "wordpiece",
            unk_token: model.unk_token.clone(),
            continuing_subword_prefix: model.continuing_subword_prefix.clone(),
            max_input_chars_per_word: model.max_input_chars_per_word
        },
        ModelWrapper::WordLevel(model) => new_info! {
            model_type: "wordlevel",
            unk_token: model.unk_token.clone()
        },
        ModelWrapper::Unigram(model) => new_info! {
            model_type: "unigram",
            min_score: model.min_score,
            byte_fallback: model.byte_fallback()
        },
    }
}

///////////////////////////////////////////////////////////////////////////////
/// BPE
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum BPEOption {
    CacheCapacity(usize),
    Dropout(f32),
    UnkToken(String),
    ContinuingSubwordPrefix(String),
    EndOfWordSuffix(String),
    FuseUnk(bool),
    ByteFallback(bool),
}

fn populate_bpe_options_to_builder(builder: BpeBuilder, options: Vec<BPEOption>) -> BpeBuilder {
    options
        .iter()
        .fold(builder, |builder, option| match option {
            BPEOption::CacheCapacity(capacity) => builder.cache_capacity(*capacity),
            BPEOption::Dropout(dropout) => builder.dropout(*dropout),
            BPEOption::UnkToken(unk_token) => builder.unk_token(unk_token.clone()),
            BPEOption::ContinuingSubwordPrefix(prefix) => {
                builder.continuing_subword_prefix(prefix.clone())
            }
            BPEOption::EndOfWordSuffix(prefix) => builder.end_of_word_suffix(prefix.clone()),
            BPEOption::FuseUnk(fuse_unk) => builder.fuse_unk(*fuse_unk),
            BPEOption::ByteFallback(byte_fallback) => builder.byte_fallback(*byte_fallback),
        })
}

#[rustler::nif]
pub fn models_bpe_init(
    vocab: HashMap<String, u32>,
    merges: Vec<(String, String)>,
    options: Vec<BPEOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    let model = populate_bpe_options_to_builder(
        tokenizers::models::bpe::BPE::builder().vocab_and_merges(vocab, merges),
        options,
    )
    .build()?;
    Ok(ExTokenizersModel::new(model))
}

#[rustler::nif]
pub fn models_bpe_empty() -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        tokenizers::models::bpe::BPE::default(),
    ))
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn models_bpe_from_file(
    vocab: String,
    merges: String,
    options: Vec<BPEOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    let model = populate_bpe_options_to_builder(
        tokenizers::models::bpe::BPE::from_file(&vocab, &merges),
        options,
    )
    .build()?;
    Ok(ExTokenizersModel::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// WordPiece
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum WordPieceOption {
    UnkToken(String),
    ContinuingSubwordPrefix(String),
    MaxInputCharsPerWord(usize),
}

fn populate_wordpiece_options_to_builder(
    builder: WordPieceBuilder,
    options: Vec<WordPieceOption>,
) -> WordPieceBuilder {
    options
        .iter()
        .fold(builder, |builder, option| match option {
            WordPieceOption::UnkToken(unk_token) => builder.unk_token(unk_token.clone()),
            WordPieceOption::ContinuingSubwordPrefix(continuing_subword_prefix) => {
                builder.continuing_subword_prefix(continuing_subword_prefix.clone())
            }
            WordPieceOption::MaxInputCharsPerWord(max_input_chars_per_word) => {
                builder.max_input_chars_per_word(*max_input_chars_per_word)
            }
        })
}

#[rustler::nif]
pub fn models_wordpiece_init(
    vocab: HashMap<String, u32>,
    options: Vec<WordPieceOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        populate_wordpiece_options_to_builder(
            tokenizers::models::wordpiece::WordPiece::builder().vocab(vocab),
            options,
        )
        .build()?,
    ))
}

#[rustler::nif]
pub fn models_wordpiece_empty() -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        tokenizers::models::wordpiece::WordPiece::default(),
    ))
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn models_wordpiece_from_file(
    vocab: String,
    options: Vec<WordPieceOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    let model = populate_wordpiece_options_to_builder(
        tokenizers::models::wordpiece::WordPiece::from_file(&vocab),
        options,
    )
    .build()?;
    Ok(ExTokenizersModel::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// WordLevel
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum WordLevelOption {
    UnkToken(String),
}

fn populate_wordlevel_options_to_builder(
    builder: WordLevelBuilder,
    options: Vec<WordLevelOption>,
) -> WordLevelBuilder {
    options
        .iter()
        .fold(builder, |builder, option| match option {
            WordLevelOption::UnkToken(unk_token) => builder.unk_token(unk_token.clone()),
        })
}

#[rustler::nif]
pub fn models_wordlevel_init(
    vocab: HashMap<String, u32>,
    options: Vec<WordLevelOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        populate_wordlevel_options_to_builder(
            tokenizers::models::wordlevel::WordLevel::builder().vocab(vocab),
            options,
        )
        .build()?,
    ))
}

#[rustler::nif]
pub fn models_wordlevel_empty() -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        tokenizers::models::wordlevel::WordLevel::default(),
    ))
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn models_wordlevel_from_file(
    vocab: String,
    options: Vec<WordLevelOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    let model = populate_wordlevel_options_to_builder(
        tokenizers::models::wordlevel::WordLevel::builder().files(vocab),
        options,
    )
    .build()?;
    Ok(ExTokenizersModel::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// Unigram
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum UnigramOption {
    UnkId(usize),
    ByteFallback(bool),
}

#[rustler::nif]
pub fn models_unigram_init(
    vocab: Vec<(String, f64)>,
    options: Vec<UnigramOption>,
) -> Result<ExTokenizersModel, ExTokenizersError> {
    let unk_id = match options
        .iter()
        .find(|opt| matches!(opt, UnigramOption::UnkId(_)))
        .unwrap()
    {
        UnigramOption::UnkId(unk_id) => Some(*unk_id),
        _ => None,
    };

    let byte_fallback = match options
        .iter()
        .find(|opt| matches!(opt, UnigramOption::ByteFallback(_)))
        .unwrap()
    {
        UnigramOption::ByteFallback(byte_fallback) => *byte_fallback,
        _ => false,
    };

    Ok(ExTokenizersModel::new(
        tokenizers::models::unigram::Unigram::from(vocab, unk_id, byte_fallback)?,
    ))
}

#[rustler::nif]
pub fn models_unigram_empty() -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        tokenizers::models::unigram::Unigram::default(),
    ))
}
