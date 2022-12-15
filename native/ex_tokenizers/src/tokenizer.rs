use std::collections::HashMap;

use rustler::Term;

use tokenizers::tokenizer::AddedToken;
use tokenizers::{EncodeInput, Tokenizer};

use crate::encoding::ExTokenizersEncoding;
use crate::error::ExTokenizersError;
use crate::model::ExTokenizersModel;

pub struct ExTokenizersTokenizerRef(pub Tokenizer);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Tokenizer"]
pub struct ExTokenizersTokenizer {
    pub resource: rustler::resource::ResourceArc<ExTokenizersTokenizerRef>,
}

impl ExTokenizersTokenizerRef {
    pub fn new(data: Tokenizer) -> Self {
        Self(data)
    }
}

impl ExTokenizersTokenizer {
    pub fn new(data: Tokenizer) -> Self {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersTokenizerRef::new(data)),
        }
    }
}

#[rustler::nif(schedule = "DirtyIo")]
pub fn from_file(
    path: &str,
    additional_special_tokens: Vec<String>,
) -> Result<ExTokenizersTokenizer, ExTokenizersError> {
    let mut tokenizer = Tokenizer::from_file(path)?;
    additional_special_tokens.iter().fold(0, |acc, token| {
        tokenizer.add_special_tokens(&[AddedToken::from(token, true)]) + acc
    });
    Ok(ExTokenizersTokenizer::new(tokenizer))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn encode(
    tokenizer: ExTokenizersTokenizer,
    input: Term,
    add_special_tokens: bool,
) -> Result<ExTokenizersEncoding, ExTokenizersError> {
    let input = term_to_encode_input(&input)?;
    let encoding = tokenizer.resource.0.encode(input, add_special_tokens)?;
    Ok(ExTokenizersEncoding::new(encoding))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn encode_batch(
    tokenizer: ExTokenizersTokenizer,
    inputs: Vec<Term>,
    add_special_tokens: bool,
) -> Result<Vec<ExTokenizersEncoding>, ExTokenizersError> {
    let inputs = inputs
        .iter()
        .map(term_to_encode_input)
        .collect::<Result<Vec<EncodeInput>, ExTokenizersError>>()?;
    let encodings = tokenizer
        .resource
        .0
        .encode_batch(inputs, add_special_tokens)?;
    let ex_encodings = encodings
        .iter()
        .map(|x| ExTokenizersEncoding::new(x.to_owned()))
        .collect();
    Ok(ex_encodings)
}

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

#[rustler::nif(schedule = "DirtyCpu")]
pub fn decode(
    tokenizer: ExTokenizersTokenizer,
    ids: Vec<u32>,
    skip_special_tokens: bool,
) -> Result<String, ExTokenizersError> {
    Ok(tokenizer.resource.0.decode(ids, skip_special_tokens)?)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn decode_batch(
    tokenizer: ExTokenizersTokenizer,
    sentences: Vec<Vec<u32>>,
    skip_special_tokens: bool,
) -> Result<Vec<String>, ExTokenizersError> {
    Ok(tokenizer
        .resource
        .0
        .decode_batch(sentences, skip_special_tokens)?)
}

#[rustler::nif]
pub fn token_to_id(
    tokenizer: ExTokenizersTokenizer,
    token: &str,
) -> Result<Option<u32>, ExTokenizersError> {
    Ok(tokenizer.resource.0.token_to_id(token))
}

#[rustler::nif]
pub fn id_to_token(
    tokenizer: ExTokenizersTokenizer,
    id: u32,
) -> Result<Option<String>, ExTokenizersError> {
    Ok(tokenizer.resource.0.id_to_token(id))
}

#[rustler::nif]
pub fn get_vocab(
    tokenizer: ExTokenizersTokenizer,
    with_added_tokens: bool,
) -> Result<HashMap<String, u32>, ExTokenizersError> {
    Ok(tokenizer.resource.0.get_vocab(with_added_tokens))
}

#[rustler::nif]
pub fn get_vocab_size(
    tokenizer: ExTokenizersTokenizer,
    with_added_tokens: bool,
) -> Result<usize, ExTokenizersError> {
    Ok(tokenizer.resource.0.get_vocab_size(with_added_tokens))
}

#[rustler::nif]
pub fn save(
    tokenizer: ExTokenizersTokenizer,
    path: &str,
    pretty: bool,
) -> Result<(), ExTokenizersError> {
    Ok(tokenizer.resource.0.save(path, pretty)?)
}

#[rustler::nif]
pub fn get_model(tokenizer: ExTokenizersTokenizer) -> Result<ExTokenizersModel, ExTokenizersError> {
    Ok(ExTokenizersModel::new(
        tokenizer.resource.0.get_model().clone(),
    ))
}
