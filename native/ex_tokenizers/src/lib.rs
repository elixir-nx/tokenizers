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

rustler::init!(
    "Elixir.Tokenizers.Native",
    [
        // AddedToken
        added_token_new,
        //
        added_token_info,
        // Decoders
        decoders_decode,
        //
        decoders_info,
        //
        decoders_byte_level,
        decoders_replace,
        decoders_wordpiece,
        decoders_byte_fallback,
        decoders_fuse,
        decoders_strip,
        decoders_metaspace,
        decoders_bpe,
        decoders_ctc,
        decoders_sequence,
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
        // Normalizers
        normalizers_normalize,
        //
        normalizers_info,
        //
        normalizers_bert_normalizer,
        normalizers_nfd,
        normalizers_nfkd,
        normalizers_nfc,
        normalizers_nfkc,
        normalizers_strip,
        normalizers_prepend,
        normalizers_strip_accents,
        normalizers_sequence,
        normalizers_lowercase,
        normalizers_replace,
        normalizers_nmt,
        normalizers_precompiled,
        // PreTokenizers
        pre_tokenizers_pre_tokenize,
        //
        pre_tokenizers_info,
        //
        pre_tokenizers_byte_level,
        pre_tokenizers_byte_level_alphabet,
        pre_tokenizers_whitespace,
        pre_tokenizers_whitespace_split,
        pre_tokenizers_bert,
        pre_tokenizers_metaspace,
        pre_tokenizers_char_delimiter_split,
        pre_tokenizers_split,
        pre_tokenizers_punctuation,
        pre_tokenizers_sequence,
        pre_tokenizers_digits,
        // PostProcessors
        post_processors_info,
        //
        post_processors_bert,
        post_processors_roberta,
        post_processors_byte_level,
        post_processors_template,
        post_processors_sequence,
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
