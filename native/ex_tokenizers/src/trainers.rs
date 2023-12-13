use std::collections::HashSet;
use std::ops::Deref;
use std::sync::RwLock;

use rustler::resource::ResourceArc;
use rustler::NifTaggedEnum;
use tokenizers::models::bpe::BpeTrainerBuilder;
use tokenizers::models::unigram::UnigramTrainerBuilder;
use tokenizers::models::wordlevel::WordLevelTrainerBuilder;
use tokenizers::models::wordpiece::WordPieceTrainerBuilder;
use tokenizers::models::TrainerWrapper;
use tokenizers::AddedToken;

use crate::added_token::AddedTokenInput;
use crate::error::ExTokenizersError;
use crate::models::ExTokenizersModel;
use crate::new_info;
use crate::util::Info;

pub struct ExTokenizersTrainerRef(pub RwLock<TrainerWrapper>);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Trainer"]
pub struct ExTokenizersTrainer {
    pub resource: ResourceArc<ExTokenizersTrainerRef>,
}

impl tokenizers::Trainer for ExTokenizersTrainer {
    type Model = ExTokenizersModel;

    fn should_show_progress(&self) -> bool {
        self.resource.0.read().unwrap().should_show_progress()
    }

    fn train(&self, model: &mut Self::Model) -> tokenizers::Result<Vec<tokenizers::AddedToken>> {
        let special_tokens = self
            .resource
            .0
            .read()
            .unwrap()
            .train(&mut model.resource.0.write().unwrap())?;

        Ok(special_tokens)
    }

    fn feed<I, S, F>(&mut self, iterator: I, process: F) -> tokenizers::Result<()>
    where
        I: Iterator<Item = S> + Send,
        S: AsRef<str> + Send,
        F: Fn(&str) -> tokenizers::Result<Vec<String>> + Sync,
    {
        self.resource.0.write().unwrap().feed(iterator, process)
    }
}

impl ExTokenizersTrainerRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<TrainerWrapper>,
    {
        Self(RwLock::new(data.into()))
    }
}

