mod added_token;
mod decoders;
mod encoding;
mod error;
mod models;
mod normalizers;
mod post_processors;
mod pre_tokenizers;
mod tokenizer;
mod trainers;
mod util;

use rustler::{Env, Term};

pub use error::ExTokenizersError;

fn on_load(_env: Env, _info: Term) -> bool {
    true
}

rustler::init!("Elixir.Tokenizers.Native", load = on_load);
