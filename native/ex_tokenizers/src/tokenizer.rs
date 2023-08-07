use std::collections::HashMap;
use std::ops::Deref;
use std::panic;

use rustler::{NifTaggedEnum, Term};

use tokenizers::models::wordpiece::WordPieceTrainerBuilder;
use tokenizers::models::TrainerWrapper;
use tokenizers::tokenizer::AddedToken;
use tokenizers::Model;
use tokenizers::{EncodeInput, TokenizerImpl};

use crate::added_token::{AddedSpecialTokenInput, AddedTokenInput};
use crate::decoders::ExTokenizersDecoder;
use crate::encoding::{apply_transformations, ExTokenizersEncoding, TransformationElement};
use crate::error::ExTokenizersError;
use crate::models::ExTokenizersModel;
use crate::normalizers::ExTokenizersNormalizer;
use crate::post_processors::ExTokenizersPostProcessor;
use crate::pre_tokenizers::ExTokenizersPreTokenizer;
use crate::trainers::ExTokenizersTrainer;
use crate::util::Direction;

type ExTokenizerImpl = TokenizerImpl<
    ExTokenizersModel,
    ExTokenizersNormalizer,
    ExTokenizersPreTokenizer,
    ExTokenizersPostProcessor,
    ExTokenizersDecoder,
>;

pub struct ExTokenizersTokenizerRef(ExTokenizerImpl);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Tokenizer"]
pub struct ExTokenizersTokenizer {
    pub resource: rustler::resource::ResourceArc<ExTokenizersTokenizerRef>,
}

impl From<ExTokenizerImpl> for ExTokenizersTokenizer {
    fn from(data: ExTokenizerImpl) -> Self {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersTokenizerRef(data)),
        }
    }
}

// /////////////////////////////////////////////////////////////////////////////
// / Creators
// /////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn tokenizer_init(
    model: ExTokenizersModel,
) -> Result<ExTokenizersTokenizer, ExTokenizersError> {
    let tokenizer = TokenizerImpl::new(model);
    Ok(tokenizer.into())
}