impl ExTokenizersTrainer {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<TrainerWrapper>,
    {
        Self {
            resource: ResourceArc::new(ExTokenizersTrainerRef::new(data)),
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
/// Inspection
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn trainers_info(trainer: ExTokenizersTrainer) -> Info {
    match &trainer.resource.0.read().unwrap().deref() {
        TrainerWrapper::BpeTrainer(trainer) => new_info!(
            trainer_type: "bpe",
            min_frequency: trainer.min_frequency,
            vocab_size: trainer.vocab_size,
            show_progress: trainer.show_progress,
            special_tokens: trainer.special_tokens.len(),
            limit_alphabet: trainer.limit_alphabet,
            initial_alphabet: trainer.initial_alphabet.len(),
            continuing_subword_prefix: trainer.continuing_subword_prefix.clone(),
            end_of_word_suffix: trainer.end_of_word_suffix.clone()
        ),
        TrainerWrapper::WordPieceTrainer(_) => new_info!(
            trainer_type: "wordpiece"
        ),
        TrainerWrapper::WordLevelTrainer(trainer) => new_info!(
            trainer_type: "wordlevel",
            min_frequency: trainer.min_frequency,
            vocab_size: trainer.vocab_size,
            show_progress: trainer.show_progress,
            special_tokens: trainer.special_tokens.len()
        ),
        TrainerWrapper::UnigramTrainer(trainer) => new_info!(
            trainer_type: "unigram",
            show_progress: trainer.show_progress,
            vocab_size: trainer.vocab_size,
            n_sub_iterations: trainer.n_sub_iterations,
            shrinking_factor: trainer.shrinking_factor,
            special_tokens: trainer.special_tokens.len(),
            initial_alphabet: trainer.initial_alphabet.len(),
            unk_token: trainer.unk_token.clone(),
            max_piece_length: trainer.max_piece_length
        ),
    }
}

///////////////////////////////////////////////////////////////////////////////
/// BPE
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum BPEOption {
    VocabSize(usize),
    MinFrequency(u32),
    SpecialTokens(Vec<AddedTokenInput>),
    LimitAlphabet(usize),
    InitialAlphabet(Vec<u32>),
    ShowProgress(bool),
    ContinuingSubwordPrefix(String),
    EndOfWordSuffix(String),
}

fn populate_bpe_options_to_builder(
    builder: BpeTrainerBuilder,
    options: Vec<BPEOption>,
) -> Result<BpeTrainerBuilder, ExTokenizersError> {
    options
        .iter()
        .try_fold(builder, |builder, option| match option {
            BPEOption::VocabSize(size) => Ok(builder.vocab_size(*size)),
            BPEOption::MinFrequency(frequency) => Ok(builder.min_frequency(*frequency)),
            BPEOption::SpecialTokens(tokens) => {
                Ok(builder.special_tokens(tokens.iter().map(|s| s.into()).collect()))
            }
            BPEOption::LimitAlphabet(limit) => Ok(builder.limit_alphabet(*limit)),
            BPEOption::InitialAlphabet(alphabet) => {
                let alphabet: Vec<char> = alphabet
                    .iter()
                    .map(|ch| std::char::from_u32(*ch).ok_or(ExTokenizersError::InvalidChar))
                    .collect::<Result<Vec<char>, ExTokenizersError>>()?;
                let alphabet: HashSet<char> = HashSet::from_iter(alphabet);

                Ok(builder.initial_alphabet(alphabet))
            }
            BPEOption::ShowProgress(show) => Ok(builder.show_progress(*show)),
            BPEOption::ContinuingSubwordPrefix(prefix) => {
                Ok(builder.continuing_subword_prefix(prefix.clone()))
            }
            BPEOption::EndOfWordSuffix(prefix) => Ok(builder.end_of_word_suffix(prefix.clone())),
        })
}

#[rustler::nif]
pub fn trainers_bpe_trainer(
    options: Vec<BPEOption>,
) -> Result<ExTokenizersTrainer, ExTokenizersError> {
    let model =
        populate_bpe_options_to_builder(tokenizers::models::bpe::BpeTrainer::builder(), options)?
            .build();
    Ok(ExTokenizersTrainer::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// WordPiece
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum WordPieceOption {
    VocabSize(usize),
    MinFrequency(u32),
    SpecialTokens(Vec<String>),
    LimitAlphabet(usize),
    InitialAlphabet(Vec<u32>),
    ShowProgress(bool),
    ContinuingSubwordPrefix(String),
    EndOfWordSuffix(String),
}

fn populate_wordpiece_options_to_builder(
    builder: WordPieceTrainerBuilder,
    options: Vec<WordPieceOption>,
) -> Result<WordPieceTrainerBuilder, ExTokenizersError> {
    options
        .iter()
        .try_fold(builder, |builder, option| match option {
            WordPieceOption::VocabSize(size) => Ok(builder.vocab_size(*size)),
            WordPieceOption::MinFrequency(frequency) => Ok(builder.min_frequency(*frequency)),
            WordPieceOption::SpecialTokens(tokens) => {
                Ok(builder
                    .special_tokens(tokens.iter().map(|s| AddedToken::from(s, true)).collect()))
            }
            WordPieceOption::LimitAlphabet(limit) => Ok(builder.limit_alphabet(*limit)),
            WordPieceOption::InitialAlphabet(alphabet) => {
                let alphabet: Vec<char> = alphabet
                    .iter()
                    .map(|ch| std::char::from_u32(*ch).ok_or(ExTokenizersError::InvalidChar))
                    .collect::<Result<Vec<char>, ExTokenizersError>>()?;
                let alphabet: HashSet<char> = HashSet::from_iter(alphabet);

                Ok(builder.initial_alphabet(alphabet))
            }
            WordPieceOption::ShowProgress(show) => Ok(builder.show_progress(*show)),
            WordPieceOption::ContinuingSubwordPrefix(prefix) => {
                Ok(builder.continuing_subword_prefix(prefix.clone()))
            }
            WordPieceOption::EndOfWordSuffix(prefix) => {
                Ok(builder.end_of_word_suffix(prefix.clone()))
            }
        })
}

#[rustler::nif]
pub fn trainers_wordpiece_trainer(
    options: Vec<WordPieceOption>,
) -> Result<ExTokenizersTrainer, ExTokenizersError> {
    let model = populate_wordpiece_options_to_builder(
        tokenizers::models::wordpiece::WordPieceTrainer::builder(),
        options,
    )?
    .build();
    Ok(ExTokenizersTrainer::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// WordLevel
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum WordLevelOption {
    VocabSize(usize),
    MinFrequency(u32),
    SpecialTokens(Vec<String>),
    ShowProgress(bool),
}

fn populate_wordlevel_options_to_builder(
    builder: &mut WordLevelTrainerBuilder,
    options: Vec<WordLevelOption>,
) {
    for option in options {
        match option {
            WordLevelOption::VocabSize(value) => builder.vocab_size(value),
            WordLevelOption::MinFrequency(value) => builder.min_frequency(value),
            WordLevelOption::SpecialTokens(tokens) => {
                builder.special_tokens(tokens.iter().map(|s| AddedToken::from(s, true)).collect())
            }
            WordLevelOption::ShowProgress(value) => builder.show_progress(value),
        };
    }
}

#[rustler::nif]
pub fn trainers_wordlevel_trainer(
    options: Vec<WordLevelOption>,
) -> Result<ExTokenizersTrainer, ExTokenizersError> {
    let mut builder = tokenizers::models::wordlevel::WordLevelTrainer::builder();
    populate_wordlevel_options_to_builder(&mut builder, options);
    let model = builder.build().map_err(anyhow::Error::from)?;
    Ok(ExTokenizersTrainer::new(model))
}

///////////////////////////////////////////////////////////////////////////////
/// Unigram
///////////////////////////////////////////////////////////////////////////////

#[derive(NifTaggedEnum)]
pub enum UnigramOption {
    VocabSize(u32),
    NSubIterations(u32),
    ShrinkingFactor(f64),
    SpecialTokens(Vec<String>),
    InitialAlphabet(Vec<u32>),
    UniToken(String),
    MaxPieceLength(usize),
    SeedSize(usize),
    ShowProgress(bool),
}

fn populate_unigram_options_to_builder(
    builder: &mut UnigramTrainerBuilder,
    options: Vec<UnigramOption>,
) -> Result<(), ExTokenizersError> {
    for option in options {
        match option {
            UnigramOption::VocabSize(size) => builder.vocab_size(size),
            UnigramOption::NSubIterations(value) => builder.n_sub_iterations(value),
            UnigramOption::ShrinkingFactor(value) => builder.shrinking_factor(value),
            UnigramOption::SpecialTokens(tokens) => {
                builder.special_tokens(tokens.iter().map(|s| AddedToken::from(s, true)).collect())
            }
            UnigramOption::InitialAlphabet(alphabet) => {
                let alphabet: Vec<char> = alphabet
                    .iter()
                    .map(|ch| std::char::from_u32(*ch).ok_or(ExTokenizersError::InvalidChar))
                    .collect::<Result<Vec<char>, ExTokenizersError>>()?;
                let alphabet: HashSet<char> = HashSet::from_iter(alphabet);

                builder.initial_alphabet(alphabet)
            }
            UnigramOption::UniToken(value) => builder.unk_token(Some(value.clone())),
            UnigramOption::MaxPieceLength(value) => builder.max_piece_length(value),
            UnigramOption::SeedSize(value) => builder.seed_size(value),
            UnigramOption::ShowProgress(show) => builder.show_progress(show),
        };
    }
    Ok(())
}

#[rustler::nif]
pub fn trainers_unigram_trainer(
    options: Vec<UnigramOption>,
) -> Result<ExTokenizersTrainer, ExTokenizersError> {
    let mut builder = tokenizers::models::unigram::UnigramTrainer::builder();
    populate_unigram_options_to_builder(&mut builder, options).map_err(anyhow::Error::from)?;
    let model = builder.build().map_err(anyhow::Error::from)?;
    Ok(ExTokenizersTrainer::new(model))
}
