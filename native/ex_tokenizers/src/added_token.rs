use crate::{new_info, util::Info};
use rustler::{NifTaggedEnum, NifUntaggedEnum, Resource};
use serde::{Deserialize, Serialize};
use tokenizers::AddedToken;

pub struct ExTokenizersAddedTokenRef(pub AddedToken);

#[rustler::resource_impl]
impl Resource for ExTokenizersAddedTokenRef {}

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.AddedToken"]
pub struct ExTokenizersAddedToken {
    pub resource: rustler::ResourceArc<ExTokenizersAddedTokenRef>,
}

impl Serialize for ExTokenizersAddedToken {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersAddedToken {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersAddedToken::new(AddedToken::deserialize(
            deserializer,
        )?))
    }
}

impl ExTokenizersAddedTokenRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<AddedToken>,
    {
        Self(data.into())
    }
}

impl ExTokenizersAddedToken {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<AddedToken>,
    {
        Self {
            resource: rustler::ResourceArc::new(ExTokenizersAddedTokenRef::new(data)),
        }
    }
}

#[derive(NifUntaggedEnum)]
pub enum AddedTokenInput {
    AddedToken(ExTokenizersAddedToken),
    String(String),
}

#[derive(NifUntaggedEnum)]
pub enum AddedSpecialTokenInput {
    AddedToken(ExTokenizersAddedToken),
    String(String),
}

impl From<&AddedTokenInput> for AddedToken {
    fn from(input: &AddedTokenInput) -> Self {
        match input {
            AddedTokenInput::AddedToken(token) => token.resource.0.clone(),
            AddedTokenInput::String(string) => AddedToken::from(string, false),
        }
    }
}

impl From<&AddedSpecialTokenInput> for AddedToken {
    fn from(input: &AddedSpecialTokenInput) -> Self {
        match input {
            AddedSpecialTokenInput::AddedToken(token) => token.resource.0.clone(),
            AddedSpecialTokenInput::String(string) => AddedToken::from(string, true),
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
/// Inspection
///////////////////////////////////////////////////////////////////////////////

#[rustler::nif]
fn added_token_info(added_token: ExTokenizersAddedToken) -> Info {
    let added_token: &AddedToken = &added_token.resource.0;
    new_info!(
        content: added_token.content.clone(),
        single_word: added_token.single_word,
        lstrip: added_token.lstrip,
        rstrip: added_token.rstrip,
        normalized: added_token.normalized,
        special: added_token.special
    )
}

#[derive(NifTaggedEnum)]
pub enum AddedTokenOption {
    Special(bool),
    SingleWord(bool),
    Lstrip(bool),
    Rstrip(bool),
    Normalized(bool),
}

#[rustler::nif]
fn added_token_new(token: String, options: Vec<AddedTokenOption>) -> ExTokenizersAddedToken {
    struct Opts {
        special: bool,
        single_word: bool,
        lstrip: bool,
        rstrip: bool,
        normalized: Option<bool>,
    }
    let mut opts = Opts {
        special: false,
        single_word: false,
        lstrip: false,
        rstrip: false,
        normalized: None,
    };

    for option in options {
        match option {
            AddedTokenOption::Special(value) => opts.special = value,
            AddedTokenOption::SingleWord(value) => opts.single_word = value,
            AddedTokenOption::Lstrip(value) => opts.lstrip = value,
            AddedTokenOption::Rstrip(value) => opts.rstrip = value,
            AddedTokenOption::Normalized(value) => opts.normalized = Some(value),
        }
    }

    let mut token = AddedToken::from(token, opts.special);
    token = token.single_word(opts.single_word);
    token = token.lstrip(opts.lstrip);
    token = token.rstrip(opts.rstrip);
    if let Some(normalized) = opts.normalized {
        token = token.normalized(normalized);
    }

    ExTokenizersAddedToken::new(token)
}