#[derive(NifTaggedEnum)]
pub enum LoadOption {
    AdditionalSpecialTokens(Vec<AddedSpecialTokenInput>),
    // Currently only :none is supported
    Padding(rustler::Atom),
    Truncation(rustler::Atom),
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn tokenizer_from_file(
    path: &str,
    options: Vec<LoadOption>,
) -> Result<ExTokenizersTokenizer, ExTokenizersError> {
    let mut tokenizer = TokenizerImpl::from_file(path)?;
    tokenizer = apply_load_options(tokenizer, options);
    Ok(tokenizer.into())
}

#[rustler::nif]
pub fn tokenizer_from_buffer(
    data: String,
    options: Vec<LoadOption>,
) -> Result<ExTokenizersTokenizer, ExTokenizersError> {
    let mut tokenizer: ExTokenizerImpl = data.parse()?;
    tokenizer = apply_load_options(tokenizer, options);
    Ok(tokenizer.into())
}

fn apply_load_options(mut tokenizer: ExTokenizerImpl, options: Vec<LoadOption>) -> ExTokenizerImpl {
    struct Opts {
        additional_special_tokens: Vec<AddedSpecialTokenInput>,
        disable_padding: bool,
        disable_truncation: bool,
    }

    let mut opts = Opts {
        additional_special_tokens: vec![],
        disable_padding: false,
        disable_truncation: false,
    };

    for opt in options {
        match opt {
            LoadOption::AdditionalSpecialTokens(tokens) => {
                opts.additional_special_tokens = tokens;
            }
            LoadOption::Padding(_) => {
                opts.disable_padding = true;
            }
            LoadOption::Truncation(_) => {
                opts.disable_truncation = true;
            }
        }
    }

    tokenizer.add_special_tokens(
        opts.additional_special_tokens
            .iter()
            .map(|t| t.into())
            .collect::<Vec<_>>()
            .as_ref(),
    );

    if opts.disable_padding {
        tokenizer.with_padding(None);
    }

    if opts.disable_truncation {
        tokenizer.with_truncation(None);
    }

    tokenizer
}

#[derive(NifTaggedEnum)]
pub enum SaveOption {
    Pretty(bool),
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn tokenizer_save(
    tokenizer: ExTokenizersTokenizer,
    path: &str,
    options: Vec<SaveOption>,
    // pretty: bool,
) -> Result<String, ExTokenizersError> {
    struct Opts {
        pretty: bool,
    }
    let mut opts = Opts { pretty: false };
    for opt in options {
        match opt {
            SaveOption::Pretty(pretty) => opts.pretty = pretty,
        }
    }

    tokenizer.resource.0.save(path, opts.pretty)?;
    Ok(path.to_string())
}

// tokenizer_from_pretrained IS SKIPPED as implemented in elixir.
// It uses tokeniser_from_file underneeth.

// /////////////////////////////////////////////////////////////////////////////
// / Setters / Getters
// /////////////////////////////////////////////////////////////////////////////
#[rustler::nif]
pub fn tokenizer_get_model(tokenizer: ExTokenizersTokenizer) -> ExTokenizersModel {
    let model = tokenizer.resource.0.get_model().clone();
    model
}

#[rustler::nif]
pub fn tokenizer_set_model(
    tokenizer: ExTokenizersTokenizer,
    model: ExTokenizersModel,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_model(model);
    new_tokenizer.into()
}

// Generate all setters and getters for pre_tokenizer, normalizer and so on - not as a macro:
#[rustler::nif]
pub fn tokenizer_get_normalizer(
    tokenizer: ExTokenizersTokenizer,
) -> Option<ExTokenizersNormalizer> {
    let normalizer: Option<ExTokenizersNormalizer> = tokenizer.resource.0.get_normalizer().cloned();
    normalizer
}

#[rustler::nif]
pub fn tokenizer_set_normalizer(
    tokenizer: ExTokenizersTokenizer,
    normalizer: ExTokenizersNormalizer,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_normalizer(normalizer);
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_get_pre_tokenizer(
    tokenizer: ExTokenizersTokenizer,
) -> Option<ExTokenizersPreTokenizer> {
    let pre_tokenizer: Option<ExTokenizersPreTokenizer> =
        tokenizer.resource.0.get_pre_tokenizer().cloned();
    pre_tokenizer
}

#[rustler::nif]
pub fn tokenizer_set_pre_tokenizer(
    tokenizer: ExTokenizersTokenizer,
    pre_tokenizer: ExTokenizersPreTokenizer,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_pre_tokenizer(pre_tokenizer);
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_get_post_processor(
    tokenizer: ExTokenizersTokenizer,
) -> Option<ExTokenizersPostProcessor> {
    let post_processor: Option<ExTokenizersPostProcessor> =
        tokenizer.resource.0.get_post_processor().cloned();
    post_processor
}

#[rustler::nif]
pub fn tokenizer_set_post_processor(
    tokenizer: ExTokenizersTokenizer,
    post_processor: ExTokenizersPostProcessor,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_post_processor(post_processor);
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_get_decoder(tokenizer: ExTokenizersTokenizer) -> Option<ExTokenizersDecoder> {
    let decoder: Option<ExTokenizersDecoder> = tokenizer.resource.0.get_decoder().cloned();
    decoder
}

#[rustler::nif]
pub fn tokenizer_set_decoder(
    tokenizer: ExTokenizersTokenizer,
    decoder: ExTokenizersDecoder,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_decoder(decoder);
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_get_vocab(
    tokenizer: ExTokenizersTokenizer,
    with_added_tokens: bool,
) -> HashMap<String, u32> {
    tokenizer.resource.0.get_vocab(with_added_tokens)
}

#[rustler::nif]
pub fn tokenizer_get_vocab_size(
    tokenizer: ExTokenizersTokenizer,
    with_added_tokens: bool,
) -> usize {
    tokenizer.resource.0.get_vocab_size(with_added_tokens)
}

#[rustler::nif]
pub fn tokenizer_add_tokens(
    tokenizer: ExTokenizersTokenizer,
    tokens: Vec<AddedTokenInput>,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.add_tokens(&tokens.iter().map(|t| t.into()).collect::<Vec<AddedToken>>());
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_add_special_tokens(
    tokenizer: ExTokenizersTokenizer,
    tokens: Vec<AddedSpecialTokenInput>,
) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.add_special_tokens(&tokens.iter().map(|t| t.into()).collect::<Vec<AddedToken>>());
    new_tokenizer.into()
}

#[derive(NifTaggedEnum)]
pub enum TruncationOption {
    MaxLength(usize),
    Stride(usize),
    Strategy(TruncateStrategy),
    Direction(Direction),
}

#[derive(NifTaggedEnum)]
pub enum TruncateStrategy {
    LongestFirst,
    OnlyFirst,
    OnlySecond,
}

impl From<TruncateStrategy> for tokenizers::TruncationStrategy {
    fn from(strategy: TruncateStrategy) -> Self {
        match strategy {
            TruncateStrategy::LongestFirst => tokenizers::TruncationStrategy::LongestFirst,
            TruncateStrategy::OnlyFirst => tokenizers::TruncationStrategy::OnlyFirst,
            TruncateStrategy::OnlySecond => tokenizers::TruncationStrategy::OnlySecond,
        }
    }
}
impl From<&TruncateStrategy> for tokenizers::TruncationStrategy {
    fn from(strategy: &TruncateStrategy) -> Self {
        match strategy {
            TruncateStrategy::LongestFirst => tokenizers::TruncationStrategy::LongestFirst,
            TruncateStrategy::OnlyFirst => tokenizers::TruncationStrategy::OnlyFirst,
            TruncateStrategy::OnlySecond => tokenizers::TruncationStrategy::OnlySecond,
        }
    }
}

#[rustler::nif]
pub fn tokenizer_set_truncation(
    tokenizer: ExTokenizersTokenizer,
    opts: Vec<TruncationOption>,
) -> ExTokenizersTokenizer {
    let mut truncation: tokenizers::TruncationParams = Default::default();
    opts.iter().for_each(|option| match option {
        TruncationOption::MaxLength(max_length) => truncation.max_length = *max_length,
        TruncationOption::Stride(stride) => truncation.stride = *stride,
        TruncationOption::Strategy(strategy) => truncation.strategy = strategy.into(),
        TruncationOption::Direction(direction) => truncation.direction = direction.into(),
    });
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_truncation(Some(truncation));
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_disable_truncation(tokenizer: ExTokenizersTokenizer) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_truncation(None);
    new_tokenizer.into()
}

#[derive(NifTaggedEnum)]
pub enum PaddingOption {
    Strategy(PadStrategy),
    Direction(Direction),
    PadToMultipleOf(usize),
    PadId(u32),
    PadTypeId(u32),
    PadToken(String),
}

#[derive(NifTaggedEnum)]
pub enum PadStrategy {
    BatchLongest,
    Fixed(usize),
}

impl From<PadStrategy> for tokenizers::PaddingStrategy {
    fn from(strategy: PadStrategy) -> Self {
        match strategy {
            PadStrategy::BatchLongest => tokenizers::PaddingStrategy::BatchLongest,
            PadStrategy::Fixed(size) => tokenizers::PaddingStrategy::Fixed(size),
        }
    }
}
impl From<&PadStrategy> for tokenizers::PaddingStrategy {
    fn from(strategy: &PadStrategy) -> Self {
        match strategy {
            PadStrategy::BatchLongest => tokenizers::PaddingStrategy::BatchLongest,
            PadStrategy::Fixed(size) => tokenizers::PaddingStrategy::Fixed(*size),
        }
    }
}

#[rustler::nif]
pub fn tokenizer_set_padding(
    tokenizer: ExTokenizersTokenizer,
    opts: Vec<PaddingOption>,
) -> ExTokenizersTokenizer {
    let mut padding = tokenizers::PaddingParams {
        ..Default::default()
    };
    opts.iter().for_each(|option| match option {
        PaddingOption::Strategy(strategy) => padding.strategy = strategy.into(),
        PaddingOption::Direction(direction) => padding.direction = direction.into(),
        PaddingOption::PadToMultipleOf(pad_to_multiple_of) => {
            padding.pad_to_multiple_of = Some(*pad_to_multiple_of)
        }
        PaddingOption::PadId(pad_id) => padding.pad_id = *pad_id,
        PaddingOption::PadTypeId(pad_type_id) => padding.pad_type_id = *pad_type_id,
        PaddingOption::PadToken(pad_token) => padding.pad_token = pad_token.clone(),
    });
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_padding(Some(padding));
    new_tokenizer.into()
}

#[rustler::nif]
pub fn tokenizer_disable_padding(tokenizer: ExTokenizersTokenizer) -> ExTokenizersTokenizer {
    let mut new_tokenizer = tokenizer.resource.0.clone();
    new_tokenizer.with_padding(None);
    new_tokenizer.into()
}

// /////////////////////////////////////////////////////////////////////////////
// / Inference
// /////////////////////////////////////////////////////////////////////////////

fn term_to_encode_input<'a>(term: &'a Term) -> Result<EncodeInput<'a>, ExTokenizersError> {
    if let Ok(seq) = term.decode::<String>() {
        Ok(EncodeInput::Single(seq.into()))
    } else if let Ok((seq1, seq2)) = term.decode::<(String, String)>() {
        Ok(EncodeInput::Dual(seq1.into(), seq2.into()))
    } else {
        Err(ExTokenizersError::Other(String::from(
            "input must be either a string or a tuple",
        )))
    }
}

#[derive(NifTaggedEnum)]
pub enum EncodeOption {
    AddSpecialTokens(bool),
    EncodingTransformations(Vec<TransformationElement>),
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn tokenizer_encode(
    tokenizer: ExTokenizersTokenizer,
    input: Term,
    options: Vec<EncodeOption>,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    struct Opts {
        add_special_tokens: bool,
        encoding_transformations: Vec<TransformationElement>,
    }
    let mut opts = Opts {
        add_special_tokens: true,
        encoding_transformations: Vec::new(),
    };
    options.into_iter().for_each(|option| match option {
        EncodeOption::AddSpecialTokens(add_special_tokens) => {
            opts.add_special_tokens = add_special_tokens
        }
        EncodeOption::EncodingTransformations(encoding_transformations) => {
            opts.encoding_transformations = encoding_transformations
        }
    });

    let input = term_to_encode_input(&input)?;
    let mut encoding = tokenizer
        .resource
        .0
        .encode(input, opts.add_special_tokens)?;
    apply_transformations(&mut encoding, &opts.encoding_transformations);
    Ok(encoding.into())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn tokenizer_encode_batch(
    tokenizer: ExTokenizersTokenizer,
    inputs: Vec<Term>,
    options: Vec<EncodeOption>,
    // add_special_tokens: bool,
) -> Result<Vec<ExTokenizersEncoding>, ExTokenizersError> {
    struct Opts {
        add_special_tokens: bool,
        encoding_transformations: Vec<TransformationElement>,
    }
    let mut opts = Opts {
        add_special_tokens: true,
        encoding_transformations: Vec::new(),
    };
    options.into_iter().for_each(|option| match option {
        EncodeOption::AddSpecialTokens(add_special_tokens) => {
            opts.add_special_tokens = add_special_tokens
        }
        EncodeOption::EncodingTransformations(encoding_transformations) => {
            opts.encoding_transformations = encoding_transformations
        }
    });
    let inputs = inputs
        .iter()
        .map(term_to_encode_input)
        .collect::<Result<Vec<EncodeInput>, ExTokenizersError>>()?;
    let mut encodings = tokenizer
        .resource
        .0
        .encode_batch(inputs, opts.add_special_tokens)?;

    // Applying transformations (if any)
    for encoding in encodings.iter_mut() {
        apply_transformations(encoding, &opts.encoding_transformations);
    }

    let ex_encodings = encodings
        .into_iter()
        .map(|encoding| encoding.into())
        .collect();
    Ok(ex_encodings)
}

#[derive(NifTaggedEnum)]
pub enum DecodeOption {
    SkipSpecialTokens(bool),
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn tokenizer_decode(
    tokenizer: ExTokenizersTokenizer,
    ids: Vec<u32>,
    options: Vec<DecodeOption>,
) -> Result<String, ExTokenizersError> {
    struct Opts {
        skip_special_tokens: bool,
    }
    let mut opts = Opts {
        skip_special_tokens: true,
    };
    options.into_iter().for_each(|option| match option {
        DecodeOption::SkipSpecialTokens(skip_special_tokens) => {
            opts.skip_special_tokens = skip_special_tokens
        }
    });

    Ok(tokenizer.resource.0.decode(ids, opts.skip_special_tokens)?)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn tokenizer_decode_batch(
    tokenizer: ExTokenizersTokenizer,
    sentences: Vec<Vec<u32>>,
    options: Vec<DecodeOption>,
) -> Result<Vec<String>, ExTokenizersError> {
    struct Opts {
        skip_special_tokens: bool,
    }
    let mut opts = Opts {
        skip_special_tokens: true,
    };
    options.into_iter().for_each(|option| match option {
        DecodeOption::SkipSpecialTokens(skip_special_tokens) => {
            opts.skip_special_tokens = skip_special_tokens
        }
    });

    Ok(tokenizer
        .resource
        .0
        .decode_batch(sentences, opts.skip_special_tokens)?)
}

#[rustler::nif]
pub fn tokenizer_token_to_id(tokenizer: ExTokenizersTokenizer, token: &str) -> Option<u32> {
    tokenizer.resource.0.token_to_id(token)
}

#[rustler::nif]
pub fn tokenizer_id_to_token(tokenizer: ExTokenizersTokenizer, id: u32) -> Option<String> {
    tokenizer.resource.0.id_to_token(id)
}

#[rustler::nif]
pub fn tokenizer_post_processing(
    tokenizer: ExTokenizersTokenizer,
    enc: ExTokenizersEncoding,
    pair: Option<ExTokenizersEncoding>,
    add_special_tokens: bool,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    let result: tokenizers::Encoding = tokenizer.resource.0.post_process(
        enc.resource.0.clone(),
        pair.map(|enc| enc.resource.0.clone()),
        add_special_tokens,
    )?;
    Ok(result.into())
}

// /////////////////////////////////////////////////////////////////////////////
// / Training
// /////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
pub fn tokenizer_train_from_files(
    tokenizer: ExTokenizersTokenizer,
    files: Vec<String>,
    trainer: Option<ExTokenizersTrainer>,
) -> Result<ExTokenizersTokenizer, ExTokenizersError> {
    // Current version of rust lib panics on retrainging with another trainer.
    // This leads to unpredicted nif behaviour.
    // Unwind can be removed after fixes https://github.com/huggingface/tokenizers/issues/525

    let result = panic::catch_unwind(|| {
        let mut new_tokenizer = tokenizer.resource.0.clone();
        let new_model = ExTokenizersModel::new(
            tokenizer
                .resource
                .0
                .get_model()
                .resource
                .0
                .read()
                .unwrap()
                .clone(),
        );
        new_tokenizer.with_model(new_model);
        match trainer {
            Some(trainer) => {
                // TODO: call clone on trainer wrapper once available (tokenizers > 0.13.3)
                // see https://github.com/huggingface/tokenizers/pull/1317
                let trainer = match trainer.resource.0.read().unwrap().deref() {
                    TrainerWrapper::BpeTrainer(trainer) => {
                        TrainerWrapper::BpeTrainer(trainer.clone())
                    }
                    TrainerWrapper::WordPieceTrainer(trainer) => {
                        // WordPieceTrainer does not derive clone so we re-build by hand
                        let mut builder = WordPieceTrainerBuilder::default()
                            .min_frequency(trainer.min_frequency())
                            .vocab_size(trainer.vocab_size())
                            .show_progress(trainer.show_progress())
                            .special_tokens(trainer.special_tokens().to_vec())
                            .initial_alphabet(trainer.initial_alphabet().clone());
                        builder = match trainer.limit_alphabet() {
                            Some(limit_alphabet) => builder.limit_alphabet(limit_alphabet),
                            None => builder,
                        };
                        builder = match trainer.continuing_subword_prefix() {
                            Some(continuing_subword_prefix) => builder
                                .continuing_subword_prefix(continuing_subword_prefix.to_string()),
                            None => builder,
                        };
                        builder = match trainer.end_of_word_suffix() {
                            Some(end_of_word_suffix) => {
                                builder.end_of_word_suffix(end_of_word_suffix.to_string())
                            }
                            None => builder,
                        };
                        TrainerWrapper::WordPieceTrainer(builder.build())
                    }
                    TrainerWrapper::WordLevelTrainer(trainer) => {
                        TrainerWrapper::WordLevelTrainer(trainer.clone())
                    }
                    TrainerWrapper::UnigramTrainer(trainer) => {
                        TrainerWrapper::UnigramTrainer(trainer.clone())
                    }
                };

                let mut trainer = ExTokenizersTrainer::new(trainer);

                new_tokenizer.train_from_files(&mut trainer, files)
            }
            None => {
                // Trainer is not defined, using default
                let mut default_trainer = new_tokenizer.get_model().get_trainer();
                new_tokenizer.train_from_files(&mut default_trainer, files)
            }
        }?;
        Ok(new_tokenizer)
    });
    let new_tokenizer = match result {
        Ok(value) => value,
        Err(panic) => {
            let panic_message = match panic.downcast_ref::<String>() {
                Some(s) => s.clone(),
                None => "Unknown Panic".to_string(),
            };
            Err(ExTokenizersError::Internal(panic_message))
        }
    }?;

    Ok(new_tokenizer.into())
}
