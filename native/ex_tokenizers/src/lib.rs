mod encoding;
mod error;
mod model;
mod tokenizer;

use encoding::*;
use model::*;
use rustler::{Env, Term};
use tokenizer::*;

pub use error::ExTokenizersError;

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(ExTokenizersTokenizerRef, env);
    rustler::resource!(ExTokenizersEncodingRef, env);
    rustler::resource!(ExTokenizersModelRef, env);
    true
}

rustler::init!(
    "Elixir.Tokenizers.Native",
    [
        add_special_tokens,
        decode,
        decode_batch,
        encode,
        encode_batch,
        from_file,
        get_attention_mask,
        get_type_ids,
        get_ids,
        get_special_tokens_mask,
        get_offsets,
        get_model,
        get_model_details,
        get_tokens,
        get_vocab,
        get_vocab_size,
        id_to_token,
        n_tokens,
        pad,
        save,
        token_to_id,
        truncate,
    ],
    load = on_load
);
