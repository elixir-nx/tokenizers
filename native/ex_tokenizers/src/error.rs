use rustler::{Encoder, Env, Term};
use std::io;
use thiserror::Error;

rustler::atoms! {
    ok,
    error
}

#[derive(Error, Debug)]
pub enum ExTokenizersError {
    #[error("Tokenizer Error")]
    Tokenizer(#[from] Box<dyn std::error::Error + Send + Sync>),
    #[error("IO Error")]
    Io(#[from] io::Error),
    #[error("Internal Error: {0}")]
    Internal(String),
    #[error("Other error: {0}")]
    Other(String),
    #[error(transparent)]
    Unknown(#[from] anyhow::Error),
}

impl Encoder for ExTokenizersError {
    fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
        format!("{self:?}").encode(env)
    }
}
