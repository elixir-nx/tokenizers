use crate::{new_info, util::Info};
use rustler::NifUntaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::AddedToken;

pub struct ExTokenizersAddedTokenRef(pub AddedToken);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.AddedToken"]
pub struct ExTokenizersAddedToken {
    pub resource: rustler::resource::ResourceArc<ExTokenizersAddedTokenRef>,
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
            resource: rustler::resource::ResourceArc::new(ExTokenizersAddedTokenRef::new(data)),
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

#[rustler::nif]
fn added_token_new(token: String, special: bool) -> ExTokenizersAddedToken {
    ExTokenizersAddedToken::new(AddedToken::from(token, special))
}

#[rustler::nif]
fn added_token_single_word(
    added_token: ExTokenizersAddedToken,
    single_word: bool,
) -> ExTokenizersAddedToken {
    ExTokenizersAddedToken::new(added_token.resource.0.clone().single_word(single_word))
}

#[rustler::nif]
fn added_token_lstrip(added_token: ExTokenizersAddedToken, lstrip: bool) -> ExTokenizersAddedToken {
    ExTokenizersAddedToken::new(added_token.resource.0.clone().lstrip(lstrip))
}

#[rustler::nif]
fn added_token_rstrip(added_token: ExTokenizersAddedToken, rstrip: bool) -> ExTokenizersAddedToken {
    ExTokenizersAddedToken::new(added_token.resource.0.clone().rstrip(rstrip))
}

#[rustler::nif]
fn added_token_normalized(
    added_token: ExTokenizersAddedToken,
    normalized: bool,
) -> ExTokenizersAddedToken {
    ExTokenizersAddedToken::new(added_token.resource.0.clone().normalized(normalized))
}
