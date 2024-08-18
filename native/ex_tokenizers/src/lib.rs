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

use added_token::*;
use decoders::*;
use encoding::*;
use models::*;
use normalizers::*;
use post_processors::*;
use pre_tokenizers::*;
use rustler::{Env, Term};
use tokenizer::*;
use trainers::*;

pub use error::ExTokenizersError;

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(ExTokenizersAddedTokenRef, env);
    rustler::resource!(ExTokenizersDecoderRef, env);
    rustler::resource!(ExTokenizersTokenizerRef, env);
    rustler::resource!(ExTokenizersEncodingRef, env);
    rustler::resource!(ExTokenizersTrainerRef, env);
    rustler::resource!(ExTokenizersModelRef, env);
    rustler::resource!(ExTokenizersNormalizerRef, env);
    rustler::resource!(ExTokenizersPostProcessorRef, env);
    rustler::resource!(ExTokenizersPreTokenizerRef, env);
    true
}

rustler::init!("Elixir.Tokenizers.Native", load = on_load);
