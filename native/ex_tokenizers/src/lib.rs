mod encoding;
mod error;
mod tokenizer;

use encoding::*;
use rustler::{Env, Term};
use tokenizer::*;

pub use error::ExTokenizersError;

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(ExTokenizersTokenizerRef, env);
    rustler::resource!(ExTokenizersEncodingRef, env);
    true
}

rustler::init!(
    "Elixir.Tokenizers.Native",
    [
        decode,
        decode_batch,
        encode,
        encode_batch,
        from_file,
        from_pretrained,
        get_attention_mask,
        get_ids,
        get_tokens,
        get_vocab,
        get_vocab_size,
        id_to_token,
        pad,
        save,
        token_to_id,
        truncate,
    ],
    load = on_load
);
