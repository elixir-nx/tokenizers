mod added_token;
mod encoding;
mod error;
mod models;
mod tokenizer;
mod trainers;
mod util;

use added_token::*;
use encoding::*;
use models::*;
use rustler::{Env, Term};
use tokenizer::*;
use trainers::*;

pub use error::ExTokenizersError;

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(ExTokenizersAddedTokenRef, env);
    rustler::resource!(ExTokenizersTokenizerRef, env);
    rustler::resource!(ExTokenizersEncodingRef, env);
    rustler::resource!(ExTokenizersTrainerRef, env);
    rustler::resource!(ExTokenizersModelRef, env);
    true
}

rustler::init!(
    "Elixir.Tokenizers.Native",
    [
        // AddedToken - DONE
        added_token_new,
        //
        added_token_info,
        //
        added_token_single_word,
        added_token_lstrip,
        added_token_rstrip,
        added_token_normalized,
        // Models
        models_save,
        //
        models_info,
        //
        models_bpe_init,
        models_bpe_empty,
        models_bpe_from_file,
        //
        models_wordpiece_init,
        models_wordpiece_empty,
        models_wordpiece_from_file,
        //
        models_wordlevel_init,
        models_wordlevel_empty,
        models_wordlevel_from_file,
        //
        models_unigram_init,
        models_unigram_empty,
        // Trainers
        trainers_info,
        //
        trainers_train,
        //
        trainers_bpe_trainer,
        trainers_wordpiece_trainer,
        trainers_wordlevel_trainer,
        trainers_unigram_trainer,
        //
        decode,
        decode_batch,
        encode,
        encode_batch,
        from_file,
        get_attention_mask,
        get_u32_attention_mask,
        get_type_ids,
        get_u32_type_ids,
        get_ids,
        get_u32_ids,
        get_special_tokens_mask,
        get_u32_special_tokens_mask,
        get_offsets,
        get_model,
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
